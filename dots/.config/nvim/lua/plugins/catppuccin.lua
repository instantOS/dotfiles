return {
	"catppuccin/nvim",
	name = "catppuccin",
	opts = {
		integrations = {
			treesitter = true,
			mini = true,
			blink_cmp = true,
			vimwiki = true,
			snacks = true,
			mason = true,
		},
	},
	config = function()
		vim.cmd.colorscheme("catppuccin")
	end,
}
