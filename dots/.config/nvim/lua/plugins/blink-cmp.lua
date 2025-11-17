return {
	"saghen/blink.cmp",
	event = "InsertEnter",
	enabled = (My_completion_engine == "myblink"),
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	version = "1.*",
	--@module 'blink.cmp'
	--@type blink.cmp.config
	opts = {
		snippets = { preset = "luasnip" },
		completion = {
			list = {
				selection = { preselect = false, auto_insert = true },
			},
		},
		cmdline = {
			keymap = {
				preset = "none",
			},
			sources = {},
		},
		keymap = {
			-- cmdline = { preset = 'none' },
			preset = "super-tab",
			["<Tab>"] = {
				function() -- sidekick next edit suggestion
					return require("sidekick").nes_jump_or_apply()
				end,
				function() -- if you are using Neovim's native inline completions
					return vim.lsp.inline_completion.get()
				end,
				function(cmp)
					if cmp.snippet_active() then
						return cmp.accept()
					else
						return cmp.select_next()
					end
				end,
				"snippet_forward",
				"fallback",
			},
			["<CR>"] = { "accept", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				codecompanion = { "codecompanion" },
			},
			providers = {
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					opts = {},
					enabled = true,
					async = false,
					timeout_ms = 500,
					transform_items = nil,
					should_show_items = true,
					max_items = 10,
					min_keyword_length = 1,
					score_offset = 0,
					fallbacks = {},
					override = nil,
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		signature = { enabled = true },
	},
	opts_extend = { "sources.default" },
}
