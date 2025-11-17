local luasnip = require("luasnip")

local untrigger = function()
	-- get the snippet
	local snip = require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()].parent.snippet
	-- get its trigger
	local trig = snip.trigger
	-- replace that region with the trigger
	local node_from, node_to = snip.mark:pos_begin_end_raw()
	vim.api.nvim_buf_set_text(0, node_from[1], node_from[2], node_to[1], node_to[2], { trig })
	-- reset the cursor-position to ahead the trigger
	vim.fn.setpos(".", { 0, node_from[1] + 1, node_from[2] + 1 + string.len(trig) })
end
