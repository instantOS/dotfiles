return {
	"vimwiki/vimwiki",
	lazy = true,
	-- enabled = false,
	branch = "dev",
	module = false,
	init = function()
		vim.cmd([[
        let g:vimwiki_filetypes = ['markdown']
        let g:vimwiki_markdown_link_ext=0
        let wiki = {}
        let wiki.path = '~/wiki/vimwiki'
        let wiki.syntax = 'markdown'
        let wiki.ext = '.md'
        let wiki.automatic_nested_syntaxes = 1

        let streamwiki = {}
        let streamwiki.path = '~/streamwiki/vimwiki'
        let streamwiki.automatic_nested_syntaxes = 1


        let g:vimwiki_conceal_pre = 1
        let g:vimwiki_list = [wiki, streamwiki] " wikilistmarker


        function! VimwikiLinkHandler(link)
          if a:link =~# '^txt:'
            try
              " chop off the leading file: - see :h expr-[:] for syntax:
              execute ':split ' . a:link[4:]
              return 1
            catch
              echo "Failed opening file in vim."
            endtry
          endif
          return 0
        endfunction

        let g:zettel_format = "%y%m%d-%H%M-%title"

        ]])

		-- Function to disable Treesitter highlighting for Markdown files
		function disable_treesitter_for_markdown()
			-- Disable Treesitter highlighting for Markdown filetype
			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = "markdown",
				callback = function()
					vim.cmd("TSBufDisable highlight")
				end,
			})

			-- Find all currently open Markdown buffers and disable Treesitter for them
			local buffers = vim.api.nvim_list_bufs()
			for _, buf in ipairs(buffers) do
				if vim.api.nvim_buf_is_valid(buf) then
					local ft = vim.api.nvim_buf_get_option(buf, "filetype")
					if ft == "markdown" then
						vim.api.nvim_buf_call(buf, function()
							vim.cmd("TSBufDisable highlight")
						end)
					end
				end
			end
		end

		disable_treesitter_for_markdown()

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				-- Enable wrapping
				vim.opt_local.wrap = true

				-- Set text width to 80 characters
				vim.opt_local.textwidth = 80

				-- Optionally, if you want soft line breaks at 80 characters but no hard break:
				vim.opt_local.linebreak = true
			end,
		})
	end,
	-- keys = {
	--     {
	--       "<leader>ww",
	--       "<Plug>VimwikiIndex",
	--       desc = "Open Vimwiki index"
	--     },
	--     {
	--       "<leader>wt",
	--       "<Plug>VimwikiTabIndex",
	--       desc = "Open Vimwiki index in new tab"
	--     },
	--     {
	--       "<leader>wi",
	--       "<Plug>VimwikiDiaryIndex",
	--       desc = "Open Vimwiki diary index"
	--     },
	--     {
	--       "<leader>w<leader>w",
	--       "<Plug>VimwikiMakeDiaryNote",
	--       desc = "Make new diary note"
	--     },
	--     {
	--       "<leader>w<leader>y",
	--       "<Plug>VimwikiMakeYesterdayDiaryNote",
	--       desc = "Make diary note for yesterday"
	--     },
	--     {
	--       "<leader>w<leader>m",
	--       "<Plug>VimwikiMakeTomorrowDiaryNote",
	--       desc = "Make diary note for tomorrow"
	--     }
	-- }
	cmd = {
		"VimwikiIndex",
		"VimwikiTabIndex",
		"VimwikiDiaryIndex",
		"VimwikiMakeDiaryNote",
		"VimwikiMakeYesterdayDiaryNote",
		"VimwikiMakeTomorrowDiaryNote",
	},
}
