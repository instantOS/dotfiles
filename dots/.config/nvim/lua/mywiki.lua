-- Wiki helpers replacing the Obsidian keymaps we used before.
-- The wiki is a plain folder of markdown notes; pickers use fzf-lua.

local M = {}

local function wiki_root()
	local root = vim.g.mywiki_root
	if type(root) == "string" and root ~= "" then
		return (vim.fn.expand(root):gsub("/+$", ""))
	end
	return (vim.fn.expand("~/wiki/vimwiki"):gsub("/+$", ""))
end

local function diary_dir()
	return wiki_root() .. "/diary"
end

local function has_letter(tag)
	for i = 1, #tag do
		local b = tag:byte(i)
		if b >= 128 or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) then
			return true
		end
	end
	return false
end

local function is_hex_color(tag)
	return tag:match("^%x%x%x$")
		or tag:match("^%x%x%x%x$")
		or tag:match("^%x%x%x%x%x%x$")
		or tag:match("^%x%x%x%x%x%x%x%x$")
end

local function is_tag_char(c)
	if c == "" then
		return false
	end
	return c:byte() >= 128 or c:match("[%w_/%-]") ~= nil
end

local function valid_tag(tag)
	return tag ~= ""
		and has_letter(tag)
		and not is_hex_color(tag)
		and tag:sub(1, 1) ~= "/"
		and tag:sub(-1) ~= "/"
		and not tag:find("//", 1, true)
end

---Find inline tags in a line. Tags must be at the start of the line or
---preceded by whitespace, which also rules out URLs and link anchors.
local function inline_tags(line)
	local tags = {}
	local init = 1
	while true do
		local i = line:find("#", init, true)
		if not i then
			break
		end
		local prev = i > 1 and line:sub(i - 1, i - 1) or ""
		if (i == 1 or prev:match("%s")) and is_tag_char(line:sub(i + 1, i + 1)) then
			local j = i + 1
			while j <= #line and is_tag_char(line:sub(j, j)) do
				j = j + 1
			end
			local tag = line:sub(i + 1, j - 1)
			if valid_tag(tag) then
				tags[#tags + 1] = { tag = tag:lower(), start = i, stop = j - 1 }
			end
			init = j
		else
			init = i + 1
		end
	end
	return tags
end

---Replace inline code spans with NUL bytes so their contents are not
---mistaken for tags. The length is preserved for column positions.
local function blank_inline_code(line)
	local out = {}
	local i, n = 1, #line
	while i <= n do
		if line:sub(i, i) == "`" then
			local j = i
			while j <= n and line:sub(j, j) == "`" do
				j = j + 1
			end
			local close_start, close_end = line:find(string.rep("`", j - i), j, true)
			if close_start then
				out[#out + 1] = string.rep("\0", close_end - i + 1)
				i = close_end + 1
			else
				out[#out + 1] = line:sub(i)
				break
			end
		else
			out[#out + 1] = line:sub(i, i)
			i = i + 1
		end
	end
	return table.concat(out)
end

local function is_fence(line)
	return line:match("^%s*```") ~= nil or line:match("^%s*~~~") ~= nil
end

local function frontmatter_end(lines)
	if not lines[1] or not lines[1]:match("^%-%-%-%s*$") then
		return 0
	end
	for i = 2, #lines do
		if lines[i]:match("^%-%-%-%s*$") or lines[i]:match("^%.%.%.%s*$") then
			return i
		end
	end
	return 0
end

local function trim_span(line, start_col, end_col)
	local s = line:sub(start_col, end_col)
	local leading = #(s:match("^%s*") or "")
	local trailing = #(s:match("%s*$") or "")
	local text = s:sub(leading + 1, #s - trailing)
	return text, start_col + leading, start_col + leading + #text - 1
end

---Parse one scalar YAML tag value, stripping quotes and a leading `#`.
local function clean_scalar(line, start_col, end_col)
	local text, s, e = trim_span(line, start_col, end_col)
	if text == "" then
		return nil
	end
	local quote = text:sub(1, 1)
	if (quote == '"' or quote == "'") and text:sub(-1) == quote then
		text = text:sub(2, -2)
		s = s + 1
		e = e - 1
	end
	if text:sub(1, 1) == "#" then
		text = text:sub(2)
	end
	if text == "" or text:find("%s") or not valid_tag(text) then
		return nil
	end
	for i = 1, #text do
		if not is_tag_char(text:sub(i, i)) then
			return nil
		end
	end
	return text:lower(), s, e
end

---Extract tags from YAML frontmatter (`tags: [a, b]` or a `tags:` list).
local function frontmatter_tags(lines, last_line)
	local out = {}
	local in_tags = false
	for i = 2, last_line - 1 do
		local line = lines[i]
		local indent, key = line:match("^(%s*)([%w_-]+)%s*:")
		if key then
			key = key:lower()
			if key == "tags" or key == "tag" then
				in_tags = true
				local colon = line:find(":", #indent + 1, true)
				local open = line:find("[", colon + 1, true)
				local close = open and line:find("]", open + 1, true)
				if open and close then
					local pos = open + 1
					while pos < close do
						local comma = line:find(",", pos, true)
						local stop = (comma and comma <= close) and (comma - 1) or (close - 1)
						local tag, s, e = clean_scalar(line, pos, stop)
						if tag then
							out[#out + 1] = { tag = tag, lnum = i, start = s, stop = e, source = "frontmatter" }
						end
						if not comma or comma > close then
							break
						end
						pos = comma + 1
					end
				else
					local tag, s, e = clean_scalar(line, colon + 1, #line)
					if tag then
						out[#out + 1] = { tag = tag, lnum = i, start = s, stop = e, source = "frontmatter" }
					end
				end
			else
				in_tags = false
			end
		elseif in_tags then
			local _, _, item_start, item = line:find("^%s*%-%s+()(.+)$")
			if item then
				local tag, s, e = clean_scalar(line, item_start, #line)
				if tag then
					out[#out + 1] = { tag = tag, lnum = i, start = s, stop = e, source = "frontmatter" }
				end
			end
		end
	end
	return out
end

---Extract all tag occurrences from a markdown buffer/file.
local function lines_tags(lines, file)
	local out = {}
	local fm_end = frontmatter_end(lines)

	for _, tag in ipairs(frontmatter_tags(lines, fm_end)) do
		tag.file = file
		tag.text = lines[tag.lnum]
		out[#out + 1] = tag
	end

	local in_fence = false
	for i = fm_end + 1, #lines do
		local line = lines[i]
		if is_fence(line) then
			in_fence = not in_fence
		elseif not in_fence then
			for _, tag in ipairs(inline_tags(blank_inline_code(line))) do
				tag.lnum = i
				tag.file = file
				tag.source = "inline"
				tag.text = line
				out[#out + 1] = tag
			end
		end
	end
	return out
end

local function build_tag_index()
	local index = {}
	local root = wiki_root()
	local prefix = root .. "/"
	for _, file in ipairs(vim.fn.globpath(root, "**/*.md", false, true)) do
		local rel = file:sub(#prefix + 1)
		if not rel:match("^%.[^/]+/") and not rel:match("/%.[^/]+/") then
			local ok, lines = pcall(vim.fn.readfile, file)
			if ok then
				for _, tag in ipairs(lines_tags(lines, file)) do
					local entry = index[tag.tag]
					if not entry then
						entry = { tag = tag.tag, refs = {}, files = {} }
						index[tag.tag] = entry
					end
					entry.refs[#entry.refs + 1] = tag
					entry.files[file] = true
				end
			end
		end
	end
	return index
end

---Return the tag name under the cursor, if any.
function M.tag_at_cursor()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	col = col + 1
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local fm_end = frontmatter_end(lines)

	if row <= fm_end then
		for _, tag in ipairs(frontmatter_tags(lines, fm_end)) do
			if tag.lnum == row and col >= tag.start and col <= tag.stop then
				return tag.tag
			end
		end
		return
	end

	-- Only the current line is parsed; find whether it is inside a fence
	-- without running the full tag extraction over the whole buffer.
	local in_fence = false
	for i = fm_end + 1, row - 1 do
		if is_fence(lines[i]) then
			in_fence = not in_fence
		end
	end
	if in_fence or is_fence(lines[row]) then
		return
	end

	for _, tag in ipairs(inline_tags(blank_inline_code(lines[row]))) do
		if col >= tag.start and col <= tag.stop then
			return tag.tag
		end
	end
end

---Show all occurrences of a tag.
---@param tag string
---@param index? table<string, { tag: string, refs: table[], files: table<string, true> }>
function M.tag_references(tag, index)
	tag = tag:gsub("^#", ""):lower()
	index = index or build_tag_index()
	local entry = index[tag]
	if not entry then
		vim.notify("No references to #" .. tag, vim.log.levels.INFO)
		return
	end

	table.sort(entry.refs, function(a, b)
		if a.file ~= b.file then
			return a.file < b.file
		end
		if a.lnum ~= b.lnum then
			return a.lnum < b.lnum
		end
		return a.start < b.start
	end)

	local fzf = require("fzf-lua")
	local root = wiki_root()
	local prefix = root .. "/"
	local entries = {}
	for _, ref in ipairs(entry.refs) do
		local file = ref.file
		if file:sub(1, #prefix) == prefix then
			file = file:sub(#prefix + 1)
		end
		local text = ref.text:gsub("\t", "  "):gsub("\r", "")
		entries[#entries + 1] = ("%s:%d:%d:%s"):format(file, ref.lnum, ref.start, text)
	end

	fzf.fzf_exec(entries, {
		cwd = root,
		prompt = ("#%s> "):format(tag),
		winopts = { title = (" #%s (%d) "):format(tag, #entries) },
		previewer = "builtin",
		fzf_opts = { ["--no-sort"] = true },
		actions = {
			["enter"] = fzf.actions.file_edit_or_qf,
			["ctrl-s"] = fzf.actions.file_split,
			["ctrl-v"] = fzf.actions.file_vsplit,
			["ctrl-t"] = fzf.actions.file_tabedit,
		},
	})
end

---List all tags in the wiki.
function M.tags()
	local index = build_tag_index()
	local tags = vim.tbl_keys(index)
	table.sort(tags)

	local width = 0
	for _, tag in ipairs(tags) do
		width = math.max(width, #tag)
	end

	local fzf = require("fzf-lua")
	local entries = {}
	for _, tag in ipairs(tags) do
		local entry = index[tag]
		local count = vim.tbl_count(entry.files)
		local notes = ("%d note%s"):format(count, count == 1 and "" or "s")
		entries[#entries + 1] = ("#%s%s%s\t%s"):format(
			tag,
			string.rep(" ", width - #tag + 2),
			fzf.utils.ansi_codes.grey(notes),
			tag
		)
	end

	fzf.fzf_exec(entries, {
		prompt = "Tags> ",
		winopts = { title = (" Wiki tags (%d) "):format(#entries) },
		fzf_opts = {
			["--delimiter"] = "\t",
			["--with-nth"] = "1",
			["--no-sort"] = true,
		},
		actions = {
			["enter"] = function(selected)
				local tag = selected[1] and selected[1]:match("\t(.+)$")
				if tag then
					M.tag_references(tag, index)
				end
			end,
		},
	})
end

-- Link handling ------------------------------------------------------------

local URL_PATTERN = "[Hh][Tt][Tt][Pp][Ss]?://"
local FILE_URL_PATTERN = "[Ff][Ii][Ll][Ee]://"
local URL_STOP_CHARS = {
	["<"] = true,
	[">"] = true,
	['"'] = true,
	["'"] = true,
	["`"] = true,
	["|"] = true,
	["]"] = true,
	["}"] = true,
}

local function is_supported_url(url)
	return url:match("^" .. URL_PATTERN) ~= nil or url:match("^" .. FILE_URL_PATTERN) ~= nil
end

---Remove link decorations and sentence punctuation from a URL.
local function clean_url(url)
	url = vim.trim(url)
	url = url:gsub("^<", ""):gsub(">$", "")
	return (url:gsub("[%.,;:!?]+$", ""))
end

local function percent_decode(text)
	return (text:gsub("%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end))
end

local function is_link_node(node)
	local kind = node:type()
	return kind == "inline_link"
		or kind == "image"
		or kind == "shortcut_link"
		or kind == "full_reference_link"
		or kind == "collapsed_reference_link"
end

---Find a link at the cursor with treesitter. This handles cursor positions on
---the link text as well as on its destination. The boolean return value says
---whether the cursor is inside a link at all, so that an unsupported link
---destination (for example a regular wiki note link) is left to Mkdnflow.
local function treesitter_link_at_cursor(row, col)
	local ok, node = pcall(vim.treesitter.get_node, {
		bufnr = 0,
		pos = { row - 1, col },
		ignore_injections = false,
	})
	if not ok or not node then
		return nil, false, false
	end

	-- Do not turn URLs in code spans/blocks or YAML frontmatter into links.
	local code_types = {
		code_span = true,
		fenced_code_block = true,
		indented_code_block = true,
		code_fence_content = true,
		minus_metadata = true,
		plus_metadata = true,
	}
	local in_code = false
	local parent = node
	while parent do
		if code_types[parent:type()] then
			in_code = true
			break
		end
		parent = parent:parent()
	end

	local kind = node:type()
	if kind == "link_destination" or kind == "uri_autolink" then
		return clean_url(vim.treesitter.get_node_text(node, 0)), true, in_code
	end

	parent = node
	while parent do
		if is_link_node(parent) then
			-- Inline links and images have the destination as a direct child.
			for child in parent:iter_children() do
				if child:type() == "link_destination" then
					return clean_url(vim.treesitter.get_node_text(child, 0)), true, in_code
				end
			end

			-- Vimwiki links are parsed as shortcut links: [[url|title]]. The
			-- parser often gives us only the inner [url|title] part.
			if parent:type() == "shortcut_link" then
				local raw = vim.treesitter.get_node_text(parent, 0)
				local inner = raw:match("^%[%[(.*)%]%]$") or raw:match("^%[(.*)%]$")
				if inner then
					local url = clean_url(inner:match("^([^|]+)") or inner)
					if is_supported_url(url) then
						return url, true, in_code
					end
				end
			end
			return nil, true, in_code
		end
		if parent:type() == "inline" or parent:type() == "section" or parent:type() == "document" then
			break
		end
		parent = parent:parent()
	end
	return nil, false, in_code
end

local function next_url_start(line, init)
	local http = line:find(URL_PATTERN, init)
	local file = line:find(FILE_URL_PATTERN, init)
	if http and file then
		return math.min(http, file)
	end
	return http or file
end

---Find a bare URL under the cursor. `col` is a 1-based byte column.
local function bare_url_at_cursor(line, col)
	local init = 1
	while true do
		local start = next_url_start(line, init)
		if not start then
			return nil
		end

		local i = start
		local depth = 0
		while i <= #line do
			local char = line:sub(i, i)
			if char:match("%s") then
				break
			elseif char == "(" then
				depth = depth + 1
			elseif char == ")" then
				if depth == 0 then
					break
				end
				depth = depth - 1
			elseif URL_STOP_CHARS[char] then
				break
			end
			i = i + 1
		end

		local url = clean_url(line:sub(start, i - 1))
		if url ~= "" and col >= start and col <= start + #url - 1 then
			return url
		end
		init = start + 1
	end
end

---Return the supported URL under the cursor, if any.
---@return string|nil
function M.url_at_cursor()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	-- Cheap path for the overwhelmingly common case: Enter on a line without
	-- any supported URL never needs a treesitter lookup or buffer scan.
	if not line:find(URL_PATTERN, 1) and not line:find(FILE_URL_PATTERN, 1) then
		return nil
	end

	local ok, ts_url, ts_in_link, ts_in_code = pcall(treesitter_link_at_cursor, row, col)
	if ok and ts_in_code then
		return nil
	end
	if ok then
		if ts_url and is_supported_url(ts_url) then
			return ts_url
		end
		if ts_in_link then
			-- The cursor is on a real link, but not a URL link. Let Mkdnflow
			-- follow it instead of mistaking URL text inside the link for one.
			return nil
		end
	end

	local url = bare_url_at_cursor(line, col + 1)
	if url and is_supported_url(url) then
		return url
	end
end

---Parse a file:// URL. Returns the local path and an optional fragment.
local function file_url_target(url)
	local rest = url:match("^" .. FILE_URL_PATTERN .. "(.*)$")
	if not rest then
		return nil, "not a file URL"
	end

	local fragment
	local hash = rest:find("#", 1, true)
	if hash then
		fragment = rest:sub(hash + 1)
		rest = rest:sub(1, hash - 1)
	end
	local query = rest:find("?", 1, true)
	if query then
		rest = rest:sub(1, query - 1)
	end

	-- file:///path has an empty authority; file://localhost/path is local too.
	if rest:sub(1, 1) ~= "/" then
		local authority, path = rest:match("^([^/]*)(/.*)$")
		if not authority then
			return nil, "invalid file URL"
		end
		if authority ~= "" and authority:lower() ~= "localhost" then
			return nil, "remote file URLs are not supported"
		end
		rest = path
	end

	local path = percent_decode(rest)
	if path == "" then
		return nil, "empty file URL path"
	end
	if path:sub(1, 1) ~= "/" then
		local current = vim.api.nvim_buf_get_name(0)
		local base = current ~= "" and vim.fs.dirname(current) or vim.fn.getcwd()
		path = vim.fs.joinpath(base, path)
	end
	return vim.fs.normalize(path), fragment
end

---Get the line number from fragments such as #L47, #L47-L170 or #line=47.
local function fragment_line(fragment)
	if not fragment or fragment == "" then
		return nil
	end
	fragment = percent_decode(fragment)
	local start = fragment:match("^[Ll](%d+)") or fragment:match("^[Ll][Ii][Nn][Ee]=(%d+)") or fragment:match("^(%d+)")
	return start and tonumber(start) or nil
end

---Open a file:// URL in the current window, honoring #Lnn line anchors.
function M.open_file_url(url)
	local path, fragment = file_url_target(url)
	if not path then
		vim.notify("Wiki: " .. (fragment or "invalid file URL"), vim.log.levels.ERROR)
		return
	end

	local stat = vim.uv.fs_stat(path)
	if not stat then
		vim.notify("Wiki: file not found: " .. path, vim.log.levels.ERROR)
		return
	end
	if stat.type == "directory" then
		vim.notify("Wiki: not a file: " .. path, vim.log.levels.ERROR)
		return
	end

	local current = vim.api.nvim_buf_get_name(0)
	if current == "" or vim.fs.normalize(current) ~= path then
		vim.cmd.edit(vim.fn.fnameescape(path))
	end

	local line = fragment_line(fragment)
	if line then
		line = math.max(1, math.min(line, vim.api.nvim_buf_line_count(0)))
		vim.api.nvim_win_set_cursor(0, { line, 0 })
		vim.cmd("normal! zz")
	end
end

---Open a supported URL. http(s) URLs go to the system handler; file:// URLs
---are opened as buffers so their line anchors work.
---@param url string
function M.open_url(url)
	if url:match("^" .. FILE_URL_PATTERN) then
		M.open_file_url(url)
		return
	end

	local ok, result, err = pcall(vim.ui.open, url)
	if not ok then
		vim.notify("Wiki: could not open link: " .. tostring(result), vim.log.levels.ERROR)
	elseif err then
		vim.notify("Wiki: could not open link: " .. err, vim.log.levels.ERROR)
	end
end

---Open the URL under the cursor. Returns true when a link was handled, so the
---Enter mapping can leave normal Enter behavior untouched otherwise.
---@return boolean
function M.open_url_at_cursor()
	local url = M.url_at_cursor()
	if not url then
		return false
	end
	M.open_url(url)
	return true
end

---Open (and create, if needed) the daily note for a date.
---@param date? string Date in YYYY-MM-DD format, defaults to today.
function M.open_daily(date)
	date = date or os.date("%Y-%m-%d")
	local dir = diary_dir()
	vim.fn.mkdir(dir, "p")
	vim.cmd.edit(vim.fn.fnameescape(M.daily_path(date)))
end

---Shared by the daily picker and calendar; respects g:mywiki_root.
function M.daily_path(date)
	return diary_dir() .. "/" .. date .. ".md"
end

function M.daily_dates()
	local dates = {}
	if vim.fn.isdirectory(diary_dir()) == 0 then
		return dates
	end
	for name, kind in vim.fs.dir(diary_dir()) do
		local date = name:match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")
		if date and (kind == "file" or kind == "link") then
			dates[#dates + 1] = date
		end
	end
	table.sort(dates)
	return dates
end

---Fuzzy-find a note in the wiki.
function M.quick_switch()
	require("fzf-lua").files({
		cwd = wiki_root(),
		hidden = false,
		-- Keep the preview visible while typing, but skip treesitter syntax
		-- highlighting (the expensive part). File contents are still shown as
		-- plain text, so typing never freezes even on huge/long-line notes.
		-- (Must be passed via `previewer`, since top-level `syntax` is not
		-- merged into the previewer opts.)
		previewer = { syntax = false },
		rg_opts = [[--color=never --files -g "*.md" -g "!.git"]],
		fd_opts = [[--color=never --type f --type l --exclude .git --exclude .jj --extension md]],
		find_opts = [[-type f -name '*.md' ! -path '*/.git/*' ! -path '*/.jj/*']],
		prompt = "Wiki notes> ",
		winopts = { title = " Wiki notes " },
	})
end

---Search the text of all wiki notes.
function M.search()
	require("fzf-lua").live_grep({
		cwd = wiki_root(),
		hidden = false,
		rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g "*.md" -e]],
		grep_opts = [[--perl-regexp --binary-files=without-match --line-number --recursive --color=always --include="*.md" -e]],
		prompt = "Search wiki> ",
		winopts = { title = " Search wiki " },
	})
end

---Pick a daily note from the previous/next 14 days.
function M.dailies()
	local now = os.date("*t")
	now.hour, now.min, now.sec = 12, 0, 0

	local fzf = require("fzf-lua")
	local entries = {}
	local today_index = 1
	for offset = 14, -14, -1 do
		local ts = os.time({ year = now.year, month = now.month, day = now.day + offset, hour = 12 })
		local date = os.date("%Y-%m-%d", ts)
		local path = M.daily_path(date)
		local exists = vim.uv.fs_stat(path) ~= nil

		local suffix = ""
		if offset == 0 then
			suffix = "  (today)"
			today_index = #entries + 1
		elseif offset == -1 then
			suffix = "  (yesterday)"
		elseif offset == 1 then
			suffix = "  (tomorrow)"
		end

		local marker = exists and fzf.utils.ansi_from_hl("DiagnosticOk", "✓") or fzf.utils.ansi_codes.grey("○")
		local text = date .. "  " .. os.date("%a", ts) .. suffix
		entries[#entries + 1] = marker .. " " .. text .. "\t" .. date
	end

	fzf.fzf_exec(entries, {
		prompt = "Daily> ",
		winopts = { title = " Daily notes (±14 days) · ctrl-g calendar " },
		fzf_opts = {
			["--delimiter"] = "\t",
			["--with-nth"] = "1",
			["--no-sort"] = true,
			["--scroll-off"] = 10,
			["--sync"] = true,
		},
		keymap = { fzf = { start = ("pos(%d)"):format(today_index) } },
		previewer = {
			_ctor = function()
				local previewer = require("fzf-lua.previewer.builtin").buffer_or_file:extend()
				function previewer:parse_entry(entry_str)
					local date = entry_str:match("\t(%d%d%d%d%-%d%d%-%d%d)$")
					if not date then
						return { content = { { { "No preview available.", "Error" } } } }
					end
					local path = M.daily_path(date)
					if vim.uv.fs_stat(path) then
						return self:entry_to_file(path)
					end
					return {
						content = {
							{ { "This daily note has not been created yet.", "Comment" } },
							"",
							{ { "Press <CR> to create it.", "Comment" } },
						},
					}
				end
				return previewer
			end,
		},
		actions = {
			["ctrl-g"] = function(selected)
				local date = selected[1] and selected[1]:match("\t(%d%d%d%d%-%d%d%-%d%d)$")
				require("mycalendar").open(date)
			end,
			["enter"] = function(selected)
				local date = selected[1] and selected[1]:match("\t(%d%d%d%d%-%d%d%-%d%d)$")
				if date then
					M.open_daily(date)
				end
			end,
		},
	})
end

return M
