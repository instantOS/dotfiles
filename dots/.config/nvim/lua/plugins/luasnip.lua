return {
	"L3MON4D3/LuaSnip",
	lazy = true,
	version = "v2.*",
	build = "make install_jsregexp",
	config = function()
		local luasnip = require("luasnip")
		local untrigger = function()
			-- get the snippet
			local snip = luasnip.session.current_nodes[vim.api.nvim_get_current_buf()].parent.snippet
			-- get its trigger
			local trig = snip.trigger
			-- replace that region with the trigger
			local node_from, node_to = snip.mark:pos_begin_end_raw()
			vim.api.nvim_buf_set_text(0, node_from[1], node_from[2], node_to[1], node_to[2], { trig })
			-- reset the cursor-position to ahead the trigger
			vim.fn.setpos(".", { 0, node_from[1] + 1, node_from[2] + 1 + string.len(trig) })
		end

		vim.keymap.set({ "i", "s" }, "<c-x>", function()
			if require("luasnip").in_snippet() then
				untrigger()
				require("luasnip").unlink_current()
			end
		end, {
			desc = "Undo a snippet",
		})

		-- vim.print(vim.inspect(luasnip))

		luasnip.config.set_config({
			enable_autosnippets = true,
			store_selection_keys = "<S-Tab>",
		})

		-- port "evesdropper/luasnip-latex-snippets.nvim" to here
		require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/luasnippets" })
	end,
}
