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

local math_mode_condition = in_latex_math_block

-- Function to generate simple hash from URL
local function hash_url(url)
	local hash1 = 0
	local hash2 = 0
	for i = 1, #url do
		local char = string.byte(url, i)
		hash1 = (hash1 * 31 + char) % 2147483647
		hash2 = (hash2 * 37 + char) % 2147483647
	end
	return string.format("%x%x", hash1, hash2)
end

local function msnip(trigger, replacement, noWordTrig)
	local trigtable = {
		trig = trigger,
		snippetType = "autosnippet",
		condition = math_mode_condition,
	}

	if noWordTrig then
		trigtable.wordTrig = false
	end

	return s(trigtable, replacement)
end

local snippets = {}

local function mathletter(name, letter)
	local capitalized = name:sub(1, 1):upper() .. name:sub(2)
	local upperletter = string.upper(letter)

	table.insert(
		snippets,
		s({
			trig = "@" .. upperletter,
			snippetType = "autosnippet",
			condition = math_mode_condition,
		}, {
			t(capitalized .. " "),
		})
	)
	table.insert(
		snippets,
		s({
			trig = "@" .. letter,
			snippetType = "autosnippet",
			condition = math_mode_condition,
		}, {
			t(name .. " "),
		})
	)
end

local staticsnippets = {
	s({
		trig = "mk",
		regTrig = false,
		condition = function()
			return not math_mode_condition()
		end,
		snippetType = "autosnippet",
	}, {
		t("$"),
		i(1),
		t("$"),
	}),
	s({
		trig = "dm",
		snippetType = "autosnippet",
		condition = function()
			return not math_mode_condition()
		end,
	}, {
		t({ "", "$ " }),
		i(1),
		t({ " $", "" }),
	}),
	msnip("Sum", { t("sum_("), i(1), t(")^("), i(2), t(")") }),
	msnip("Par", {
		t("(diff "),
		i(1),
		t(")/(diff "),
		i(2),
		t(")"),
		i(3),
	}),
	s({
		trig = "^prq",
		regTrig = true,
		snippetType = "autosnippet",
	}, {
		t('#prequery.image("'),
		i(1),
		t('", "preq/'),
		f(function(args, snip)
			local url = args[1][1] or ""
			if url == "" then
				return "hash"
			else
				return hash_url(url)
			end
		end, { 1 }),
		t('")'),
		i(0),
	}),
}

mathletter("alpha", "a")
mathletter("beta", "b")
mathletter("gamma", "g")
mathletter("delta", "d")
mathletter("epsilon", "e")
mathletter("zeta", "z")
mathletter("eta", "h")
mathletter("theta", "t")
mathletter("iota", "i")
mathletter("kappa", "k")
mathletter("lambda", "l")
mathletter("mu", "m")
mathletter("psi", "p")
mathletter("sigma", "s")
mathletter("upsilon", "u")
mathletter("omega", "o")
mathletter("xi", "x")

for _, snippet in ipairs(staticsnippets) do
	table.insert(snippets, snippet)
end

return snippets
