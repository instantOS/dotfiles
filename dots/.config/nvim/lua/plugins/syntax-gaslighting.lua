return {
	"NotAShelf/syntax-gaslighting.nvim",
	lazy = true,
	cmd = "GasLight",
	opts = {
		-- Set the chance of gaslighting per line (1-100%)
		gaslighting_chance = 5, -- Default is 5%

		-- Minimum line length to apply gaslighting
		min_line_length = 10, -- Default is 10 characters

		-- Custom messages for gaslighting (optional)
		messages = {
			"Are you sure this will pass the code quality checks? 🤔",
			"Is this line really covered by unit tests? 🧐",
			-- Add more custom messages here...
		},

		-- Option to merge user messages with the default ones (default: false)
		-- If disabled, the messages table will override default messages.
		merge_messages = true,

		-- Highlight group for gaslighting messages (linked to 'Comment' by default)
		highlight = "GaslightingUnderline",

		-- Debounce delay for updates in milliseconds (default: 500ms)
		debounce_delay = 500,

		-- Auto-update on buffer events (default: true)
		auto_update = true,

		-- List of filetypes to ignore (default: {"netrw"})
		filetypes_to_ignore = { "netrw", "markdown" },
	},
}
