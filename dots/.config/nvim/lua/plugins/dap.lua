return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	lazy = true,
	cmd = {
		"DapClearBreakpoints",
		"DapContinue",
		"DapDisconnect",
		"DapEval",
		"DapNew",
		"DapPause",
		"DapRestartFrame",
		"DapSetLogLevel",
		"DapShowLog",
		"DapStepInto",
		"DapStepOut",
		"DapStepOver",
		"DapTerminate",
		"DapToggleBreakpoint",
		"DapToggleRepl",
		"DapUiToggle",
	},
	config = function()
		local dap = require("dap")
		vim.api.nvim_create_user_command("DapUiToggle", function()
			require("dapui").toggle()
		end, { desc = "Toggle DAP UI" })
		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			name = "gdb",
			args = { "--interpreter=dap", "--eval-command", "set pretty print on" },
		}
		dap.configurations.cpp = {
			{
				request = "launch",
				type = "gdb",
				name = "Launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				ars = {},
			},
		}
		require("dapui").setup()

		vim.keymap.set("n", "<F4>", function()
			require("dapui").toggle()
		end)
		vim.keymap.set("n", "<F5>", function()
			require("dap").continue()
		end)
		vim.keymap.set("n", "<F10>", function()
			require("dap").step_over()
		end)
		vim.keymap.set("n", "<F11>", function()
			require("dap").step_into()
		end)
		vim.keymap.set("n", "<F12>", function()
			require("dap").step_out()
		end)
		vim.keymap.set("n", "<Leader>B", function()
			require("dap").toggle_breakpoint()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
			require("dap.ui.widgets").hover()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
			require("dap.ui.widgets").preview()
		end)
		vim.keymap.set("n", "<Leader>df", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.frames)
		end)
		vim.keymap.set("n", "<Leader>ds", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes)
		end)
		-- vim.opt.laststatus = 3
	end,
}
