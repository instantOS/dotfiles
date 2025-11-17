return {
	enabled = false,
	"supermaven-inc/supermaven-nvim",
	event = "VeryLazy",
	config = function()
		require("supermaven-nvim").setup({
			condition = function()
				local file_path = vim.api.nvim_buf_get_name(0)
				local filename = vim.fn.expand("%:t")
				-- TODO: learn lua and do not copy if...return everywhere

				if file_path:match("^/dev/shm/") then
					return true
				end

				local password_path = vim.fn.expand("~/.password-store")
				if file_path:match("^" .. vim.fn.escape(password_store_path, "%.") .. "/") then
					return true
				end
				-- Check if the file ends with gpg.txt
				if file_path:match("%.gpg%.txt$") then
					return true
				end
				-- Check if the file is an SSH key (common SSH key filenames)
				local ssh_key_patterns = {
					"id_rsa",
					"id_dsa",
					"id_ecdsa",
					"id_ed25519",
					"authorized_keys",
					"known_hosts",
				}
				for _, pattern in ipairs(ssh_key_patterns) do
					if filename == pattern then
						return true
					end
				end
				-- Check if the file is in the ~/.ssh directory
				local ssh_dir = vim.fn.expand("~/.ssh")
				if file_path:match("^" .. vim.fn.escape(ssh_dir, "%.") .. "/") then
					return true
				end
			end,
			keymaps = {
				accept_suggestion = "<C-j>",
				clear_suggestion = "<C-e>",
				accept_word = "<C-M-j>",
			},
		})
	end,
}
