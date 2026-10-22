return {
	"jakewvincent/mkdnflow.nvim",
	ft = { "markdown", "rmd" },
	keys = {
		{
			"<leader>ww",
			function()
				require("mywiki").quick_switch()
			end,
			desc = "Open wiki note",
		},
		{
			"<leader>ws",
			function()
				require("mywiki").search()
			end,
			desc = "Search wiki",
		},
		{
			"<leader>wt",
			function()
				require("mywiki").dailies()
			end,
			desc = "Pick daily note (±14 days)",
		},
		{
			"<leader>w#",
			function()
				require("mywiki").tags()
			end,
			desc = "List wiki tags",
		},
		{
			"<leader>w<leader>w",
			function()
				require("mywiki").open_daily()
			end,
			desc = "Open today's daily note",
		},
	},
	config = function()
		require("mkdnflow").setup({
			modules = {
				-- Folding is handled by treesitter (see init.lua) and `foldenable`
				-- is off globally, so Mkdnflow's manual folds would only warn.
				folds = false,
				foldtext = false,
				completion = true,
			},
			path_resolution = {
				-- The wiki uses links relative to the note they appear in,
				-- e.g. "[[Song notes/Lovely]]" inside 07 - Chor/Chor.md.
				primary = "current",
				fallback = "first",
			},
			links = {
				-- ~/wiki/vimwiki mostly uses [[path|title]] without extension.
				style = "wiki",
				conceal = true, -- works with conceallevel = 2
				implicit_extension = "md",
			},
			to_do = {
				highlight = true,
				-- Rotate unchecked -> done -> in-progress -> unchecked.
				status_order = { "not_started", "complete", "in_progress" },
				statuses = {
					-- Use the usual lowercase markdown checkbox when completing an item.
					complete = { marker = { "x", "X" } },
				},
			},
			on_attach = function(bufnr)
				-- MkdnEnter would otherwise run followLink on any heading/plain
				-- text (since folds are disabled) and auto-create a note from the
				-- word under the cursor. Only follow tags and real links.
				local links = require("mkdnflow").links
				local wiki = require("mywiki")
				vim.keymap.set("n", "<CR>", function()
					local tag = wiki.tag_at_cursor()
					if tag then
						wiki.tag_references(tag)
					elseif links.getLinkUnderCursor() then
						vim.cmd("MkdnFollowLink")
					else
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
					end
				end, { buffer = bufnr, desc = "Follow tag/link (or default <CR>)" })
			end,
			mappings = {
				-- <leader>f saves and <leader>F formats; folds are disabled above.
				MkdnFoldSection = false,
				MkdnUnfoldSection = false,
				-- Leave insert-mode <Tab>/<S-Tab> to blink.cmp. mkdnflow's
				-- fallback feeds a literal tab, which would swallow completion.
				MkdnTableNextCell = { "i", "<A-l>" },
				MkdnTablePrevCell = { "i", "<A-h>" },
			},
		})
	end,
}
