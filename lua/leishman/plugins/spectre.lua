return {
	{
		"nvim-pack/nvim-spectre",
		cmd = "Spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>R",
				function()
					require("spectre").toggle()
				end,
				desc = "Spectre: toggle",
			},
			{
				"<leader>rw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Spectre: search current word",
			},
			{
				"<leader>rw",
				function()
					require("spectre").open_visual()
				end,
				mode = "v",
				desc = "Spectre: search selection",
			},
			{
				"<leader>rp",
				function()
					require("spectre").open_file_search({ select_word = true })
				end,
				desc = "Spectre: search in current file",
			},
		},
		config = function()
			require("spectre").setup()
		end,
	},
}
