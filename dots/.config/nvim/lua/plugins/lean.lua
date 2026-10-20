-- Lean 4 support: https://github.com/Julian/lean.nvim
--
-- lean.nvim is the de-facto standard Lean 4 plugin for Neovim (maintained by
-- a Lean FRO member, used by the Lean FRO themselves). It replaces the older
-- lspleank / weblean approach entirely.
--
-- Configuration is read from `vim.g.lean_config` (lean.nvim's `setup` is
-- deprecated). lazy.nvim's `init` hook runs at startup, before the plugin is
-- loaded, which is exactly what lean.nvim needs.
return {
	{
		"Julian/lean.nvim",
		event = { "BufReadPre *.lean", "BufNewFile *.lean" },
		init = function()
			vim.g.lean_config = {
				-- <LocalLeader> mappings (see :maplocalleader in init.lua):
				--   ,i toggle infoview      ,r restart file
				--   ,x add pin              ,c clear pins
				--   ,s accept suggestion    ,v view options
				--   ,w / ,W toggle widgets  ,p pause infoview
				--   ,dx / ,dc / ,dd / ,dt diff pins
				mappings = true,

				infoview = {
					autoopen = true,
					width = 1 / 3,
					height = 1 / 3,
					orientation = "auto",
				},

				-- Lean elaborates as you type, so keep diagnostics live.
				lsp = {
					enhanced_handlers = {
						hover = true, -- interactive hover popup instead of plain K
						diagnostics = true, -- filter silent diagnostics, multi-line signs
					},
				},

				abbreviations = {
					enable = true,
					leader = "\\", -- \lambda -> λ
				},
			}
		end,
	},
}
