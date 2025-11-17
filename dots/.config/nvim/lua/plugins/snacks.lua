local potato = require("mypotato")
return {
	"folke/snacks.nvim",
	lazy = false,
	-- version = "*",
	priority = 1000,
	---@type snacks.Config
	-- config = function()
	--     vim.api.nvim_create_autocmd("User", {
	--         pattern = "MiniFilesActionRename",
	--         callback = function(event)
	--             Snacks.rename.on_rename_file(event.data.from, event.data.to)
	--         end,
	--     })
	-- end,
	opts = {
		indent = {
			enabled = false,
			-- filter for buffers to enable indent guides
			filter = function(buf)
				local is_markdown = vim.bo[buf].filetype == "markdown"
				return vim.g.snacks_indent ~= false
					and vim.b[buf].snacks_indent ~= false
					and vim.bo[buf].buftype == ""
					and not is_markdown
			end,
		},
		image = {
			doc = {
				max_width = 160,
				max_height = 40,
				---@param lang string tree-sitter language
				---@param type snacks.image.Type image type
				conceal = function(lang, type)
					-- only conceal math expressions
					return type == "math"
				end,
			},
			enabled = not potato,
			math = {
				enabled = true,
				latex = {
					packages = {
						"unicode-math",
						-- "amsmath",
						-- "amssymb",
						-- "amsfonts",
						-- "amscd",
						-- "mathrsfs",
						"mathtools",
					},
					tpl = [[
                          \documentclass[preview,border=0pt,varwidth,12pt,varwidth=180mm]{standalone}
                          \usepackage{${packages}}
                          \DeclareMathAlphabet{\mathcal}{OMS}{cmsy}{m}{n}
                          \begin{document}
                          ${header}
                          { \${font_size} \selectfont
                            \color[HTML]{${color}}
                            \renewcommand{\setminus}{\mathbin{\backslash}}
                          ${content}}
                          \end{document}]],
				},
			},
		},
		bigfile = { enabled = true },
		quickfile = { enabled = true },
		dashboard = { enabled = true },
		zen = {
			toggles = {
				dim = false,
				git_signs = false,
				mini_diff_signs = true,
			},
			show = {
				statusline = true,
				tabline = true,
			},
			win = {
				backdrop = {
					transparent = false,
				},
			},
		},
		words = { enabled = not potato },
		scroll = {
			enabled = not potato,
			easing = "quadratic",
		},
		picker = {
			enabled = true,
			matcher = {
				frecency = true,
			},
		},
		input = { enabled = true },
		scratch = { enabled = true },
		lazygit = { enabled = true },
	},
	keys = {
		{
			"<leader>Z",
			function()
				Snacks.zen.zoom()
			end,
			desc = "Zoom onto the current buffer",
		},
		{
			"<leader>z",
			function()
				Snacks.zen.zen()
			end,
			desc = "Zen Mode",
		},
		{
			"<leader>G",
			function()
				local git_dir = Snacks.git.get_root()
				print("Git dir " .. git_dir)
				if git_dir then
					vim.cmd("cd " .. git_dir)
				end
			end,
			desc = "Cd into Git Root",
		},
		{
			"<leader>g",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>tt",
			function()
				require("myterm")
				Snacks.terminal.toggle()
			end,
			desc = "Toggle Terminal",
		},
		{
			"<leader>ts",
			function()
				Snacks.picker.lsp_symbols({ layout = { preset = "vscode", preview = "main" } })
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>tr",
			function()
				Snacks.picker.lsp_references({ layout = { preset = "vscode", preview = "main" } })
			end,
			desc = "LSP References",
		},
		{
			"<leader>tw",
			function()
				Snacks.picker.lsp_workspace_symbols({ layout = { preset = "vscode", preview = "main" } })
			end,
			desc = "LSP Workspace Symbols",
		},
		{
			"<leader>to",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent files",
		},
		{
			"<leader>tp",
			function()
				Snacks.picker()
			end,
			desc = "View all pickers",
		},
		{
			"<leader><SPACE>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Files",
		},
		{
			"<leader>b",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>l",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},

		--     { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
		--     { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
	},
}
