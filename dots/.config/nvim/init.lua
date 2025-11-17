vim.g.mapleader = " "

vim.loader.enable()

if vim.env.PROF then
	-- example for lazy.nvim
	-- change this to the correct path for your plugin manager
	local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
	vim.opt.rtp:append(snacks)
	require("snacks.profiler").startup({
		startup = {
			event = "VimEnter", -- stop profiler on this event. Defaults to `VimEnter`
			-- event = "UIEnter",
			-- event = "VeryLazy",
		},
	})
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local potato = require("mypotato")

-- My_completion_engine = "mycoq"
-- My_completion_engine = "mycmp"
My_completion_engine = "myblink"

require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	checker = { enabled = false },
})

vim.api.nvim_create_user_command("Debug", ":lua require'mydap'", { nargs = 0 })

vim.diagnostic.config({ virtual_lines = true })

if vim.fn.has("termguicolors") == 1 then
	vim.opt.termguicolors = true
end

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.colorcolumn = "80"

vim.g.neovide_cursor_vfx_mode = "sonicboom"

-- Custom commands
vim.api.nvim_create_user_command("Lighttheme", function()
	vim.cmd.colorscheme("catppuccin-latte")
	vim.opt.background = "light"
end, {})

vim.cmd([[

set guifont=FiraCode\ Nerd\ Font\ Mono:h11
set encoding=UTF-8

command! Cal Calendar | vertical resize +20

nnoremap <leader>vn :cnext<CR>
nnoremap <leader>vp :cprevious<CR>

noremap glk <Plug>VimwikiToggleListItem

" additional mode switching

"TODO: redo this
"inoremap <special> kj <ESC>
"inoremap <special> jk <ESC>:
"tnoremap <special> jk <C-\><C-n>

" move line up/down with alt j/k
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" TODO do this in lua and in mywiki
"autocmd FileType markdown nnoremap <buffer> <C-Space> <Plug>VimwikiToggleListItem

" let g:user_emmet_expandabbr_key = '<C-,>'

]])

-- TODO: make this use the mini dashboard
-- vim.keymap.set('n', '<leader>a', ":Startify<CR>")
vim.keymap.set("n", "<leader>f", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- TODO: make this work with mini or something
-- vim.keymap.set('n', '<leader>g', ':Gcd<CR>')

vim.keymap.set("n", "<leader>n", ":tabnew<CR>", { desc = "New tab" })
-- vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.relativenumber = true
opt.ignorecase = true
opt.smartcase = true

opt.conceallevel = 2

opt.hidden = true

opt.inccommand = "split"
opt.mouse = "a"
opt.scrolloff = 6
opt.foldenable = false

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

-- require("indent_blankline").setup {
--     -- for example, context is off by default, use this to turn it on
--     show_current_context = true,
--     show_current_context_start = true,
-- }

-- require("hardtime").setup()

if not potato then
	require("gitsigns").setup()
	require("colorizer").setup()
	-- require 'mycopilot'
	-- require 'myharpoon'

	-- this one is mostly annoying
	-- require "lsp_signature".setup()
end

--
-- require 'myneovide'

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- local mytheme = require('themes.catppuccin')
--
-- vim.cmd("colorscheme " .. mytheme.vimtheme)

if My_completion_engine == "mycoq" then
	vim.cmd("COQnow --shut-up")
end
