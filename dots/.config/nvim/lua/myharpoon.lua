local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():append()
end)
vim.keymap.set("n", "<C-x>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
