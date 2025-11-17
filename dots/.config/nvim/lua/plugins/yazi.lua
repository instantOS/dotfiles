return {
	"mikavilpas/yazi.nvim",
	version = "*",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim", lazy = true },
	keys = {
		{
			"<leader>-",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "Open Yazi at the current file",
		},
		{
			"<leader>we",
			mode = { "n", "v" },
			"<cmd>cd ~/wiki/vimwiki/ | Yazi cwd<cr>",
			desc = "Open Yazi at the current file",
		},
	},
}
