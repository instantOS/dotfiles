return {
	"olimorris/codecompanion.nvim",
	-- enabled = false,
	opts = {},
	-- config = function ()
	--     vim.opt.laststatus = 3
	-- end,
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"CodeCompanionCmd",
	},
	keys = {
		{ mode = "v", "<leader>c", ":CodeCompanion ", { noremap = true, silent = false } },
		{ mode = "v", "<leader>C", ":CodeCompanionChat ", { noremap = true, silent = false } },
	},
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
