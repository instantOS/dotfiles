-- Diary calendar. All date arithmetic uses local noon and calendar fields,
-- rather than adding 86400 seconds across daylight-saving transitions.
local M = {}
local api = vim.api
local ns = api.nvim_create_namespace("mycalendar")
local month_height = 9
local day_grid_indent = 2
local day_cell_width = 5
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

local function geometry(title)
	-- The rounded border takes one cell on each side.
	local width = vim.o.columns - 2
	local height = vim.o.lines - vim.o.cmdheight - 2
	if width < 38 or height < 20 then
		return nil
	end
	return {
		relative = "editor",
		width = width,
		height = height,
		row = 0,
		col = 0,
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
	}
end

local bindings = {
	{ "h/l, ←/→", "Previous/next day" },
	{ "k/j, ↑/↓", "Previous/next week" },
	{ "[ / ]", "Previous/next month" },
	{ "{ / }", "Previous/next year" },
	{ "Ctrl-u/d", "Browse past/future" },
	{ "t", "Jump to today" },
	{ "g", "Go to date" },
	{ "p/n", "Previous/next note" },
	{ "Ctrl-y/e", "Preview up/down" },
	{ "Mouse wheel", "Scroll preview" },
	{ "Left click", "Select day" },
	{ "Enter", "Open/create note" },
	{ "Ctrl-s/v/t", "Split/vsplit/tab" },
	{ "D", "Daily note picker" },
	{ "q / Esc", "Close active popup" },
	{ "?", "Toggle this list" },
}

local function help_config(s)
	local parent_width = api.nvim_win_get_width(s.win)
	local width = math.min(48, parent_width - 2)
	return {
		relative = "win",
		win = s.win,
		width = width,
		height = #bindings,
		row = math.floor((api.nvim_win_get_height(s.win) - #bindings - 2) / 2),
		col = math.floor((parent_width - width - 2) / 2),
		style = "minimal",
		border = "rounded",
		title = " Calendar bindings ",
		title_pos = "center",
		zindex = 60,
	}
end

local function close_help(s)
	local win = s.help_win
	s.help_win = nil
	if win and api.nvim_win_is_valid(win) then
		api.nvim_win_close(win, true)
	end
end

local function toggle_help(s)
	if s.help_win and api.nvim_win_is_valid(s.help_win) then
		close_help(s)
		return
	end
	local buf = api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	local lines = {}
	for _, binding in ipairs(bindings) do
		local gap = string.rep(" ", 13 - vim.fn.strdisplaywidth(binding[1]))
		lines[#lines + 1] = " " .. binding[1] .. gap .. binding[2]
	end
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	for row, binding in ipairs(bindings) do
		api.nvim_buf_set_extmark(buf, ns, row - 1, 1, { end_col = 1 + #binding[1], hl_group = "Special" })
	end
	for _, key in ipairs({ "?", "q", "<Esc>" }) do
		vim.keymap.set("n", key, function()
			close_help(s)
		end, { buffer = buf, nowait = true, silent = true, desc = "Close calendar bindings" })
	end
	s.help_win = api.nvim_open_win(buf, true, help_config(s))
	vim.wo[s.help_win].wrap = false
end

local function close_preview(s)
	if s.preview_win and api.nvim_win_is_valid(s.preview_win) then
		api.nvim_win_close(s.preview_win, true)
	end
	s.preview_win, s.preview_date = nil, nil
end

local function close()
	local s = active
	active = nil
	if not s then
		return
	end
	close_help(s)
	close_preview(s)
	if api.nvim_win_is_valid(s.win) then
		api.nvim_win_close(s.win, true)
	end
	if api.nvim_buf_is_valid(s.buf) then
		api.nvim_buf_delete(s.buf, { force = true })
	end
end

local function refresh(s)
	local wiki = require("mywiki")
	local dir = vim.fs.dirname(wiki.daily_path("2000-01-01"))
	local stat = vim.uv.fs_stat(dir)
	local previous = s.diary_stat
	-- Reuse the filename index while the same directory is unchanged.
	if
		not stat
		or not previous
		or s.diary_dir ~= dir
		or stat.dev ~= previous.dev
		or stat.ino ~= previous.ino
		or stat.mtime.sec ~= previous.mtime.sec
		or stat.mtime.nsec ~= previous.mtime.nsec
	then
		s.disk_dates = wiki.daily_dates()
		s.diary_dir, s.diary_stat = dir, stat
	end
	s.dates = s.disk_dates
	s.notes = {}
	for _, date in ipairs(s.dates) do
		s.notes[date] = true
	end
	-- Include unsaved daily notes in the markers and preview.
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(buf) then
			local path = api.nvim_buf_get_name(buf)
			local date = vim.fs.basename(path):match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")
			if date and vim.fs.dirname(path) == dir then
				if not s.notes[date] then
					if s.dates == s.disk_dates then
						s.dates = vim.list_extend({}, s.disk_dates)
					end
					s.dates[#s.dates + 1] = date
				end
				s.notes[date] = true
			end
		end
	end
	if s.dates ~= s.disk_dates then
		table.sort(s.dates)
	end
end

local function read_preview(date)
	local path = require("mywiki").daily_path(date)
	local buf = vim.fn.bufnr(path)
	if buf >= 0 and api.nvim_buf_is_loaded(buf) then
		return api.nvim_buf_get_lines(buf, 0, -1, false)
	end
	local ok, lines = pcall(vim.fn.readfile, path)
	return ok and lines or nil
end

local function highlight_preview(buf, lines)
	-- Use bounded regex highlighting for large or unusually long-line notes.
	-- Tree-sitter queries on these inputs can make preview redraws stall.
	local size = 0
	for _, line in ipairs(lines) do
		size = size + #line + 1
		if size > 512 * 1024 or #line > 16 * 1024 then
			vim.bo[buf].synmaxcol = 3000
			vim.bo[buf].syntax = "markdown"
			return
		end
	end
	if not pcall(vim.treesitter.start, buf, "markdown") then
		vim.bo[buf].syntax = "markdown"
	end
end

local function show_preview(s, date, row, col, width, height, reload)
	if height < 1 then
		close_preview(s)
		return
	end
	local config = {
		relative = "win",
		win = s.win,
		row = row,
		col = col,
		width = width,
		height = height,
		border = "none",
		style = "minimal",
		focusable = false,
		zindex = 51,
	}
	local visible = s.preview_win and api.nvim_win_is_valid(s.preview_win)
	if visible then
		api.nvim_win_set_config(s.preview_win, config)
		if s.preview_date == date and not reload then
			return
		end
	end
	s.preview_date = date
	local buf = api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	if visible then
		api.nvim_win_set_buf(s.preview_win, buf)
	else
		s.preview_win = api.nvim_open_win(buf, false, config)
		local opts = vim.wo[s.preview_win]
		opts.wrap = true
		opts.linebreak = true
		opts.smoothscroll = true
		opts.foldenable = false
		opts.scrolloff = 0
		opts.conceallevel = 0
	end
	local win = s.preview_win
	-- Skip notes passed over while navigating.
	vim.defer_fn(function()
		if active ~= s or not api.nvim_win_is_valid(win) or api.nvim_win_get_buf(win) ~= buf then
			return
		end
		local lines = read_preview(date)
		vim.bo[buf].modifiable = true
		api.nvim_buf_set_lines(buf, 0, -1, false, lines or { "No note yet. Press Enter to start this day." })
		vim.bo[buf].modifiable = false
		if lines then
			highlight_preview(buf, lines)
		end
	end, 75)
end

local function render_month(s, lines, marks, month, date, today)
	local year = math.floor(month / 12)
	local month_of_year = month % 12 + 1
	local start = stamp(year, month_of_year, 1)
	local first = os.date("*t", start)
	local offset = (first.wday + 5) % 7 -- Monday first.
	local days = os.date("*t", stamp(year, month_of_year + 1, 0)).day
	local title = "  " .. os.date("%B %Y", start)
	marks[#marks + 1] = { #lines, 2, #title, "Title" }
	lines[#lines + 1] = title
	lines[#lines + 1] = "  Mo   Tu   We   Th   Fr   Sa   Su"
	local cursor
	for week = 0, 5 do
		local cells = {}
		local week_dates = {}
		s.day_rows[#lines + 1] = week_dates
		for weekday = 0, 6 do
			local day = week * 7 + weekday - offset + 1
			local cell = "    "
			if day >= 1 and day <= days then
				local key = ("%04d-%02d-%02d"):format(year, month_of_year, day)
				week_dates[weekday + 1] = key
				cell = ("%2d%s "):format(day, s.notes[key] and "*" or " ")
				local col = day_grid_indent + weekday * day_cell_width
				local hl = key == today and "MyCalendarToday" or s.notes[key] and "MyCalendarNote" or "NormalFloat"
				if key == date then
					hl = "MyCalendarSelected"
					cursor = { #lines + 1, col }
				end
				marks[#marks + 1] = { #lines, col, col + 3, hl }
			end
			cells[#cells + 1] = cell
		end
		lines[#lines + 1] = string.rep(" ", day_grid_indent) .. table.concat(cells, " ")
	end
	lines[#lines + 1] = ""
	return cursor
end

local function separator(label, width)
	local prefix = "  ── " .. label .. " "
	local cells = math.max(0, width - vim.fn.strdisplaywidth(prefix) - 2)
	return prefix .. string.rep("─", math.floor(cells / vim.fn.strdisplaywidth("─")))
end

local function footer_hint(width)
	local hints = { "hjkl Move", "Enter Open", "? Help", "q Close" }
	local text = table.concat(hints, "  ·  ")
	if vim.fn.strdisplaywidth(text) > width then
		text = table.concat(hints, "  ")
	end
	return string.rep(" ", math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))) .. text
end

local function render(s, reload_preview)
	if active ~= s or not api.nvim_win_is_valid(s.win) then
		return
	end
	local selected = os.date("*t", s.selected)
	local selected_month = selected.year * 12 + selected.month - 1
	local date = date_of(s.selected)
	local today = os.date("%Y-%m-%d")
	local width = api.nvim_win_get_width(s.win)
	local body_height = api.nvim_win_get_height(s.win) - 1
	local status = "  " .. date .. " · " .. os.date("%A", s.selected) .. (s.notes[date] and " · note" or " · new")
	local legend = "  * diary note    Today: " .. today
	local left_width = math.max(38, vim.fn.strdisplaywidth(status) + 2, vim.fn.strdisplaywidth(legend) + 2)
	local side_by_side = width - left_width >= 38
	local month_count = side_by_side and math.max(1, math.floor((body_height - 2) / month_height)) or 1
	-- Keep the visible months steady until the selection crosses an edge.
	s.first_month =
		math.max(selected_month - month_count + 1, math.min(s.first_month or selected_month, selected_month))
	s.day_rows = {}
	local lines, marks = {}, {}
	local cursor
	for month = s.first_month, s.first_month + month_count - 1 do
		cursor = render_month(s, lines, marks, month, date, today) or cursor
	end
	lines[#lines + 1] = status
	lines[#lines + 1] = legend
	for _, line in ipairs(lines) do
		left_width = math.max(left_width, vim.fn.strdisplaywidth(line) + 2)
	end
	local preview_heading = s.preview_icon .. "Note preview"
	local preview_row, preview_col
	if side_by_side then
		local divider = "│  "
		preview_row = 2
		preview_col = left_width + vim.fn.strdisplaywidth(divider)
		for row = 1, body_height do
			local left = lines[row] or ""
			left = left .. string.rep(" ", left_width - vim.fn.strdisplaywidth(left))
			lines[row] = left .. divider
			marks[#marks + 1] = { row - 1, #left, #left + #"│", "Comment" }
			if row == 1 then
				lines[row] = lines[row] .. preview_heading
				marks[#marks + 1] = { 0, #left + #divider, #lines[row], "Title" }
			end
		end
	else
		local heading = separator(preview_heading, width)
		marks[#marks + 1] = { #lines, 0, #heading, "Comment" }
		lines[#lines + 1] = heading
		preview_row, preview_col = #lines, 2
		while #lines < body_height do
			lines[#lines + 1] = ""
		end
	end
	local hint = footer_hint(width)
	marks[#marks + 1] = { #lines, 0, #hint, "Comment" }
	lines[#lines + 1] = hint
	vim.bo[s.buf].modifiable = true
	api.nvim_buf_set_lines(s.buf, 0, -1, false, lines)
	vim.bo[s.buf].modifiable = false
	api.nvim_buf_clear_namespace(s.buf, ns, 0, -1)
	for _, mark in ipairs(marks) do
		api.nvim_buf_set_extmark(s.buf, ns, mark[1], mark[2], {
			end_col = mark[3],
			hl_group = mark[4],
		})
	end
	api.nvim_win_set_cursor(s.win, cursor)
	-- Keep the month header visible even on a shorter terminal.
	api.nvim_win_call(s.win, function()
		vim.fn.winrestview({ topline = 1 })
	end)
	show_preview(s, date, preview_row, preview_col, width - preview_col - 2, body_height - preview_row, reload_preview)
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
		close_help(active)
		api.nvim_set_current_win(active.win)
		active.selected = selected or active.selected
		refresh(active)
		render(active, true)
		return
	end
	local title, preview_icon = " Diary calendar ", ""
	local icons = _G.MiniIcons
	if icons and icons.config.style == "glyph" then
		title = "   Diary calendar "
		preview_icon = icons.get("filetype", "markdown") .. " "
	end
	local config = geometry(title)
	if not config then
		vim.notify("Calendar needs at least 40 columns and 22 lines above the command line", vim.log.levels.WARN)
		return
	end
	local current = api.nvim_buf_get_name(0)
	local note_date = vim.fs.basename(current):match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")
	local s = {
		origin = api.nvim_get_current_win(),
		selected = selected or parse(note_date) or parse(os.date("%Y-%m-%d")),
		preview_icon = preview_icon,
	}
	s.buf = api.nvim_create_buf(false, true)
	vim.bo[s.buf].bufhidden = "wipe"
	vim.bo[s.buf].filetype = "diarycalendar"
	s.win = api.nvim_open_win(s.buf, true, config)
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
	map("<LeftMouse>", function()
		local mouse = vim.fn.getmousepos()
		if mouse.winid ~= s.win then
			api.nvim_feedkeys(vim.keycode("<LeftMouse>"), "n", false)
			return
		end
		local col = mouse.column - 1 - day_grid_indent
		local week = s.day_rows[mouse.line]
		local date = week and week[math.floor(col / day_cell_width) + 1]
		if date and date ~= date_of(s.selected) then
			s.selected = parse(date)
			render(s)
		end
	end, "Select calendar day")
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
	for key, direction in pairs({ ["<C-u>"] = -1, ["<C-d>"] = 1 }) do
		map(key, function()
			local months = direction * vim.v.count1
			s.first_month = s.first_month + months
			s.selected = move_month(s.selected, months)
			render(s)
		end, "Scroll by month")
	end
	for key, scroll in pairs({
		["<C-y>"] = "<C-y>",
		["<C-e>"] = "<C-e>",
		["<ScrollWheelUp>"] = "<C-y>",
		["<ScrollWheelDown>"] = "<C-e>",
	}) do
		map(key, function()
			if not s.preview_win or not api.nvim_win_is_valid(s.preview_win) then
				return
			end
			local mouse = key:find("Wheel", 1, true)
			if mouse and vim.fn.getmousepos().winid ~= s.win then
				return
			end
			local keys = (vim.v.count1 * (mouse and 3 or 1)) .. vim.keycode(scroll)
			api.nvim_win_call(s.preview_win, function()
				vim.cmd.normal({ args = { keys }, bang = true })
			end)
		end, "Scroll note preview")
	end
	for key, direction in pairs({ p = -1, n = 1 }) do
		map(key, function()
			refresh(s)
			local current_date = date_of(s.selected)
			local candidate
			local first = direction == 1 and 1 or #s.dates
			local last = direction == 1 and #s.dates or 1
			for i = first, last, direction do
				local entry = s.dates[i]
				if (direction == 1 and entry > current_date) or (direction == -1 and entry < current_date) then
					candidate = parse(entry)
					if candidate then
						break
					end
				end
			end
			if candidate then
				s.selected = candidate
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
	map("?", function()
		toggle_help(s)
	end, "Show calendar bindings")
	map({ "q", "<Esc>" }, close, "Close calendar")
	local resize = api.nvim_create_autocmd("VimResized", {
		callback = function()
			if active == s then
				local resized = geometry(title)
				if not resized then
					close()
					return
				end
				api.nvim_win_set_config(s.win, resized)
				render(s)
				if s.help_win and api.nvim_win_is_valid(s.help_win) then
					api.nvim_win_set_config(s.help_win, help_config(s))
				end
			end
		end,
	})
	api.nvim_create_autocmd("BufWipeout", {
		buffer = s.buf,
		once = true,
		callback = function()
			api.nvim_del_autocmd(resize)
			close_help(s)
			close_preview(s)
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
