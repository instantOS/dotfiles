return {
	"yetone/avante.nvim",
	version = false,
	enabled = false,
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
	},
	build = "make",
	config = function(_, opts)
		vim.opt.laststatus = 3
		require("avante").setup(opts)
	end,
	opts = {
		provider = "openrouter",
		ollama = {
			model = "smollm2:135m",
		},
		vendors = {
			openrouter = {
				__inherited_from = "openai",
				endpoint = "https://openrouter.ai/api/v1",
				api_key_name = "OPENROUTER_API_KEY",
				model = "deepseek/deepseek-chat-v3-0324:free",
				disable_tools = true, -- disable tools!
			},
		},
	},
}
