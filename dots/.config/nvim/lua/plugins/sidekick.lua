return {
	"folke/sidekick.nvim",
	opts = {
		nes = {
			enabled = function(buf)
				-- Check if file contains "secret" (case-insensitive)
				local filename = vim.api.nvim_buf_get_name(buf)
				if filename == "" then
					return true
				end -- allow for unnamed buffers

				local content = vim.fn.readfile(filename)
				for _, line in ipairs(content) do
					if line:lower():find("secret") then
						return false -- disable sidekick for files containing "secret"
					end
				end
				return true
			end,
		},
		cli = {
			prompts = {
				spellcheck = "search for simple typos in {file} and fix them",
			},
			mux = {
				backend = "tmux",
				enabled = true,
			},
		},
	},
	keys = {
		{
			"<tab>",
			function()
				if vim.fn.has("nvim-0.12") == 1 then
					if require("sidekick").nes_jump_or_apply() then
						return
					end
				end
				return "<tab>"
			end,
			mode = { "n" },
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle CLI",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select()
			end,
			desc = "Select CLI",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
		{
			"<c-.>",
			function()
				require("sidekick.cli").focus()
			end,
			mode = { "n", "x", "i", "t" },
			desc = "Sidekick Switch Focus",
		},
		{
			"<leader>ac",
			function()
				require("sidekick.cli").toggle({ name = "claude", focus = true })
			end,
			desc = "Sidekick Toggle Claude",
		},
	},
}
