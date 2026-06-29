return {
	{
		"gbprod/substitute.nvim",
		config = function()
			local sub = require("substitute")
			local sub_range = require("substitute.range")
			local sub_exchange = require("substitute.exchange")
			sub.setup()
			vim.keymap.set("n", "s", sub.operator, { noremap = true, desc = "Substitute operator" })
			vim.keymap.set("n", "ss", sub.line, { noremap = true, desc = "Substitute operator line" })
			vim.keymap.set("n", "S", sub.eol, { noremap = true, desc = "Substitute operator to end-of-line" })
			vim.keymap.set("x", "s", sub.visual, { noremap = true, desc = "Substitute operator" })
			vim.keymap.set("n", "<leader>s", sub_range.operator, { noremap = true, desc = "Substitute range" })
			vim.keymap.set("n", "<leader>ss", sub_range.word, { noremap = true, desc = "Substitute range word" })
			vim.keymap.set("x", "<leader>s", sub_range.visual, { noremap = true, desc = "Substitute range" })
			vim.keymap.set("n", "sx", sub_exchange.operator, { noremap = true, desc = "Substitute exchange" })
			vim.keymap.set("n", "sxx", sub_exchange.line, { noremap = true, desc = "Substitute exchange line" })
			vim.keymap.set("x", "X", sub_exchange.visual, { noremap = true, desc = "Substitute exchange" })
			vim.keymap.set("n", "sxc", sub_exchange.cancel, { noremap = true, desc = "Substitute exchange cancel" })
		end,
	},
}
