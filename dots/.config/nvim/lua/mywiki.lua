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

	local items = {}
	for offset = 14, -14, -1 do
		local ts = base + offset * 86400
		local date = os.date("%Y-%m-%d", ts)
		local path = diary_dir() .. "/" .. date .. ".md"
		local exists = vim.uv.fs_stat(path) ~= nil

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
			file = path,
			date = date,
			exists = exists,
			today = offset == 0,
			preview = exists and "file" or {
				text = "This daily note has not been created yet.\n\nPress <CR> to create it.",
				loc = false,
			},
		}
	end

	require("snacks").picker.pick({
		title = "Daily notes (±14 days)",
		items = items,
		format = function(item)
			return {
				{
					item.exists and "✓ " or "○ ",
					item.exists and "DiagnosticOk" or "Comment",
					virtual = true,
				},
				{ item.text, item.exists and "Normal" or "Comment" },
			}
		end,
		preview = "preview",
		sort = false,
		on_show = function(picker)
			for i, item in ipairs(picker:items()) do
				if item.today then
					picker.list:view(i)
					require("snacks").picker.actions.list_scroll_center(picker)
					break
				end
			end
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				M.open_daily(item.date)
			end
		end,
	})
end

return M
