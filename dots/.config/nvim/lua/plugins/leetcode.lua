local leet_arg = "leetcode.nvim"
return {
	"kawre/leetcode.nvim",
	cmd = { "Leet" },
	opts = {
		lang = {
			"rust",
		},
	},
	dependencies = {
		-- "nvim-telescope/telescope.nvim",
		"ibhagwan/fzf-lua",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
}
