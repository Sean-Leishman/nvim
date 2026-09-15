return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					-- Conform will run multiple formatters sequentially
					python = { "ruff_fix", "ruff_format", "black" },
					-- clangd has clang-format built in; "prefer" makes conform use it
					-- instead of the `*` trimmers below (which otherwise satisfy the
					-- `fallback` check and stop clangd from ever formatting).
					c = { lsp_format = "prefer" },
					cpp = { lsp_format = "prefer" },
					["*"] = { "trim_whitespace", "trim_newlines" },
					-- You can customize some of the format options for the filetype (:help conform.format)
					rust = { "rustfmt", lsp_format = "fallback" },
					-- Conform will run the first available formatter
					javascript = { "prettierd", "prettier", stop_after_first = true },
				},
				format_on_save = {
					-- These options will be passed to conform.format()
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			})
		end,
	},
}
