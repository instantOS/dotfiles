return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	-- ft = "markdown",
	-- enabled = false,
	cmd = { "Obsidian" },
	keys = {
		{
			"<leader>ww",
			"<cmd>Obsidian quick_switch<CR>",
			desc = "Open obsidian file",
		},
		{
			"<leader>ws",
			"<cmd>Obsidian search<CR>",
			desc = "Search obsidian vault",
		},
		{
			"<leader>wt",
			"<cmd>Obsidian dailies -14 14<CR>",
			desc = "Pick obsidian note in last and next 14 days",
		},
		{
			"<leader>w<leader>w",
			"<cmd>Obsidian today<CR>",
			desc = "Open obsidian daily note",
		},
	},
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
	},
	opts = {
		legacy_commands = false,
		completion = {
			blink = true,
			nvim_cmp = false,
		},
		workspaces = {
			{
				name = "wiki",
				path = "~/wiki/vimwiki",
			},
		},
		daily_notes = {
			folder = "diary",
			date_format = "%Y-%m-%d",
		},
		picker = {
			name = "snacks.pick",
		},
	},
}
