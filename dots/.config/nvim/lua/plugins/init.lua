local potato = require("mypotato")
return {
	{ "tpope/vim-eunuch", event = "VeryLazy" },
	{ "tpope/vim-repeat", event = "VeryLazy" },
	-- { "mattn/emmet-vim" , event = "InsertEnter"},
	{ "tpope/vim-dadbod", cmd = { "DB", "DBUI" } },
	{ "kristijanhusak/vim-dadbod-ui", cmd = "DBUI" },

	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{ "<leader>T", "<cmd>Trouble diagnostics toggle", desc = "Trouble Diagnostics" },
		},
	},
	{
		"nvim-neorg/neorg",
		lazy = false,
		version = "*", -- Pin Neorg to the latest stable release
		config = true,
		enabled = not potato,
	},
	{ "paperbenni/Calendar.vim", cmd = { "Calendar", "CalendarH", "CalendarT" } },
	-- { "michal-h21/vim-zettel",   event = "BufRead *.md" },

	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
	},

	{ "j-hui/fidget.nvim", enabled = not potato },
	{
		"hrsh7th/nvim-cmp",
		enabled = (My_completion_engine == "mycmp"),
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"ray-x/cmp-treesitter",
			"rafamadriz/friendly-snippets",
			"saadparwaiz1/cmp_luasnip",
		},
	},
	{
		"ms-jpq/coq_nvim",
		enabled = (My_completion_engine == "mycoq"),
		dependencies = {
			{ "ms-jpq/coq.artifacts", branch = "artifacts" },
			{ "ms-jpq/coq.thirdparty", branch = "3p" },
		},
	},

	{ "xiyaowong/nvim-transparent", event = "VeryLazy" },
	{ "norcalli/nvim-colorizer.lua", event = "VeryLazy" },
	{ "machakann/vim-highlightedyank", enabled = not potato },
	--TODO: check if this can be replaced by mini or snacks
	-- { "lewis6991/gitsigns.nvim",       enabled = not potato },
	-- TODO: check if this can be replaced by blink cmp
	-- { "ray-x/lsp_signature.nvim",      enabled = not potato },

	{
		"simrat39/rust-tools.nvim",
		enabled = not potato,
		event = "BufRead *.rs",
	},
	{ "mfussenegger/nvim-dap-python", enabled = not potato },
}
