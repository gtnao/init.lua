-- Options
vim.opt.tabstop = 2

-- Keymaps
vim.g.mapleader = " "
vim.keymap.set({ "n", "x" }, "<Leader>", "<Nop>")

vim.keymap.set({ "n", "x" }, ";", ":")
vim.keymap.set({ "n", "x" }, ":", ";")

vim.keymap.set({ "n" }, "<Leader>w", [[<Cmd>update<CR>]], { silent = true })
vim.keymap.set({ "n" }, "<Leader>q", [[<Cmd>quit<CR>]], { silent = true })

-- Plugin Manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	install = { colorscheme = { "habamax" } },
	checker = { enabled = true },
	spec = {
		-- Completion
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-cmdline",
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
						{ name = "nvim_lua" },
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
					}),
				})
			end,
		},
		-- LSP
		{
			"williamboman/mason.nvim",
			config = true,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = {
				"williamboman/mason.nvim",
				"neovim/nvim-lspconfig",
			},
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
			"nvimtools/none-ls.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
		},
		{
			"jay-babu/mason-null-ls.nvim",
			dependencies = {
				"williamboman/mason.nvim",
				"nvimtools/none-ls.nvim",
			},
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
			"j-hui/fidget.nvim",
			config = true,
		},
		-- Treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function()
				local configs = require("nvim-treesitter.configs")
				configs.setup({
					ensure_installed = {
						"lua",
					},
					sync_install = false,
					highlight = {
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
			},
			config = true,
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
			config = true,
		},
		-- AI
		-- Nodejs is required.
		-- First, execute `Copilot auth`.
		{
			"zbirenbaum/copilot.lua",
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
			config = true,
		},
		{
			"lewis6991/gitsigns.nvim",
			config = true,
		},
		-- Cmdline
		{
			"folke/noice.nvim",
			dependencies = {
				"MunifTanjim/nui.nvim",
				"rcarriga/nvim-notify",
			},
			opts = {
				popupmenu = {
					backend = "cmp",
				},
			},
		},
		-- View
		-- Statusline
		{
			"nvim-lualine/lualine.nvim",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			config = true,
		},
		-- Bufferline
		{
			"akinsho/bufferline.nvim",
			version = "*",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			config = true,
		},
		{
			"petertriho/nvim-scrollbar",
			config = true,
		},
		-- Startup
		{
			"goolord/alpha-nvim",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			config = function()
				local startify = require("alpha.themes.startify")
				startify.file_icons.provider = "devicons"
				require("alpha").setup(startify.config)
			end,
		},
		-- Edit
		{
			"gbprod/substitute.nvim",
			config = function()
				local substitute = require("substitute")
				substitute.setup()
				vim.keymap.set({ "n", "x" }, "_", substitute.operator)
			end,
		},
		{
			"kylechui/nvim-surround",
			version = "*",
			config = true,
		},
		{
			"windwp/nvim-autopairs",
			config = true,
		},
		{
			"monaqa/dial.nvim",
			init = function()
				vim.keymap.set({ "n", "x" }, "+", [[<Plug>(dial-increment)]])
				vim.keymap.set({ "n", "x" }, "-", [[<Plug>(dial-decrement)]])
			end,
		},
		-- Search
		{
			"kevinhwang91/nvim-hlslens",
			config = true,
		},
		-- Highlight
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			config = true,
		},
		{
			"machakann/vim-highlightedyank",
			init = function()
				vim.g.highlightedyank_highlight_duration = 300
			end,
		},
		{
			"mvllow/modes.nvim",
			tag = "v0.2.1",
			config = true,
		},
		{
			"folke/todo-comments.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			config = true,
		},
		{
			"norcalli/nvim-colorizer.lua",
			config = true,
		},
		-- Quickfix
		{
			"kevinhwang91/nvim-bqf",
			config = true,
		},
		-- Notification
		{
			"rcarriga/nvim-notify",
			config = function()
				vim.notify = require("notify")
			end,
		},
		-- Colorscheme
		{
			"ellisonleao/gruvbox.nvim",
			priority = 1000,
			config = function()
				vim.o.background = "dark"
				vim.cmd([[colorscheme gruvbox]])
			end,
		},
	},
})
