local LEADER_KEY = " "

vim.g.mapleader = LEADER_KEY

vim.o.path = "**"

vim.o.number = true
vim.o.relativenumber = true
vim.o.background = "dark"
vim.o.title = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.o.completeopt = "menu,menuone,noselect"
vim.o.cmdheight = 2

vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.ignorecase = true

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.backup = false
vim.o.swapfile = false

vim.o.signcolumn = "yes"

vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

local lsp = require("nvim-lsp-installer")

require("paq")({
	-- Let Paq manage itself
	"savq/paq-nvim",

	"nvim-treesitter/nvim-treesitter",

	-- Mind the semi-colons
	"neovim/nvim-lspconfig",
	"williamboman/nvim-lsp-installer",

	"kyazdani42/nvim-web-devicons",

	-- https://github.com/projekt0n/github-nvim-theme
	"projekt0n/github-nvim-theme",
	"folke/lsp-colors.nvim",

	"folke/trouble.nvim",
	"nvim-lua/plenary.nvim",
	"jose-elias-alvarez/null-ls.nvim",
	"nvim-telescope/telescope.nvim",

	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp",
	"dcampos/nvim-snippy",
	"dcampos/cmp-snippy",

	"p00f/nvim-ts-rainbow",

	"lewis6991/gitsigns.nvim",
	"numToStr/Comment.nvim",
	"folke/todo-comments.nvim",
	"tversteeg/registers.nvim",

	"romgrk/barbar.nvim",

	"mattn/emmet-vim",
})

vim.g.user_emmet_mode = "a"

require("todo-comments").setup()
require("Comment").setup()
require("gitsigns").setup()

local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.completion.spell,
		null_ls.builtins.code_actions.gitsigns,
		-- null_ls.builtins.diagnostics.eslit,
	},
})

local on_attach = function(_, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	-- Enable completion triggered by <c-x><c-o>
	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	local opts = { noremap = true, silent = true }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", "<Leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<Leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	buf_set_keymap("n", "<Leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
	buf_set_keymap("n", "<Leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	buf_set_keymap("n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "<Leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	buf_set_keymap("n", "<Leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", "<Leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	buf_set_keymap("n", "<Leader>p", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp.on_server_ready(function(server)
	local opts = {
		on_attach = on_attach,
	}

	-- (optional) Customize the options passed to the server
	if server.name == "sumneko_lua" then
		opts.settings = {
			Lua = {
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim" },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = vim.api.nvim_get_runtime_file("", true),
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			},
		}
	end

	server:setup(opts)
end)

-- Setup nvim-cmp.
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require("snippy").expand_snippet(args.body) -- For `snippy` users.
		end,
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end,
		["<S-Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

require("nvim-treesitter.configs").setup({
	ensure_installed = "maintained",
	sync_install = true,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},

	indent = {
		enable = true,
	},

	rainbow = {
		enable = true,
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
	},
})

require("nvim-web-devicons").setup()
require("github-theme").setup()
require("lsp-colors").setup()
require("trouble").setup()

-- vim.o.foldmethod = "indent"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"

vim.api.nvim_set_keymap("n", "<C-s>", ":w<Cr>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-s>", "<Esc>:w<Cr>a", { noremap = true })
vim.api.nvim_set_keymap("v", "<C-s>", "<Esc>:w<Cr>gv", { noremap = true })

vim.api.nvim_set_keymap("n", "<Leader>r", ":so %<Cr>", { noremap = true })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true })
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true })

vim.api.nvim_set_keymap("n", "<Leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true })

-- Barbar stuff
vim.api.nvim_set_keymap("n", "<A-Right>", ":BufferPrevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-Left>", ":BufferNext<CR>", { noremap = true, silent = true })
-- Goto buffer in position...
vim.api.nvim_set_keymap("n", "<A-1>", ":BufferGoto 1<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-2>", ":BufferGoto 2<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-3>", ":BufferGoto 3<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-4>", ":BufferGoto 4<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-5>", ":BufferGoto 5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-6>", ":BufferGoto 6<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-7>", ":BufferGoto 7<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-8>", ":BufferGoto 8<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-9>", ":BufferGoto 9<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-0>", ":BufferLast<CR>", { noremap = true, silent = true })
-- Close buffer
vim.api.nvim_set_keymap("n", "<A-w>", ":BufferClose<CR>", { noremap = true, silent = true })
-- Wipeout buffer
--                 :BufferWipeout<CR>
-- Close commands
--                 :BufferCloseAllButCurrent<CR>
--                 :BufferCloseBuffersLeft<CR>
--                 :BufferCloseBuffersRight<CR>
-- Magic buffer-picking mode
vim.api.nvim_set_keymap("n", "<A-p>", ":BufferPick<CR>", { noremap = true, silent = true })
