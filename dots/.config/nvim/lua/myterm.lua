vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		vim.api.nvim_buf_set_keymap(0, "t", "jk", "<C-\\><C-n>", { noremap = true, silent = true })
	end,
})
