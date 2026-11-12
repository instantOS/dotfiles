-- Diary calendar. All date arithmetic uses local noon and calendar fields,
-- rather than adding 86400 seconds across daylight-saving transitions.
local M = {}
local api = vim.api
local ns = api.nvim_create_namespace("mycalendar")
local active

local function stamp(year, month, day)
	return os.time({ year = year, month = month, day = day, hour = 12 })
end

local function parse(date)
	if type(date) ~= "string" then
		return nil
	end
	local y, m, d = date:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
	if not y then
		return nil
	end
	local ts = stamp(tonumber(y), tonumber(m), tonumber(d))
	return os.date("%Y-%m-%d", ts) == date and ts or nil
end

local function date_of(ts)
	return os.date("%Y-%m-%d", ts)
end

local function move_day(ts, days)
	local d = os.date("*t", ts)
	return stamp(d.year, d.month, d.day + days)
end

local function move_month(ts, months)
	local d = os.date("*t", ts)
	local first = os.date("*t", stamp(d.year, d.month + months, 1))
	local last = os.date("*t", stamp(first.year, first.month + 1, 0)).day
	return stamp(first.year, first.month, math.min(d.day, last))
end

local function geometry()
	local width = math.min(88, vim.o.columns - 4)
	local height = math.min(32, vim.o.lines - vim.o.cmdheight - 4)
	return {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.floor((vim.o.lines - vim.o.cmdheight - height - 2) / 2)),
		col = math.max(0, math.floor((vim.o.columns - width - 2) / 2)),
		style = "minimal",
		border = "rounded",
		title = " Diary calendar ",
		title_pos = "center",
	}
end

local function close()
	local s = active
	active = nil
	if not s then
		return
	end
	if api.nvim_win_is_valid(s.win) then
		api.nvim_win_close(s.win, true)
	end
	if api.nvim_buf_is_valid(s.buf) then
		api.nvim_buf_delete(s.buf, { force = true })
	end
end

local function refresh(s)
	s.dates = require("mywiki").daily_dates()
	s.notes = {}
	for _, date in ipairs(s.dates) do
		s.notes[date] = true
	end
	-- Include unsaved daily notes in the markers and preview.
	local dir = vim.fs.dirname(require("mywiki").daily_path("2000-01-01"))
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(buf) then
			local path = api.nvim_buf_get_name(buf)
			local date = vim.fs.basename(path):match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")
			if date and vim.fs.dirname(path) == dir then
				if not s.notes[date] then
					s.dates[#s.dates + 1] = date
				end
				s.notes[date] = true
			end
		end
	end
	table.sort(s.dates)
end

local function preview(date, limit)
	if limit == 0 then
		return {}
	end
	local path = require("mywiki").daily_path(date)
	local buf = vim.fn.bufnr(path)
	if buf >= 0 and api.nvim_buf_is_loaded(buf) then
		return api.nvim_buf_get_lines(buf, 0, math.min(limit, api.nvim_buf_line_count(buf)), false)
	end
	local ok, lines = pcall(vim.fn.readfile, path, "", limit)
	return ok and lines or { "No note yet. Press Enter to start this day." }
end

local function render(s)
	if active ~= s or not api.nvim_win_is_valid(s.win) then
		return
	end
	local d = os.date("*t", s.selected)
	local first = os.date("*t", stamp(d.year, d.month, 1))
	local offset = (first.wday + 5) % 7 -- Monday first.
	local days = os.date("*t", stamp(d.year, d.month + 1, 0)).day
	local date = date_of(s.selected)
	local function separator(label)
		local prefix = "  ── " .. label .. " "
		return prefix
			.. string.rep("─", math.max(0, api.nvim_win_get_width(s.win) - vim.fn.strdisplaywidth(prefix) - 2))
	end
	local lines = { "  " .. os.date("%B %Y", s.selected), "", "  Mo   Tu   We   Th   Fr   Sa   Su" }
	local marks = {}
	local selected_row, selected_col
	for week = 0, 5 do
		local cells = {}
		for weekday = 0, 6 do
			local day = week * 7 + weekday - offset + 1
			local cell = "    "
			if day >= 1 and day <= days then
				local key = ("%04d-%02d-%02d"):format(d.year, d.month, day)
				cell = ("%2d%s "):format(day, s.notes[key] and "*" or " ")
				local col = 2 + weekday * 5
				local hl = key == os.date("%Y-%m-%d") and "MyCalendarToday"
					or s.notes[key] and "MyCalendarNote"
					or "NormalFloat"
				if key == date then
					hl = "MyCalendarSelected"
					selected_row, selected_col = #lines + 1, col
				end
				marks[#marks + 1] = { #lines, col, hl }
			end
			cells[#cells + 1] = cell
		end
		lines[#lines + 1] = "  " .. table.concat(cells, " ")
	end
	vim.list_extend(lines, {
		"",
		"  " .. date .. " · " .. os.date("%A", s.selected) .. (s.notes[date] and " · note" or " · new"),
		"  * diary note    Today: " .. os.date("%Y-%m-%d"),
		separator("Note preview"),
	})
	local preview_height = math.max(0, api.nvim_win_get_height(s.win) - 18)
	for i, line in ipairs(preview(date, preview_height)) do
		if i > preview_height then
			break
		end
		lines[#lines + 1] = "  " .. line:gsub("\t", "  "):gsub("%c", " ")
	end
	while #lines < 13 + preview_height do
		lines[#lines + 1] = ""
	end
	local footer_start = #lines
	vim.list_extend(lines, {
		separator("Controls"),
		"  hjkl/arrows: day/week   [ ]: month   { }: year",
		"  t: today   g: date   p/n: previous/next note",
		"  Enter: open   D: daily picker   q/Esc: close",
		"  Ctrl-s/v/t: open in split / vertical / tab",
	})
	vim.bo[s.buf].modifiable = true
	api.nvim_buf_set_lines(s.buf, 0, -1, false, lines)
	vim.bo[s.buf].modifiable = false
	api.nvim_buf_clear_namespace(s.buf, ns, 0, -1)
	for _, mark in ipairs(marks) do
		api.nvim_buf_set_extmark(s.buf, ns, mark[1], mark[2], {
			end_col = mark[2] + 3,
			hl_group = mark[3],
		})
	end
	api.nvim_buf_set_extmark(s.buf, ns, 0, 2, { end_col = #lines[1], hl_group = "Title" })
	api.nvim_buf_set_extmark(s.buf, ns, 12, 0, { end_col = #lines[13], hl_group = "Comment" })
	for row = footer_start, #lines - 1 do
		api.nvim_buf_set_extmark(s.buf, ns, row, 0, { end_col = #lines[row + 1], hl_group = "Comment" })
	end
	for i, keys in ipairs({
		{ "hjkl/arrows", "[ ]", "{ }" },
		{ "t", "g", "p/n" },
		{ "Enter", "D", "q/Esc" },
		{ "Ctrl-s/v/t" },
	}) do
		local row = footer_start + i
		local start = 1
		for _, key in ipairs(keys) do
			local first, last = lines[row + 1]:find(key .. ":", start, true)
			if first then
				api.nvim_buf_set_extmark(
					s.buf,
					ns,
					row,
					first - 1,
					{ end_col = last - 1, hl_group = "Special", priority = 110 }
				)
				start = last + 1
			end
		end
	end
	api.nvim_win_set_cursor(s.win, { selected_row, selected_col })
	-- Keep the month header visible even on a shorter terminal.
	api.nvim_win_call(s.win, function()
		vim.fn.winrestview({ topline = 1 })
	end)
end

local function open_note(s, layout)
	local date = date_of(s.selected)
	local origin = s.origin
	close()
	if api.nvim_win_is_valid(origin) then
		api.nvim_set_current_win(origin)
	end
	local ok, err = pcall(function()
		if layout then
			vim.cmd(layout)
		end
		require("mywiki").open_daily(date)
	end)
	if not ok then
		vim.notify("Calendar: " .. tostring(err), vim.log.levels.ERROR)
		M.open(date)
	end
end

function M.open(date)
	local selected = date and parse(date)
	if date and not selected then
		vim.notify("Calendar: use a valid YYYY-MM-DD date", vim.log.levels.WARN)
		return
	end
	if active and api.nvim_win_is_valid(active.win) then
		api.nvim_set_current_win(active.win)
		active.selected = selected or active.selected
		refresh(active)
		render(active)
		return
	end
	if vim.o.columns < 40 or vim.o.lines < 23 then
		vim.notify("Calendar needs at least 40 columns and 23 lines", vim.log.levels.WARN)
		return
	end
	local current = api.nvim_buf_get_name(0)
	local note_date = vim.fs.basename(current):match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")
	local s =
		{ origin = api.nvim_get_current_win(), selected = selected or parse(note_date) or parse(os.date("%Y-%m-%d")) }
	s.buf = api.nvim_create_buf(false, true)
	vim.bo[s.buf].bufhidden = "wipe"
	vim.bo[s.buf].filetype = "diarycalendar"
	s.win = api.nvim_open_win(s.buf, true, geometry())
	active = s
	vim.wo[s.win].wrap = false
	vim.wo[s.win].cursorline = false
	vim.wo[s.win].scrolloff = 0
	vim.wo[s.win].sidescrolloff = 0
	vim.wo[s.win].winfixbuf = true
	local function map(keys, action, desc)
		for _, key in ipairs(type(keys) == "table" and keys or { keys }) do
			vim.keymap.set("n", key, action, { buffer = s.buf, nowait = true, silent = true, desc = desc })
		end
	end
	for key, days in pairs({
		h = -1,
		l = 1,
		j = 7,
		k = -7,
		["<Left>"] = -1,
		["<Right>"] = 1,
		["<Down>"] = 7,
		["<Up>"] = -7,
	}) do
		map(key, function()
			s.selected = move_day(s.selected, days * vim.v.count1)
			render(s)
		end, "Move by day/week")
	end
	for key, months in pairs({ ["["] = -1, ["]"] = 1, ["{"] = -12, ["}"] = 12 }) do
		map(key, function()
			s.selected = move_month(s.selected, months * vim.v.count1)
			render(s)
		end, "Move by month/year")
	end
	for key, direction in pairs({ p = -1, n = 1 }) do
		map(key, function()
			refresh(s)
			local current_date = date_of(s.selected)
			local candidate
			for _, entry in ipairs(s.dates) do
				if direction == 1 and entry > current_date and parse(entry) then
					candidate = entry
					break
				elseif direction == -1 and entry < current_date and parse(entry) then
					candidate = entry
				end
			end
			if candidate then
				s.selected = parse(candidate)
			else
				vim.notify("Calendar: no " .. (direction == 1 and "later" or "earlier") .. " diary note")
			end
			render(s)
		end, "Jump to existing diary note")
	end
	map("t", function()
		s.selected = parse(os.date("%Y-%m-%d"))
		refresh(s)
		render(s)
	end, "Today")
	map("g", function()
		vim.ui.input({ prompt = "Diary date (YYYY-MM-DD): ", default = date_of(s.selected) }, function(input)
			if active ~= s or not input then
				return
			end
			local ts = parse(input)
			if ts then
				s.selected = ts
				render(s)
			else
				vim.notify("Calendar: use a valid YYYY-MM-DD date", vim.log.levels.WARN)
			end
		end)
	end, "Go to date")
	map("<CR>", function()
		open_note(s)
	end, "Open/create daily note")
	for key, layout in pairs({ ["<C-s>"] = "split", ["<C-v>"] = "vsplit", ["<C-t>"] = "tabnew" }) do
		map(key, function()
			open_note(s, layout)
		end, "Open daily note in " .. layout)
	end
	map("D", function()
		close()
		require("mywiki").dailies()
	end, "Daily note picker")
	map({ "q", "<Esc>" }, close, "Close calendar")
	api.nvim_create_autocmd("VimResized", {
		buffer = s.buf,
		callback = function()
			if active == s then
				if vim.o.columns < 40 or vim.o.lines < 23 then
					close()
					return
				end
				api.nvim_win_set_config(s.win, geometry())
				render(s)
			end
		end,
	})
	api.nvim_create_autocmd("BufWipeout", {
		buffer = s.buf,
		once = true,
		callback = function()
			if active == s then
				active = nil
			end
		end,
	})
	refresh(s)
	render(s)
end

function M.setup()
	vim.api.nvim_set_hl(0, "MyCalendarToday", { default = true, link = "DiagnosticWarn" })
	vim.api.nvim_set_hl(0, "MyCalendarNote", { default = true, link = "DiagnosticOk" })
	vim.api.nvim_set_hl(0, "MyCalendarSelected", { default = true, link = "Visual" })
	for _, name in ipairs({ "Calendar", "Cal" }) do
		api.nvim_create_user_command(name, function(opts)
			M.open(opts.args ~= "" and opts.args or nil)
		end, { nargs = "?", desc = "Diary calendar [YYYY-MM-DD]" })
	end
	vim.keymap.set("n", "<leader>wc", function()
		M.open()
	end, { desc = "Diary calendar" })
end

return M
