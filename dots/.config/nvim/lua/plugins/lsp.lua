return {
	-- "neovim/nvim-lspconfig",
	"mason-org/mason-lspconfig.nvim",
	dependencies = {
		{ "mason-org/mason.nvim" },
		"neovim/nvim-lspconfig",
	},
	event = { "VeryLazy", "BufReadPost", "BufWritePost", "BufNewFile" },
	config = function()
		-- local potato = require("mypotato")
		if vim.fn.has("nvim-0.12") == 1 then
			vim.lsp.inline_completion.enable(true)
		end
		require("mason").setup()
		require("mason-lspconfig").setup({
			automatic_enable = {
				exclude = {
					"harper_ls",
					"lua_ls",
				},
			},
		})
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.lsp.config["yamlls"] = {
			capabilities = capabilities,
			settings = {
				yaml = {
					schemas = {
						["https://raw.githubusercontent.com/canonical/cloud-init/main/cloudinit/config/schemas/versions.schema.cloud-config.json"] = "user-data.yml",
					},
				},
			},
		}
	end,
}
