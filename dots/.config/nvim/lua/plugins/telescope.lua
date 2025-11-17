return {
	"nvim-telescope/telescope.nvim",
	lazy = true,
	enabled = false,
	keys = {
		{ "<leader>l", "<cmd>Telescope live_grep<cr>" },
		{ "<leader>b", "<cmd>Telescope buffers<CR>" },
		{ "<leader>th", "<cmd>Telescope help_tags<CR>" },
		{ "<leader>tr", "<cmd>Telescope lsp_references<CR>" },
		{ "<leader>ts", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>" },
		{ "<leader>tz", "<cmd>Telescope zoxide list<CR>" },
		{ "<leader>to", "<cmd>Telescope oldfiles<CR>" },
		{
			"<leader>r",
			function()
				require("telescope.builtin").lsp_document_symbols()
			end,
		},
		{ "<leader>tq", "<cmd>Telescope quickfix<CR>" },
	},
	config = function()
		local tactions = require("telescope.actions")
		local potato = require("mypotato")
		local telescope = require("telescope")

		telescope.load_extension("fzf")
		if not potato then
			telescope.load_extension("zoxide")
			telescope.load_extension("frecency")
			vim.cmd([[
                nnoremap <leader><SPACE> <cmd>Telescope frecency<cr>
            ]])
		else
			vim.cmd([[
                nnoremap <leader><SPACE> <cmd>Telescope find_files<cr>
            ]])
		end

		telescope.setup({
			extensions = {
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					-- the default case_mode is "smart_case"
				},
			},
			defaults = {
				mappings = {
					i = {
						["<esc>"] = tactions.close,
					},
				},
			},
		})
	end,
}
