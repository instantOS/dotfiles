local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local extras = require("luasnip.extras")
local conds = require("luasnip.extras.expand_conditions")

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

local function ankisnip(trigger, replacement, extras)
	return s(
		vim.tbl_extend("force", {
			snippetType = "autosnippet",
			trig = trigger,
			condition = in_anki_file,
		}, extras),
		replacement
	)
end

-- TODO: condition for not math mode or within anything special
local function blockenv(name)
	return s({
		trig = "^" .. name .. " ",
		snippetType = "autosnippet",
		regTrig = true,
	}, {
		t({ "```" .. name, "" }),
		i(1),
		t({ "", "```" }),
	})
end

local staticmdsnippets = {
	-- TODO: more envs
	blockenv("bash"),
	blockenv("txt"),
	blockenv("python"),
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
