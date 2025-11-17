local potato = require("mypotato")

local display = {
	["icons.mode"] = "short",
	pum = {
		kind_context = { "│", "│" },
		source_context = { "", "" },
	},
}

if potato then
	vim.g.coq_settings = {
		-- keymap = {
		--     pre_select = true
		-- },
		display = display,
	}
else
	vim.g.coq_settings = {
		-- keymap = {
		--     pre_select = true
		-- },
		clients = {
			tabnine = {
				enabled = true,
			},
		},
		display = display,
	}
end

local capabilities = require("coq").lsp_ensure_capabilities()

return capabilities
