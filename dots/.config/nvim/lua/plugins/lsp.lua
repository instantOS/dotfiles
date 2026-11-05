return {
	"neovim/nvim-lspconfig",
	event = { "VeryLazy", "BufReadPost", "BufWritePost", "BufNewFile" },
	config = function()
		if vim.fn.has("nvim-0.12") == 1 then
			vim.lsp.inline_completion.enable(true)
		end

		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
		})

		vim.lsp.config("tinymist", {
			settings = {
				projectResolution = "lockDatabase",
			},
		})

		vim.lsp.config["yamlls"] = {
			settings = {
				yaml = {
					schemas = {
						["https://raw.githubusercontent.com/canonical/cloud-init/main/cloudinit/config/schemas/versions.schema.cloud-config.json"] = "user-data.yml",
					},
				},
			},
		}

		vim.lsp.enable({
			"ty", -- Python type checking/completion (mise)
			"ruff", -- Python lint/format (mise)
			"tinymist", -- Typst (mise)
			"rust_analyzer", -- Rust (mise)
			"clangd", -- C/C++ (system)
		})
	end,
}
