-- Wiki helpers replacing the Obsidian keymaps we used before.
-- The wiki is a plain folder of markdown notes, so these only need Snacks.

local M = {}

local function wiki_root()
	local root = vim.g.mywiki_root
	if type(root) == "string" and root ~= "" then
		return vim.fn.expand(root)
	end
	return vim.fn.expand("~/wiki/vimwiki")
end

local function diary_dir()
	return wiki_root() .. "/diary"
end

---Open (and create, if needed) the daily note for a date.
---@param date? string Date in YYYY-MM-DD format, defaults to today.
function M.open_daily(date)
	date = date or os.date("%Y-%m-%d")
	local dir = diary_dir()
	vim.fn.mkdir(dir, "p")
	vim.cmd.edit(vim.fn.fnameescape(dir .. "/" .. date .. ".md"))
end

---Fuzzy-find a note in the wiki.
function M.quick_switch()
	require("snacks").picker.files({
		cwd = wiki_root(),
		ft = "md",
		title = "Wiki notes",
	})
end

---Search the text of all wiki notes.
function M.search()
	require("snacks").picker.grep({
		cwd = wiki_root(),
		glob = "*.md",
		title = "Search wiki",
	})
end

---Pick a daily note from the previous/next 14 days.
function M.dailies()
	local now = os.date("*t")
	now.hour, now.min, now.sec = 12, 0, 0
	local base = os.time(now)

	-- Today first, then recent days, then upcoming days.
	local offsets = { 0 }
	for offset = -1, -14, -1 do
		offsets[#offsets + 1] = offset
	end
	for offset = 1, 14 do
		offsets[#offsets + 1] = offset
	end

	local items = {}
	for _, offset in ipairs(offsets) do
		local ts = base + offset * 86400
		local date = os.date("%Y-%m-%d", ts)
		local suffix = ""
		if offset == 0 then
			suffix = "  (today)"
		elseif offset == -1 then
			suffix = "  (yesterday)"
		elseif offset == 1 then
			suffix = "  (tomorrow)"
		end
		items[#items + 1] = {
			text = date .. "  " .. os.date("%a", ts) .. suffix,
			file = diary_dir() .. "/" .. date .. ".md",
			date = date,
		}
	end

	require("snacks").picker.pick({
		title = "Daily notes (±14 days)",
		items = items,
		format = "text",
		preview = "file",
		sort = false,
		confirm = function(picker, item)
			picker:close()
			if item then
				M.open_daily(item.date)
			end
		end,
	})
end

return M
