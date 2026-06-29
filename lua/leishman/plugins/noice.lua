return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				-- Use noice/treesitter to render LSP markdown (hover, signature,
				-- cmp docs). cmp is provided by the lsp.lua spec.
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true, -- classic bottom cmdline for search
				command_palette = true, -- position cmdline + popupmenu together
				long_message_to_split = true, -- long messages -> split
				inc_rename = false,
				lsp_doc_border = false,
			},
		},
	},
}
