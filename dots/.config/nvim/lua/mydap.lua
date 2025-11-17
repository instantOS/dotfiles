vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F5>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F5>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F5>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")

vim.keymap.set("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl_open()<CR>")

-- ui

require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
require("dapui").setup()
