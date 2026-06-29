return {
	{
		"NicolasGB/jj.nvim",
		version = "*",
		-- Optional integrations (uncomment if/when installed):
		--   "folke/snacks.nvim"        -- nicer picker UI
		--   "sindrets/diffview.nvim"   -- alternative diff backend
		cmd = { "J", "Jdiff", "Jvdiff", "Jhdiff", "Jbrowse" },
		keys = {
			{
				"<leader>jl",
				function()
					require("jj.cmd").log()
				end,
				desc = "JJ log",
			},
			{
				"<leader>js",
				function()
					require("jj.cmd").status()
				end,
				desc = "JJ status",
			},
			{
				"<leader>jd",
				function()
					require("jj.cmd").describe()
				end,
				desc = "JJ describe",
			},
			{
				"<leader>je",
				function()
					require("jj.cmd").edit()
				end,
				desc = "JJ edit",
			},
		},
		config = function()
			require("jj").setup({})
		end,
	},
}
