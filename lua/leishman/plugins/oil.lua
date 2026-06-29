return {
	{
		"stevearc/oil.nvim",
		lazy = false, -- load early so it can hijack netrw for directories
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			view_options = { show_hidden = true },
		},
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" },
		},
	},
}
