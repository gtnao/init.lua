-- Options
vim.opt.tabstop = 2

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.showmatch = true

vim.opt.number = true

vim.opt.scrolloff = 5

vim.opt.virtualedit = "block"

vim.opt.swapfile = false

vim.opt.termguicolors = true

-- Keymaps
vim.g.mapleader = " "
vim.keymap.set({ "n", "x" }, "<Leader>", "<Nop>")
vim.keymap.set({ "n", "x" }, "<Plug>(ff)", "<Nop>")
vim.keymap.set({ "n", "x" }, ",", "<Plug>(_FuzzyFinder)")

vim.keymap.set({ "n", "x" }, ";", ":")
vim.keymap.set({ "n", "x" }, ":", ";")

vim.keymap.set({ "n" }, "<Leader>w", [[<Cmd>update<CR>]], { silent = true })
vim.keymap.set({ "n" }, "<Leader>q", [[<Cmd>quit<CR>]], { silent = true })

vim.keymap.set({ "n", "x" }, "<Leader>h", "^")
vim.keymap.set({ "n", "x" }, "<Leader>l", "$")

vim.keymap.set("n", "<ESC><ESC>", [[<Cmd>nohlsearch<CR>]], { silent = true })

vim.keymap.set("n", "ZZ", "<Nop>")
vim.keymap.set("n", "ZQ", "<Nop>")

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
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-nvim-lsp-signature-help",
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-cmdline",
				"hrsh7th/cmp-nvim-lsp-document-symbol",
				"onsails/lspkind-nvim",
			},
			config = function()
				local cmp = require("cmp")
				local lspkind = require("lspkind")
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
					}, {
						{ name = "buffer" },
					}),
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
			event = { "VeryLazy" },
			config = true,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = {
				"williamboman/mason.nvim",
				"neovim/nvim-lspconfig",
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
				mason_lspconfig.setup_handlers({
					function(server_name)
						lspconfig[server_name].setup()
					end,
					["lua_ls"] = function()
						lspconfig.lua_ls.setup({
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
			opts = {
				lightbulb = {
					enable = false,
				},
				symbol_in_winbar = {
					enable = false,
				},
			},
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
			tag = "0.1.8",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{
					"nvim-telescope/telescope-fzf-native.nvim",
					build = "make",
				},
				"crispgm/telescope-heading.nvim",
			},
			event = { "VimEnter" },
			config = function()
				local telescope = require("telescope")
				telescope.setup({
					extensions = {
						heading = {
							treesitter = true,
						},
					},
				})
				telescope.load_extension("fzf")
				telescope.load_extension("heading")
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)f", [[<Cmd>Telescope find_files<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)o", [[<Cmd>Telescope oldfiles<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)s", [[<Cmd>Telescope live_grep<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)b", [[<Cmd>Telescope buffers<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder);", [[<Cmd>Telescope command_history<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)/", [[<Cmd>Telescope search_history<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)q", [[<Cmd>Telescope quickfix<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)d", [[<Cmd>Telescope diagnostics<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)n", [[<Cmd>Telescope notify<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)g", [[<Cmd>Telescope git_status<CR>]], { silent = true })
				vim.keymap.set("n", "<Plug>(_FuzzyFinder)h", [[<Cmd>Telescope heading<CR>]], { silent = true })
			end,
		},
		-- Filer
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
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
				vim.keymap.set({ "n" }, "<C-n>", [[<Cmd>Neotree toggle reveal<CR>]], { silent = true })
			end,
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
			event = { "VeryLazy" },
			init = function()
				vim.keymap.set("n", "<Leader>g", [[<Cmd>Neogit<CR>]], { silent = true })
			end,
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
			version = "*",
			event = { "VimEnter" },
			config = true,
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
			config = true,
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
				require("alpha").setup(startify.config)
			end,
		},
		-- Edit
		{
			"gbprod/substitute.nvim",
			event = { "VeryLazy" },
			config = function()
				local substitute = require("substitute")
				substitute.setup()
				vim.keymap.set({ "n", "x" }, "_", substitute.operator)
			end,
		},
		{
			"kylechui/nvim-surround",
			version = "*",
			event = { "VeryLazy" },
			config = true,
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
			"monaqa/dial.nvim",
			event = { "VeryLazy" },
			init = function()
				vim.keymap.set({ "n", "x" }, "+", [[<Plug>(dial-increment)]])
				vim.keymap.set({ "n", "x" }, "-", [[<Plug>(dial-decrement)]])
			end,
		},
		{
			"Wansmer/treesj",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			event = { "VeryLazy" },
			config = function()
				require("treesj").setup({
					use_default_keymaps = false,
				})
				vim.keymap.set({ "n" }, "<Leader>t", require("treesj").toggle)
			end,
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
			event = { "VeryLazy" },
			config = true,
		},
		-- Move
		{
			"phaazon/hop.nvim",
			branch = "v2",
			opts = {
				keys = "etovxqpdygfblzhckisuran",
			},
			event = { "VeryLazy" },
			init = function()
				vim.keymap.set("", "fw", [[<Cmd>lua require('hop').hint_words()<CR>]], { silent = true, remap = true })
			end,
		},
		-- Highlight
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			event = { "VeryLazy" },
			config = true,
		},
		{
			"machakann/vim-highlightedyank",
			event = { "TextYankPost" },
			init = function()
				vim.g.highlightedyank_highlight_duration = 300
			end,
		},
		{
			"mvllow/modes.nvim",
			tag = "v0.2.1",
			event = { "VeryLazy" },
			config = true,
		},
		{
			"folke/todo-comments.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			event = { "VeryLazy" },
			config = true,
		},
		{
			"norcalli/nvim-colorizer.lua",
			event = { "VeryLazy" },
			config = true,
		},
		-- Quickfix
		{
			"kevinhwang91/nvim-bqf",
			ft = { "qf" },
			config = true,
		},
		-- Session
		{
			"farmergreg/vim-lastplace",
			event = { "BufReadPre" },
		},
		-- Notification
		{
			"rcarriga/nvim-notify",
			event = { "VeryLazy" },
			config = function()
				vim.notify = require("notify")
				vim.keymap.set("n", "<BS>", function()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						if
							vim.fn.bufexists(buf) == 1
							and vim.api.nvim_get_option_value("filetype", { buf = buf }) == "notify"
						then
							vim.api.nvim_win_close(win, { force = false })
						end
					end
				end, { silent = true })
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
