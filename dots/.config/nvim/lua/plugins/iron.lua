return {
	"Vigemus/iron.nvim",
	cmd = { "IronRepl", "Iron" },
	keys = {
		{
			"<leader>I",
			ft = { "sh", "python" },
			function()
				vim.cmd("Iron")
			end,
			desc = "Activate Iron Repl",
		},
	},

	config = function()
		local iron = require("iron.core")
		local view = require("iron.view")
		iron.setup({
			config = {
				-- Whether a repl should be discarded or not
				scratch_repl = true,
				-- Your repl definitions come here
				repl_definition = {
					sh = {
						-- Can be a table or a function that
						-- returns a table (see below)
						command = { "zsh" },
					},
					python = {
						-- pip install ipython
						-- pip install catppuccin
						command = { "ipython", "--no-autoindent" }, -- or { "ipython", "--no-autoindent" }
						format = require("iron.fts.common").bracketed_paste_python,
						block_deviders = { "# %%", "#%%" },
					},
				},
				-- set the file type of the newly created repl to ft
				-- bufnr is the buffer id of the REPL and ft is the filetype of the
				-- language being used for the REPL.
				repl_filetype = function(bufnr, ft)
					return ft
					-- or return a string name such as the following
					-- return "iron"
				end,
				repl_open_cmd = {
					view.split.vertical.rightbelow("%20"), -- cmd_1: open a repl to the right
					view.split.rightbelow("%25"), -- cmd_2: open a repl below
				},
				-- How the repl window will be displayed
				-- See below for more information
			},
			-- Iron doesn't set keymaps by default anymore.
			-- You can set them here or manually add keymaps to the functions in iron.core
			keymaps = {
				send_motion = "<space>sc",
				visual_send = "<space>sc",
				send_file = "<space>sf",
				send_line = "<space>sl",
				send_paragraph = "<space>sp",
				send_until_cursor = "<space>su",
				send_mark = "<space>sm",
				send_code_block = "<space>sb",
				send_code_block_and_move = "<space>sn",
				mark_motion = "<space>mc",
				mark_visual = "<space>mc",
				remove_mark = "<space>md",
				cr = "<space>s<cr>",
				interrupt = "<space>s<space>",
				exit = "<space>sq",
				clear = "<space>cl",
			},
			-- If the highlight is on, you can change how it looks
			-- For the available options, check nvim_set_hl
			highlight = {
				italic = true,
			},
			ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
		})
		-- Create user command 'Iron' that starts REPL and configures mappings
		vim.api.nvim_create_user_command("Iron", function()
			-- Set up terminal initialization handler
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "*",
				once = true,
				callback = function(args)
					-- Configure terminal escape mapping
					vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {
						buffer = args.buf,
						noremap = true,
						desc = "Exit terminal mode",
					})
				end,
			})

			-- Launch Iron REPL
			vim.cmd("IronRepl")

			-- Configure F5 motion mapping
			vim.keymap.set({ "n", "x" }, "<F5>", function()
				require("iron.core").run_motion("send_motion")
			end, {
				noremap = true,
				desc = "Send code to REPL",
			})

			vim.keymap.set({ "n", "x" }, "<F6>", function()
				require("iron.core").send_line()
				vim.cmd("normal! j")
			end, {
				noremap = true,
				desc = "Send code to REPL",
			})
		end, {})
	end,
}
