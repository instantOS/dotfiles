return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		require("nvim-treesitter").setup()

		local enabled_filetypes = {
			"c",
			"cpp",
			"css",
			"dart",
			"diff",
			"dockerfile",
			"go",
			"gomod",
			"html",
			"javascript",
			"json",
			"lua",
			"make",
			"nginx",
			"python",
			"regex",
			"rust",
			"sh",
			"sql",
			"svelte",
			"sway",
			"terraform",
			"toml",
			"typescript",
			"typescriptreact",
			"udev",
			"zathurarc",
			"zig",
		}

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
			pattern = enabled_filetypes,
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo.foldmethod = "expr"
			end,
		})
	end,
}
