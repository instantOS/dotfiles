return {
	enabled = false,
	"Exafunction/windsurf.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	config = function()
		require("codeium").setup({
			enable_cmp_source = false,
			virtual_text = {
				enabled = true,
				default_filetype_enabled = true,
				key_bindings = {
					-- Accept the current completion.
					accept = "<C-j>",
					-- Accept the next word.
					accept_word = false,
					-- Accept the next line.
					accept_line = false,
					-- Clear the virtual text.
					clear = "<C-e>",
					-- Cycle to the next completion.
					-- next = "<M-]>",
					next = false,
					-- Cycle to the previous completion.
					-- prev = "<M-[>",
					prev = false,
				},
			},
		})
	end,
}
