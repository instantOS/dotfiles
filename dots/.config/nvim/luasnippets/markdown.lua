local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local extras = require("luasnip.extras")
local conds = require("luasnip.extras.expand_conditions")
local fmta = require("luasnip.extras.fmt").fmta

-- Function to check if cursor is inside a LaTeX math block in markdown
local function in_latex_math_block()
	local captures = vim.treesitter.get_captures_at_cursor()
	for _, capture in ipairs(captures) do
		if capture == "markup.math" then
			return true
		end
	end
	return false
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
