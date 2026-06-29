return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 200,
		spec = {
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "git hunks" },
			{ "<leader>j", group = "jujutsu" },
			{ "<leader>p", group = "project" },
			{ "<leader>r", group = "replace (spectre)" },
			{ "<leader>d", group = "debug" },
			{ "<leader>x", group = "trouble" },
		},
	},
}
