return {
	"stevearc/conform.nvim",
	opts = {
		formatters = {
			injected = {
				lang_to_ft = {
					tex = "tex",
				},
				lang_to_ext = {
					tex = "tex",
				},
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			rust = { "rustfmt", lsp_format = "fallback" },
			sh = { "shfmt", lsp_format = "fallback" },
			cpp = { "clang-format" },
			markdown = { "deno_fmt", "injected" },
			tex = { "tex-fmt" },
		},
	},
	keys = {
		{
			"<leader>F",
			function()
				require("conform").format()
			end,
		},
	},
}
