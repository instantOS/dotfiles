local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local extras = require("luasnip.extras")
local conds = require("luasnip.extras.expand_conditions")
local fmta = require("luasnip.extras.fmt").fmta

local function is_escaped(text, column)
	local backslashes = 0
	column = column - 1
	while column > 0 and text:sub(column, column) == "\\" do
		backslashes = backslashes + 1
		column = column - 1
	end
	return backslashes % 2 == 1
end

-- Tree-sitter can briefly have no captures immediately after an edit. This
-- scanner is the fallback for that window; unlike forcing parser:parse(), its
-- cost does not depend on Tree-sitter reparsing the document.
local function markdown_math_fallback(row, column)
	local lines = vim.api.nvim_buf_get_lines(0, 0, row + 1, false)
	local fence_char, fence_length
	local code_ticks
	local display_math = false
	local inline_math = false

	for line_number, full_line in ipairs(lines) do
		local line = line_number == row + 1 and full_line:sub(1, column) or full_line
		local _, fence = line:match("^( ? ? ?)([`~]+)")

		if fence and (not fence_char or fence:sub(1, 1) == fence_char) then
			local char = fence:sub(1, 1)
			if not fence_char and #fence >= 3 then
				fence_char, fence_length = char, #fence
			elseif fence_char and #fence >= fence_length then
				fence_char, fence_length = nil, nil
			end
			inline_math = false
			goto continue
		end

		if fence_char then
			goto continue
		end

		local position = 1
		while position <= #line do
			local char = line:sub(position, position)

			if char == "`" and not display_math and not inline_math then
				local run_end = line:find("[^`]", position) or (#line + 1)
				local run_length = run_end - position
				if not code_ticks then
					code_ticks = run_length
				elseif code_ticks == run_length then
					code_ticks = nil
				end
				position = run_end
			elseif char == "$" and not code_ticks and not is_escaped(line, position) then
				local run_end = line:find("[^$]", position) or (#line + 1)
				local run_length = run_end - position
				if run_length == 2 and not inline_math then
					display_math = not display_math
				elseif run_length == 1 and not display_math then
					inline_math = not inline_math
				end
				position = run_end
			else
				position = position + 1
			end
		end

		if line_number < row + 1 then
			inline_math = false
		end

		::continue::
	end

	if fence_char or code_ticks then
		return false
	end
	if display_math then
		return true
	end
	if not inline_math then
		return false
	end

	-- A closing delimiter must already exist for the inline fallback. This
	-- avoids treating ordinary currency text such as "$5 ..." as math.
	local rest = lines[#lines]:sub(column + 1)
	for position = 1, #rest do
		if rest:sub(position, position) == "$" and not is_escaped(rest, position) then
			return rest:sub(position + 1, position + 1) ~= "$"
		end
	end
	return false
end

local function in_latex_math_block()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, column = cursor[1] - 1, cursor[2]
	local capture_column = math.max(column - 1, 0)

	for _, item in ipairs(vim.treesitter.get_captures_at_pos(0, row, capture_column)) do
		if item.capture == "markup.math" then
			return true
		end
	end

	return markdown_math_fallback(row, column)
end

local snippets = require("math_snips")(in_latex_math_block)

local function in_anki_file()
	local file_path = vim.api.nvim_buf_get_name(0)
	return string.find(file_path, "anki") and string.match(file_path, "%.md$")
end

local function in_video_file()
	local file_path = vim.api.nvim_buf_get_name(0)
	return string.find(file_path, "video") and string.match(file_path, "%.md$")
end

local function conditional_snip(trigger, replacement, condition, extras)
	return s(
		vim.tbl_extend("force", {
			snippetType = "autosnippet",
			trig = trigger,
			condition = condition,
		}, extras),
		replacement
	)
end

local function ankisnip(trigger, replacement, extras)
	return conditional_snip(trigger, replacement, in_anki_file, extras)
end

local function videosnip(trigger, replacement, extras)
	return conditional_snip(trigger, replacement, in_video_file, extras)
end

local function blockenv(name)
	return s({
		trig = "^" .. name .. ":",
		snippetType = "autosnippet",
		regTrig = true,
		wordTrig = false,
	}, {
		t({ "```" .. name, "" }),
		i(1),
		t({ "", "```" }),
	})
end

local staticmdsnippets = {
	s({
		trig = "^img ",
		snippetType = "autosnippet",
		regTrig = true,
		wordTrig = false,
	}, {
		t("!["),
		i(1),
		t("]("),
		i(2),
		t(")"),
	}),
	blockenv("bash"),
	blockenv("txt"),
	blockenv("python"),
	blockenv("rust"),
	videosnip("^music:", {
		t({ "```music", "" }),
		i(1),
		t({ "", "```" }),
	}, {
		regTrig = true,
	}),
	videosnip("^ps  ", {
		t({ "", "---", "" }),
		i(1),
		t({ "", "---", "" }),
	}, {
		regTrig = true,
	}),
	ankisnip(
		"^QA",
		fmta(
			[[Q: <>
A: <>


        ]],
			{
				i(1),
				i(2),
			}
		),
		{
			regTrig = true,
		}
	),
	ankisnip(
		"^MQ",
		fmta(
			[[Q: <>
A: .
$$
<>
$$


        ]],
			{
				i(1),
				i(2),
			}
		),
		{
			regTrig = true,
		}
	),
}

for _, snippet in ipairs(staticmdsnippets) do
	table.insert(snippets, snippet)
end

return snippets
