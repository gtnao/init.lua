-- Options
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.list = true
vim.opt.listchars = {
	space = "⋅",
	tab = "> ",
	trail = "•",
}

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.showmatch = true

vim.opt.number = true

vim.opt.scrolloff = 5

vim.opt.virtualedit = "block"

vim.opt.swapfile = false

vim.opt.termguicolors = true

vim.opt.clipboard:append("unnamedplus")

-- Keymaps
vim.g.mapleader = " "
vim.keymap.set({ "n", "x" }, "<Leader>", "<Nop>")
vim.keymap.set({ "n", "x" }, "<Plug>(_LSP)", "<Nop>")
vim.keymap.set({ "n", "x" }, ",", "<Plug>(_LSP)")
vim.keymap.set({ "n", "x" }, "<Plug>(_FuzzyFinder)", "<Nop>")
vim.keymap.set({ "n", "x" }, "z", "<Plug>(_FuzzyFinder)")

vim.keymap.set("n", "<Leader>L", [[<Cmd>Lazy<CR>]])
vim.keymap.set({ "n", "x" }, ";", ":")
vim.keymap.set({ "n", "x" }, ":", ";")

vim.keymap.set("n", "<Leader>w", [[<Cmd>update<CR>]])
vim.keymap.set("n", "<Leader>q", [[<Cmd>quit<CR>]])

vim.keymap.set({ "n", "x" }, "<Leader>h", "^")
vim.keymap.set({ "n", "x" }, "<Leader>l", "$")

vim.keymap.set("n", "<ESC><ESC>", [[<Cmd>nohlsearch<CR>]])

vim.keymap.set("n", "ZZ", "<Nop>")
vim.keymap.set("n", "ZQ", "<Nop>")

-- FileType
local ft_settings = {
	go = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = false,
	},
	lua = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = false,
	},
	python = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
	},
	rust = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
	},
	c = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
	},
	cpp = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
	},
	java = {
		tabstop = 4,
		shiftwidth = 4,
		expandtab = true,
	},
}
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local s = ft_settings[vim.bo.filetype]
		if s then
			vim.opt_local.tabstop = s.tabstop
			vim.opt_local.shiftwidth = s.shiftwidth
			vim.opt_local.expandtab = s.expandtab
		end
	end,
})

-- Autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})

-- Plugin Manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	defaults = {
		lazy = true,
	},
	install = { colorscheme = { "habamax" } },
	checker = { enabled = true },
	spec = {
		-- Completion
		{
			"hrsh7th/nvim-cmp",
			event = { "InsertEnter", "CmdlineEnter" },
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-nvim-lsp-signature-help",
				"hrsh7th/cmp-nvim-lsp-document-symbol",
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-cmdline",
				"saadparwaiz1/cmp_luasnip",
				"L3MON4D3/LuaSnip",
				"onsails/lspkind-nvim",
			},
			config = function()
				local cmp = require("cmp")
				local lspkind = require("lspkind")
				local luasnip = require("luasnip")
				cmp.setup({
					mapping = cmp.mapping.preset.insert({
						["<C-u>"] = cmp.mapping.scroll_docs(-4),
						["<C-d>"] = cmp.mapping.scroll_docs(4),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "path" },
						{ name = "nvim_lsp_signature_help" },
						{ name = "nvim_lua" },
						{ name = "luasnip" },
					}, {
						{ name = "buffer" },
					}),
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					formatting = {
						format = lspkind.cmp_format({
							mode = "symbol_text",
							maxwidth = {
								menu = 50,
								abbr = 50,
							},
							ellipsis_char = "...",
							show_labelDetails = true,
						}),
					},
				})
				cmp.setup.cmdline(":", {
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						{ name = "cmdline" },
						{ name = "path" },
					}),
				})
				cmp.setup.cmdline("/", {
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						{ name = "nvim_lsp_document_symbol" },
						{ name = "buffer" },
					}),
				})
			end,
		},
		-- LSP
		{
			"williamboman/mason.nvim",
			cmd = "Mason",
			config = true,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = {
				"williamboman/mason.nvim",
				"neovim/nvim-lspconfig",
				"hrsh7th/cmp-nvim-lsp",
			},
			event = { "BufReadPre", "BufNewfile" },
			config = function()
				local mason_lspconfig = require("mason-lspconfig")
				local lspconfig = require("lspconfig")
				mason_lspconfig.setup({
					ensure_installed = {
						"lua_ls",
					},
					automatic_installation = true,
				})
				local default_capabilities = require("cmp_nvim_lsp").default_capabilities()
				mason_lspconfig.setup_handlers({
					function(server_name)
						lspconfig[server_name].setup({
							capabilities = default_capabilities,
						})
					end,
					["lua_ls"] = function()
						lspconfig.lua_ls.setup({
							capabilities = default_capabilities,
							on_attach = function(client, _)
								client.server_capabilities.documentFormattingProvider = false
								client.server_capabilities.documentRangeFormattingProvider = false
							end,
							settings = {
								Lua = {
									diagnostics = {
										globals = { "vim" },
									},
								},
							},
						})
					end,
				})
			end,
		},
		{
			"jay-babu/mason-null-ls.nvim",
			dependencies = {
				"williamboman/mason.nvim",
				{
					"nvimtools/none-ls.nvim",
					dependencies = {
						"nvim-lua/plenary.nvim",
					},
				},
			},
			event = { "BufReadPre", "BufNewfile" },
			config = function()
				local mason_null_ls = require("mason-null-ls")
				local null_ls = require("null-ls")
				mason_null_ls.setup({
					ensure_installed = {
						"stylua",
					},
					automatic_installation = true,
				})
				null_ls.setup({
					sources = {
						null_ls.builtins.formatting.stylua,
					},
					on_attach = function(client, bufnr)
						if client.supports_method("textDocument/formatting") then
							vim.api.nvim_create_autocmd("BufWritePre", {
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.format({ async = false })
								end,
							})
						end
					end,
				})
			end,
		},
		{
			"nvimdev/lspsaga.nvim",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
			event = { "VeryLazy" },
			config = function()
				require("lspsaga").setup({
					ui = {
						code_action = "󰌶",
					},
					symbol_in_winbar = {
						enable = false,
					},
				})
				vim.keymap.set({ "n" }, "<Plug>(_LSP)K", "<Cmd>Lspsaga hover_doc<CR>")
				vim.keymap.set({ "n" }, "<Plug>(_LSP)d", "<Cmd>Lspsaga peek_definition<CR>")
				vim.keymap.set({ "n" }, "<Plug>(_LSP)D", "<Cmd>Lspsaga goto_definition<CR>")
				vim.keymap.set({ "n" }, "<Plug>(_LSP)f", "<Cmd>Lspsaga finder<CR>")
				vim.keymap.set({ "n" }, "<Plug>(_LSP)e", "<Cmd>Lspsaga diagnostic_jump_next<CR>")
				vim.keymap.set({ "n" }, "<Plug>(_LSP)o", "<Cmd>Lspsaga outline<CR>")
				vim.keymap.set({ "n" }, "<Plug>(_LSP)r", "<Cmd>Lspsaga rename ++project<CR>")
				vim.keymap.set({ "n" }, "<Plug>(_LSP)c", "<Cmd>Lspsaga code_action<CR>")
			end,
		},
		{
			"j-hui/fidget.nvim",
			event = { "BufReadPre", "BufNewfile" },
			config = true,
		},
		-- Treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			dependencies = {
				"RRethy/nvim-treesitter-endwise",
			},
			event = { "VeryLazy" },
			config = function()
				local configs = require("nvim-treesitter.configs")
				configs.setup({
					ensure_installed = {
						"lua",
						"markdown",
						"tsx",
					},
					sync_install = false,
					highlight = {
						enable = true,
					},
					incremental_selection = {
						enable = true,
						keymaps = {
							node_incremental = "<CR>",
							node_decremental = "<S-CR>",
						},
					},
					endwise = {
						enable = true,
					},
				})
			end,
		},
		-- FuzzyFinder
		{
			"nvim-telescope/telescope.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{
					"nvim-telescope/telescope-fzf-native.nvim",
					build = "make",
				},
				{
					"nvim-telescope/telescope-live-grep-args.nvim",
				},
				"crispgm/telescope-heading.nvim",
			},
			event = { "VimEnter" },
			config = function()
				local telescope = require("telescope")
				local lga_actions = require("telescope-live-grep-args.actions")
				telescope.setup({
					extensions = {
						live_grep_args = {
							auto_quoting = true,
							mappings = {
								i = {
									["<C-k>"] = lga_actions.quote_prompt(),
								},
							},
						},
						heading = {
							treesitter = true,
						},
					},
				})
				telescope.load_extension("fzf")
				telescope.load_extension("live_grep_args")
				telescope.load_extension("heading")
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)f", [[<Cmd>Telescope find_files<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)o", [[<Cmd>Telescope oldfiles<CR>]])
				vim.keymap.set(
					"n",
					"<Plug>(_FuzzyFinder)s",
					[[<Cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>]]
				)
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)b", [[<Cmd>Telescope buffers<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder);", [[<Cmd>Telescope command_history<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)/", [[<Cmd>Telescope search_history<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)q", [[<Cmd>Telescope quickfix<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)d", [[<Cmd>Telescope diagnostics<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)n", [[<Cmd>Telescope notify<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)g", [[<Cmd>Telescope git_status<CR>]])
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)h", [[<Cmd>Telescope heading<CR>]])
			end,
		},
		-- Filer
		{
			"nvim-neo-tree/neo-tree.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"MunifTanjim/nui.nvim",
			},
			event = { "VimEnter" },
			opts = {
				close_if_last_window = true,
				filesystem = {
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
					},
					follow_current_file = {
						enabled = true,
					},
					group_empty_dirs = true,
				},
			},
			init = function()
				vim.keymap.set({ "n" }, "<C-n>", [[<Cmd>Neotree toggle reveal<CR>]])
			end,
		},
		-- Diagnostic
		{
			"folke/trouble.nvim",
			cmd = "Trouble",
			keys = {
				{
					"<Leader>xx",
					[[<Cmd>Trouble diagnostics toggle<CR>]],
					mode = { "n" },
				},
				{
					"<leader>xX",
					[[<Cmd>Trouble diagnostics toggle filter.buf=0<CR>]],
					mode = { "n" },
				},
			},
			opts = {
				focus = true,
				open_no_results = true,
			},
		},
		-- AI
		-- Nodejs is required.
		-- First, execute `Copilot auth`.
		{
			"zbirenbaum/copilot.lua",
			event = { "InsertEnter" },
			opts = {
				suggestion = {
					auto_trigger = true,
					keymap = {
						accept = "<Tab>",
					},
				},
			},
		},
		-- Git
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"sindrets/diffview.nvim",
				"nvim-telescope/telescope.nvim",
			},
			keys = {
				{
					"<Leader>g",
					[[<Cmd>Neogit<CR>]],
					mode = { "n" },
				},
			},
			config = true,
		},
		{
			"lewis6991/gitsigns.nvim",
			event = { "VeryLazy" },
			config = true,
		},
		-- Cmdline
		{
			"folke/noice.nvim",
			dependencies = {
				"MunifTanjim/nui.nvim",
				"rcarriga/nvim-notify",
			},
			event = { "VimEnter" },
			opts = {
				popupmenu = {
					backend = "cmp",
				},
			},
		},
		-- Terminal
		{
			"akinsho/toggleterm.nvim",
			cmd = "ToggleTerm",
			config = true,
		},
		-- Sinippet
		{
			"L3MON4D3/LuaSnip",
			dependencies = {
				"rafamadriz/friendly-snippets",
			},
			build = "make install_jsregexp",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load({
					paths = {
						vim.fn.stdpath("data") .. "/lazy/friendly-snippets",
					},
				})
				local luasnip = require("luasnip")
				vim.keymap.set({ "i", "s" }, "<C-L>", function()
					luasnip.jump(1)
				end)
				vim.keymap.set({ "i", "s" }, "<C-J>", function()
					luasnip.jump(-1)
				end)
			end,
		},
		-- View
		-- Statusline
		{
			"nvim-lualine/lualine.nvim",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			event = { "VimEnter" },
			config = true,
		},
		-- Bufferline
		{
			"akinsho/bufferline.nvim",
			version = "*",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			event = { "BufReadPre", "BufNewfile" },
			config = function()
				require("bufferline").setup({
					options = {
						diagnostics = "nvim_lsp",
						offsets = {
							{
								filetype = "neo-tree",
								text = "FileExplorer",
								text_align = "center",
								separator = true,
							},
						},
						separator_style = "slant",
					},
				})
				vim.keymap.set({ "n" }, "<C-b>l", "<Cmd>BufferLineCycleNext<CR>")
				vim.keymap.set({ "n" }, "<C-b>h", "<Cmd>BufferLineCyclePrev<CR>")
			end,
		},
		{
			"petertriho/nvim-scrollbar",
			event = { "VeryLazy" },
			config = true,
		},
		-- Startup
		{
			"goolord/alpha-nvim",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			event = { "VimEnter" },
			config = function()
				local startify = require("alpha.themes.startify")
				startify.file_icons.provider = "devicons"
				startify.section.header.val = {
					[[                                                                       ]],
					[[  ██████   █████                   █████   █████  ███                  ]],
					[[ ░░██████ ░░███                   ░░███   ░░███  ░░░                   ]],
					[[  ░███░███ ░███   ██████   ██████  ░███    ░███  ████  █████████████   ]],
					[[  ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ░░███░░███░░███  ]],
					[[  ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███  ░███ ░███ ░███  ]],
					[[  ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███  ░███ ░███ ░███  ]],
					[[  █████  ░░█████░░██████ ░░██████     ░░███      █████ █████░███ █████ ]],
					[[ ░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░      ░░░░░ ░░░░░ ░░░ ░░░░░  ]],
					[[                                                                       ]],
				}
				require("alpha").setup(startify.config)
			end,
		},
		-- Edit
		{
			"kylechui/nvim-surround",
			event = { "VeryLazy" },
			config = true,
		},
		{
			"gbprod/substitute.nvim",
			keys = {
				{
					"_",
					[[<Cmd>lua require('substitute').operator()<CR>]],
					mode = { "n", "x" },
				},
			},
			config = true,
		},
		{
			"mopp/vim-operator-convert-case",
			dependencies = {
				"kana/vim-operator-user",
			},
			keys = {
				{
					"<Leader>cl",
					"<Plug>(operator-convert-case-lower-camel)",
					mode = { "n", "x" },
				},
				{
					"<Leader>cu",
					"<Plug>(operator-convert-case-upper-camel)",
					mode = { "n", "x" },
				},
				{
					"<Leader>sl",
					"<Plug>(operator-convert-case-lower-snake)",
					mode = { "n", "x" },
				},
				{
					"<Leader>su",
					"<Plug>(operator-convert-case-upper-snake)",
					mode = { "n", "x" },
				},
			},
		},
		{
			"windwp/nvim-autopairs",
			event = { "InsertEnter" },
			config = true,
		},
		{
			"windwp/nvim-ts-autotag",
			event = { "InsertEnter" },
			config = true,
		},
		{
			"Wansmer/treesj",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			keys = {
				{
					"<Leader>t",
					[[<Cmd>lua require('treesj').toggle()<CR>]],
					mode = { "n" },
				},
			},
			opts = {
				use_default_keymaps = false,
			},
		},
		{
			"monaqa/dial.nvim",
			keys = {
				{
					"+",
					[[<Plug>(dial-increment)]],
					mode = { "n", "x" },
				},
				{
					"-",
					[[<Plug>(dial-decrement)]],
					mode = { "n", "x" },
				},
			},
		},
		{
			"numToStr/Comment.nvim",
			dependencies = {
				{
					"JoosepAlviste/nvim-ts-context-commentstring",
					dependencies = { "nvim-treesitter/nvim-treesitter" },
					opts = {
						enable_autocmd = false,
					},
				},
			},
			event = { "VeryLazy" },
			config = function()
				require("Comment").setup({
					pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
				})
			end,
		},
		-- Search
		{
			"kevinhwang91/nvim-hlslens",
			keys = {
				{
					"<Leader>/",
					[[*<Cmd>lua require('hlslens').start()<CR>]],
					mode = { "n" },
				},
			},
			config = true,
		},
		-- Move
		{
			"smoka7/hop.nvim",
			keys = {
				{
					"<Leader>f",
					[[<Cmd>lua require('hop').hint_words()<CR>]],
					mode = { "n", "x" },
					remap = true,
				},
			},
			opts = {
				keys = "etovxqpdygfblzhckisuran",
			},
		},
		-- Highlight
		{
			"mvllow/modes.nvim",
			event = { "VeryLazy" },
			config = true,
		},
		{
			"folke/todo-comments.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope.nvim",
			},
			event = { "VeryLazy" },
			config = function()
				require("todo-comments").setup({})
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)t", [[<Cmd>TodoTelescope<CR>]])
				vim.keymap.set("n", "<Leader>qt", [[<Cmd>TodoQuickFix<CR>]])
			end,
		},
		{
			"norcalli/nvim-colorizer.lua",
			event = { "VeryLazy" },
			config = function()
				require("colorizer").setup()
			end,
		},
		-- Jump
		{
			"rgroli/other.nvim",
			cmd = "Other",
			config = function()
				require("other-nvim").setup({
					mappings = {
						"rails",
					},
				})
			end,
		},
		-- Quickfix
		{
			"kevinhwang91/nvim-bqf",
			ft = { "qf" },
			config = true,
		},
		{
			"gabrielpoca/replacer.nvim",
			ft = { "qf" },
			config = function()
				require("replacer").setup()
				vim.api.nvim_create_autocmd("FileType", {
					pattern = "qf",
					callback = function()
						local opts = { save_on_write = false, rename_files = false }
						vim.keymap.set("n", "<leader>r", function()
							require("replacer").run(opts)
						end, { buffer = true })
						vim.keymap.set("n", "<leader>w", function()
							require("replacer").save(opts)
						end, { buffer = true })
					end,
				})
			end,
		},
		-- Lastplace
		{
			"farmergreg/vim-lastplace",
			event = { "BufReadPre" },
		},
		-- Markdown
		{
			"OXY2DEV/markview.nvim",
			ft = "markdown",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
		},
		-- Notification
		{
			"rcarriga/nvim-notify",
			event = { "VeryLazy" },
			config = function()
				local notify = require("notify")
				notify.setup({
					background_colour = "#282828",
				})
				vim.notify = notify
			end,
		},
		-- Colorscheme
		{
			"ellisonleao/gruvbox.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				vim.o.background = "dark"
				vim.cmd.colorscheme("gruvbox")
			end,
		},
	},
})
