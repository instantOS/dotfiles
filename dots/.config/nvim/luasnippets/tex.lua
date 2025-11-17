local mathsnips = require("math_snips")

-- Helper function to check if we're in math mode
local function math_mode_condition()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

return mathsnips(math_mode_condition)
