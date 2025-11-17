return {
	"nvim-mini/mini.nvim",
	version = "*",
	config = function()
		require("mini.sessions").setup({})
		require("mini.git").setup({})
		require("mini.tabline").setup({})
		require("mini.icons").setup({})
		-- require("mini.diff").setup({})

		local miniclue = require("mini.clue")
		local potato = require("mypotato")

		-- if not potato then
		miniclue.setup({
			triggers = {
				-- leader
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },
				-- go
				{ mode = "n", keys = "g" },
				{ mode = "x", keys = "g" },
				-- folding
				{ mode = "n", keys = "z" },
				{ mode = "x", keys = "z" },
				-- marks
				{ mode = "n", keys = "'" },
				{ mode = "n", keys = "`" },
				{ mode = "x", keys = "'" },
				{ mode = "x", keys = "`" },
			},
			clues = {
				miniclue.gen_clues.builtin_completion(),
				miniclue.gen_clues.g(),
				miniclue.gen_clues.z(),
				miniclue.gen_clues.marks(),
			},
		})
		-- end

		-- if potato then
		-- 	require("mini.notify").setup({})
		-- end

		-- files
		local files = require("mini.files")

		-- require("mini.pairs").setup({})
		require("mini.surround").setup({
			mappings = {
				add = "S",
				delete = "ds",
				replace = "cs",
			},
		})

		files.setup({})
		vim.keymap.set("n", "<leader>e", function()
			files.open()
		end, { desc = "File explorer" })

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesActionRename",
			callback = function(event)
				Snacks.rename.on_rename_file(event.data.from, event.data.to)
			end,
		})

		local statusline = require("mini.statusline")
		statusline.setup()
	end,
	lazy = false,
	keys = {
		{
			"<leader>s",
			function()
				MiniSessions.select()
			end,
			desc = "Select session",
		},
	},
}
