return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		commit = "4da89f3",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
		commit = "1a31f82",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
			local default_setup = function(server)
				vim.lsp.config(server, {
					capabilities = lsp_capabilities,
				})
			end
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "pyright", "rust_analyzer" },
				automatic_installation = true,
				handlers = {
					default_setup,
					lua_ls = function()
						vim.lsp.config("lua_ls", {
							capabilities = lsp_capabilities,
						})
					end,
				},
			})

			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				callback = function(ev)
					local ft = vim.bo[ev.buf].filetype
					if ft == "python" then
						vim.cmd("LspStart pyright")
					elseif ft == "c" or ft == "cpp" or ft == "cc" or ft == "h" or ft == "hpp" then
						vim.cmd("LspStart clangd")
					elseif ft == "rs" then
						vim.cmd("LspStart rust_analyzer")
					end
				end,
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<Enter>"] = cmp.mapping.confirm({ select = true }),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				formatting = {
					format = lspkind.cmp_format({
						maxwidth = 150,
						ellipsis_char = "...",
					}),
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
			vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
			vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")

			vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
			vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
			vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
			vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
			vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
			vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
			vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
			vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
			vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async=true})<cr>", opts)
			vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

			-- clangd: smart compile_commands.json discovery + rich flag set.
			-- Ported from the old after/plugin/lsp.lua (pre lazy.nvim migration).
			local function find_compile_commands_recursive(dir, max_depth)
				max_depth = max_depth or 3
				if max_depth <= 0 then
					return nil
				end

				local candidates = {
					dir .. "/compile_commands.json",
					dir .. "/build/compile_commands.json",
					dir .. "/build/debug/compile_commands.json",
					dir .. "/build/release/compile_commands.json",
					dir .. "/out/build/debug/compile_commands.json",
					dir .. "/out/build/release/compile_commands.json",
					dir .. "/build/clang19-debug/compile_commands.json",
					dir .. "/build/clang19-release/compile_commands.json",
					dir .. "/.build/compile_commands.json",
					dir .. "/cmake-build-debug/compile_commands.json",
					dir .. "/cmake-build-release/compile_commands.json",
				}

				for _, path in ipairs(candidates) do
					if vim.fn.filereadable(path) == 1 then
						return vim.fn.fnamemodify(path, ":h")
					end
				end

				local parent = vim.fn.fnamemodify(dir, ":h")
				if parent ~= dir then
					return find_compile_commands_recursive(parent, max_depth - 1)
				end

				return nil
			end

			local clangd_root_markers = {
				".git",
				".hg",
				".svn",
				"CMakeLists.txt",
				"Makefile",
				"makefile",
				".clangd",
				".clang-format",
				".clang-tidy",
				"compile_commands.json",
				"compile_flags.txt",
				"configure.ac",
				"configure.in",
				"meson.build",
				"BUILD.bazel",
				"WORKSPACE",
			}

			local function get_project_root(bufnr)
				local bufname = vim.api.nvim_buf_get_name(bufnr or 0)
				local dirname = vim.fn.fnamemodify(bufname, ":p:h")

				local function find_root(path)
					for _, pattern in ipairs(clangd_root_markers) do
						if vim.fn.glob(path .. "/" .. pattern) ~= "" then
							return path
						end
					end
					local parent = vim.fn.fnamemodify(path, ":h")
					if parent == path then
						return nil
					end
					return find_root(parent)
				end

				return find_root(dirname) or dirname
			end

			local function build_clangd_cmd(bufnr)
				local project_root = get_project_root(bufnr)
				local compile_commands_dir = find_compile_commands_recursive(project_root)

				local cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
					"--all-scopes-completion",
					"--cross-file-rename",
					"--log=verbose",
					"--pretty",
					"--pch-storage=memory",
					"--query-driver=/usr/bin/clang-19,/usr/bin/clang++-19,/usr/bin/clang,/usr/bin/clang++,/usr/local/bin/clang,/usr/local/bin/clang++",
				}

				if compile_commands_dir then
					table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
				else
					local fallback_includes = {
						"/usr/include",
						"/usr/local/include",
						"/usr/include/c++/11",
						"/usr/include/c++/12",
						"/usr/include/c++/13",
					}
					for _, include_path in ipairs(fallback_includes) do
						if vim.fn.isdirectory(include_path) == 1 then
							table.insert(cmd, "--extra-arg=-I" .. include_path)
						end
					end
				end

				return cmd
			end

			local function set_clangd_config(bufnr)
				vim.lsp.config("clangd", {
					cmd = build_clangd_cmd(bufnr),
					root_markers = clangd_root_markers,
					init_options = {
						usePlaceholders = true,
						completeUnimported = true,
						clangdFileStatus = true,
					},
				})
			end

			-- Initial config (buffer 0); refreshed per-project below.
			set_clangd_config(0)

			-- Recompute the clangd cmd for the current buffer's project BEFORE the
			-- filetype autocmd (BufRead/BufNewFile) fires `LspStart clangd`. This
			-- replaces the old lspconfig `on_new_config` hook.
			vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
				pattern = { "*.c", "*.cc", "*.cpp", "*.cxx", "*.h", "*.hpp", "*.hxx" },
				callback = function(ev)
					set_clangd_config(ev.buf)
				end,
			})

			-- clangd buffer-local keymaps + helper commands.
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if not client or client.name ~= "clangd" then
						return
					end
					local bufnr = ev.buf
					local bufopts = { buffer = bufnr, silent = true }

					vim.keymap.set("n", "<space>ch", "<cmd>ClangdSwitchSourceHeader<cr>", bufopts)
					vim.keymap.set("n", "<space>ct", "<cmd>ClangdTypeHierarchy<cr>", bufopts)
					vim.keymap.set("n", "<space>cs", "<cmd>ClangdSymbolInfo<cr>", bufopts)

					vim.api.nvim_buf_create_user_command(bufnr, "ClangdRestart", function()
						vim.lsp.stop_client(client.id)
						vim.cmd("LspStart clangd")
					end, {})

					vim.api.nvim_buf_create_user_command(bufnr, "ClangdFindCompileCommands", function()
						local project_root = get_project_root(bufnr)
						local dir = find_compile_commands_recursive(project_root)
						if dir then
							print("Found compile_commands.json in: " .. dir)
							local file = dir .. "/compile_commands.json"
							local out = vim.fn.system(
								"jq length " .. vim.fn.shellescape(file) .. " 2>/dev/null || echo 'Cannot read file'"
							)
							print("Number of compilation units: " .. vim.trim(out))
						else
							print("No compile_commands.json found in project")
							print(
								"Try: cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -sf build/compile_commands.json ."
							)
						end
					end, {})
				end,
			})
			vim.lsp.config("clang-format", {})
			vim.lsp.config("rust_analyzer", {})
			vim.lsp.config("pyright", {
				on_attach = on_attach,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})
		end,
	},
}
