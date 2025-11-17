require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.concealer"] = {},
		["core.integrations.telescope"] = {},
		["core.latex.renderer"] = {
			config = {
				conceal = true,
			},
		},
		["core.dirman"] = {
			config = {
				workspaces = {
					notes = "~/txxwiki/norg",
				},
				default_workspace = "notes",
			},
		},
	},
})

-- TODO: keybinds
-- - switch workspace
-- - open index
-- - create new note

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "norg",
	callback = function()
		vim.keymap.set("i", "<C-l>", function()
			require("telescope").extensions.neorg.insert_link()
		end, { buffer = true, desc = "Insert Neorg link" })
	end,
})
