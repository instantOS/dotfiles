-- Run: TZ=Europe/Berlin nvim --headless -u NONE -l tests/calendar.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.o.lines, vim.o.columns = 40, 100
vim.o.hidden = true
local api = vim.api
local calendar = require("mycalendar")
local wiki = require("mywiki")
local root = vim.fn.tempname() .. " wiki"
vim.g.mywiki_root = root
calendar.setup()
local function key(lhs)
	local mapping = vim.fn.maparg(lhs, "n", false, true)
	assert(type(mapping.callback) == "function", "Missing mapping: " .. lhs)
	mapping.callback()
end
local function text()
	return table.concat(api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end
local function selected(date)
	assert(text():find("  " .. date .. " ·", 1, true), "Expected selection " .. date .. "\n" .. text())
end
local function open(date)
	calendar.open(date)
	selected(date)
end
local ok, err = xpcall(function()
	assert(#wiki.daily_dates() == 0)
	open("2024-02-28")
	key("l")
	selected("2024-02-29")
	key("l")
	selected("2024-03-01")
	key("h")
	selected("2024-02-29")
	key("}")
	selected("2025-02-28")
	key("q")
	assert(vim.fn.isdirectory(root) == 0, "Browsing must not create notes/directories")
	open("2024-01-31")
	key("]")
	selected("2024-02-29")
	key("q")
	open("2026-03-28")
	key("l")
	selected("2026-03-29")
	key("l")
	selected("2026-03-30")
	key("q")
	open("2026-10-24")
	key("l")
	selected("2026-10-25")
	key("l")
	selected("2026-10-26")
	key("q")
	local before = api.nvim_get_current_buf()
	calendar.open("2026-02-30")
	assert(api.nvim_get_current_buf() == before, "Invalid dates must not open")
	vim.fn.mkdir(root .. "/diary", "p")
	vim.fn.writefile({ "# A real entry", "Some thoughts" }, wiki.daily_path("2024-02-29"))
	vim.fn.writefile({ "# Next" }, wiki.daily_path("2024-03-04"))
	open("2024-02-29")
	assert(text():find("# A real entry", 1, true))
	assert(text():find("29*", 1, true))
	key("n")
	selected("2024-03-04")
	key("p")
	selected("2024-02-29")
	key("<CR>")
	assert(api.nvim_buf_get_name(0) == wiki.daily_path("2024-02-29"))
	api.nvim_buf_set_lines(0, 0, -1, false, { "# Unsaved preview" })
	calendar.open()
	selected("2024-02-29")
	assert(text():find("# Unsaved preview", 1, true))
	key("q")
	assert(vim.bo.modified and api.nvim_get_current_line() == "# Unsaved preview")
	open("2024-02-28")
	key("<C-v>")
	assert(api.nvim_buf_get_name(0) == wiki.daily_path("2024-02-28"))
	assert(#api.nvim_list_wins() == 2)
	vim.cmd("close")
	open("2024-02-29")
	local buf = api.nvim_get_current_buf()
	calendar.open("2024-03-01")
	assert(api.nvim_get_current_buf() == buf, "Reopening should reuse float")
	selected("2024-03-01")
	vim.o.columns = 60
	api.nvim_exec_autocmds("VimResized", {})
	selected("2024-03-01")
	vim.o.lines = 24
	api.nvim_exec_autocmds("VimResized", {})
	assert(api.nvim_buf_line_count(0) <= api.nvim_win_get_height(0), "Controls must fit a standard terminal")
	key("q")
	-- Capture the actual picker options, then exercise its calendar action.
	local picker
	package.loaded["fzf-lua"] = {
		utils = {
			ansi_from_hl = function(_, s)
				return s
			end,
			ansi_codes = {
				grey = function(s)
					return s
				end,
			},
		},
		fzf_exec = function(entries, opts)
			picker = { entries = entries, opts = opts }
		end,
	}
	wiki.dailies()
	assert(#picker.entries == 29)
	local seen = {}
	for _, entry in ipairs(picker.entries) do
		local date = entry:match("\t(.+)$")
		assert(not seen[date], "Duplicate daily date across DST")
		seen[date] = true
	end
	picker.opts.actions["ctrl-g"]({ "note\t2024-02-29" })
	selected("2024-02-29")
	key("D")
	assert(vim.bo.filetype ~= "diarycalendar")
	vim.cmd("Cal 2024-02-29")
	selected("2024-02-29")
	key("q")
end, debug.traceback)
vim.fn.delete(root, "rf")
if not ok then
	error(err)
end
print("Calendar tests passed")
vim.cmd("qa!")
