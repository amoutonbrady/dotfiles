local keymap = vim.api.nvim_set_keymap

-- @description An awesome description
local nmap = function(...) keymap('n', ...) end
local vmap = function(...) keymap('v', ...) end
local imap = function(...) keymap('i', ...) end
local xmap = function(...) keymap('x', ...) end
local tmap = function(...) keymap('t', ...) end

vim.o.completeopt = "menuone,noselect"
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.g.mapleader = ","
vim.g.netrw_menu = 0
vim.g.netrw_banner = 0

-- https://keleshev.com/my-book-writing-setup/#:~:text=here%20is%20virtualedit%3A-,set%20virtualedit%3Dall,-It%20allows%20to
vim.g.virtualedit = "all"
-- vim.wo.scrolloff = 999

vim.cmd('set iskeyword+=-') -- treat dash separated words as a word text object"
vim.cmd('set shortmess+=c') -- Don't pass messages to |ins-completion-menu|.
vim.cmd('set inccommand=split') -- Make substitution work in realtime
vim.o.title = true
vim.o.titlestring = "%<%F%=%l/%L - nvim"
vim.cmd('set whichwrap+=<,>,[,],h,l') -- move to next line with theses keys
vim.o.pumheight = 10 -- Makes popup menu smaller
vim.o.cmdheight = 2 -- More space for displaying messages
vim.o.mouse = "a" -- Enable your mouse
vim.o.splitbelow = true -- Horizontal splits will automatically be below
vim.o.termguicolors = true -- set term giu colors most terminals support this
vim.o.splitright = true -- Vertical splits will automatically be to the right
vim.o.background = "dark"
vim.o.t_Co = "256" -- Support 256 colors
vim.o.conceallevel = 0 -- So that I can see `` in markdown files
vim.cmd('set ts=2') -- Insert 2 spaces for a tab
vim.cmd('set sw=2') -- Change the number of space characters inserted for indentation
vim.bo.expandtab = true -- Converts tabs to spaces
vim.bo.smartindent = true -- Makes indenting smart
vim.wo.cursorline = true -- Enable highlighting of the current line
vim.o.backup = false -- This is recommended by coc
vim.o.writebackup = false -- This is recommended by coc
vim.wo.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.o.updatetime = 300 -- Faster completion
vim.o.timeoutlen = 750 -- By default timeoutlen is 1000 ms

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
    -- Packer can manage itself
    use {'wbthomason/packer.nvim', opt = true}

    use {
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = function() require('gitsigns').setup() end
    }

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
    }

    use {
        'blackCauldron7/surround.nvim',
        config = function() require"surround".setup {} end
    }

    -- https://github.com/windwp/nvim-ts-autotag
    use {'windwp/nvim-ts-autotag'}

    use {'mg979/vim-visual-multi', branch = 'master'}

    -- https://github.com/p00f/nvim-ts-rainbow
    use {'p00f/nvim-ts-rainbow'}

    -- https://github.com/b3nj5m1n/kommentary
    use {'b3nj5m1n/kommentary'}

    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

    -- Theme
    use {'dracula/vim', as = 'dracula'}
    -- use 'shaunsingh/moonlight.nvim'

    use {'neovim/nvim-lspconfig'}
    use {'ray-x/lsp_signature.nvim'}
    use {'kabouzeid/nvim-lspinstall'}
    use {
        'glepnir/lspsaga.nvim',
        config = function()
          local saga = require 'lspsaga'
          saga.init_lsp_saga()
        end
    }
    use {
        'folke/lsp-colors.nvim',
        config = function()
          require("lsp-colors").setup()
        end
    }
    use {
        "folke/lsp-trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
          require("trouble").setup {}
        end
    }

    use {'hrsh7th/nvim-compe'}
    use {'hrsh7th/vim-vsnip'}
    use {'hrsh7th/vim-vsnip-integ'}

    use {
        'windwp/nvim-autopairs',
        config = function() require'nvim-autopairs'.setup {} end
    }
    use {'prettier/vim-prettier', run = 'yarn install' }
    use {
        "numtostr/FTerm.nvim",
        config = function()
            require("FTerm").setup()
        end
    }

    -- Git stuff
    use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
end)

require'nvim-treesitter.configs'.setup {
    ensure_installed = "all",
    highlight = {
        enable = true -- false will disable the whole extension
    },
    autotag = {enable = true},
    rainbow = {
        enable = true,
        extended_mode = true -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    }
}

-- keymaps
local on_attach = function(client)
  require "lsp_signature".on_attach()

  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
    augroup lsp_document_highlight
    autocmd! * <buffer>
    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]], false)
  end
end

-- Configure lua language server for neovim development
local lua_settings = {
  Lua = {
    runtime = {
      -- LuaJIT in the case of Neovim
      version = 'LuaJIT',
      path = vim.split(package.path, ';'),
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {'vim'},
    },
    workspace = {
      preloadFileSize = 10000,
      -- Make the server aware of Neovim runtime files
      library = {
        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
      },
    },
  }
}

-- config that activates keymaps and enables snippet support
local function make_config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  return {
    -- enable snippet support
    capabilities = capabilities,
    -- map buffer local keybindings when the language server attaches
    on_attach = on_attach,
  }
end

-- lsp-install
local function setup_servers()
  require'lspinstall'.setup()

  -- get all installed servers
  local servers = require'lspinstall'.installed_servers()

  for _, server in pairs(servers) do
    local config = make_config()

    -- language specific config
    if server == "lua" then
      config.settings = lua_settings
    end

    require'lspconfig'[server].setup(config)
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

require'compe'.setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,

    source = {
        path = true,
        buffer = true,
        calc = true,
        nvim_lsp = true,
        nvim_lua = true,
        vsnip = true
    }
}

require'neogit'.setup {}


vim.g.dracula_colorterm = 0
vim.cmd [[colorscheme dracula]]
vim.cmd [[highlight Normal ctermbg=none]]
vim.cmd [[highlight NonText ctermbg=none]]

imap('<c-space>', "compe#complete()", {noremap = true, silent = true, expr = true})
imap('<cr>', "compe#confirm('<cr>')", {noremap = true, silent = true, expr = true})
imap('<c-e>', "compe#close('<c-e>')", {noremap = true, silent = true, expr = true})
imap('<c-f>', "compe#scroll({ 'delta': +4 })')", {noremap = true, silent = true, expr = true})
imap('<c-d>', "compe#scroll({ 'delta': -4 })')", {noremap = true, silent = true, expr = true})
imap('<c-d>', "compe#scroll({ 'delta': -4 })')", {noremap = true, silent = true, expr = true})

nmap('<leader>fh', '<cmd>Telescope help_tags<cr>', {noremap = true})
nmap('<leader>ff', '<cmd>Telescope find_files<cr>', {noremap = true})
nmap('<leader>fg', '<cmd>Telescope live_grep<cr>', {noremap = true})
nmap('<leader>fb', '<cmd>Telescope buffers<cr>', {noremap = true})
nmap('<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', {noremap = true})

-- no hl
nmap('<cr>', [[{-> v:hlsearch ? ":nohl\<cr>" : "\<cr>"}()]], {expr = true })
nmap('<leader>n', '<cmd>noh<cr>', {noremap = true, silent = true})

nmap('<c-up>', '<cmd>resize -2<cr>', {noremap = true, silent = true})
nmap('<c-down>', '<cmd>resize +2<cr>', {noremap = true, silent = true})
nmap('<c-left>', '<cmd>vertical resize -2<cr>', {noremap = true, silent = true})
nmap('<c-right>', '<cmd>vertical resize +2<cr>', {noremap = true, silent = true})

-- better indenting
vmap('<', '<gv', {noremap = true, silent = true})
vmap('>', '>gv', {noremap = true, silent = true})

-- tab switch buffer
nmap('<tab>', ':bnext<cr>', {noremap = true, silent = true})
nmap('<s-tab>', ':bprevious<cr>', {noremap = true, silent = true})

-- move selected line / block of text in visual mode
xmap('<c-j>', ':move \'>+1<cr>gv-gv', {noremap = true, silent = true})
xmap('<c-k>', ':move \'<-2<cr>gv-gv', {noremap = true, silent = true})

imap('<c-v>', '<esc>"+pa', {noremap = true, silent = true})
vmap('<c-c>', '"+y', {noremap = true, silent = true})
imap('<c-s>', '<cmd>w!<cr>', {noremap = true, silent = true})
nmap('<c-s>', '<cmd>w!<cr>', {noremap = true, silent = true})
vmap('<c-s>', '<cmd>w!<cr>', {noremap = true, silent = true})

vmap(';', ':', {noremap = true})
nmap(';', ':', {noremap = true})
xmap(';', ':', {noremap = true})
tmap(';', ':', {noremap = true})

nmap('<space>', '/', {noremap = true})
vmap('<space>', '/', {noremap = true})

nmap('k', 'gk', {noremap = true})
vmap('k', 'gk', {noremap = true})
nmap('j', 'gj', {noremap = true})
vmap('j', 'gj', {noremap = true})

-- Prettier
nmap('<leader><leader>', '<cmd>Prettier<cr>', {noremap = true, silent = true})

-- LSP Saga
nmap('<leader>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<cr>", {noremap = true, silent = true})
vmap('<leader>ca', ":<c-u>lua require('lspsaga.codeaction').range_code_a<silent>ction()<cr>", {noremap = true, silent = true})
nmap('gh', "<cmd>lua require'lspsaga.provider'.lsp_finder()<cr>", {noremap = true, silent = true})
nmap('K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<cr>", {noremap = true, silent = true})
nmap('<c-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>", {noremap = true, silent = true})
nmap('<c-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>", {noremap = true, silent = true})
nmap('gs', "<cmd>lua require('lspsaga.signaturehelp').signature_help()<cr>", {noremap = true, silent = true})
nmap('gr', "<cmd>lua require('lspsaga.rename').rename()<cr>", {noremap = true, silent = true})
nmap('gd', "<cmd>lua vim.lsp.buf.definition()<cr>", {noremap = true, silent = true})
nmap('<c-j>', "<cmd>lua require('FTerm').open()<cr>", {noremap = true, silent = true})
tmap('<c-j>', [[<c-\><c-n><cmd>lua require('FTerm').close()<cr>]], {noremap = true, silent = true})
nmap('<leader>cd', "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<cr>", {noremap = true, silent = true})

-- Trouble
nmap("<leader>xx", "<cmd>LspTroubleToggle<cr>", {silent = true, noremap = true})
nmap("<leader>xw", "<cmd>LspTroubleToggle lsp_workspace_diagnostics<cr>", {silent = true, noremap = true})
nmap("<leader>xd", "<cmd>LspTroubleToggle lsp_document_diagnostics<cr>", {silent = true, noremap = true})
nmap("<leader>xl", "<cmd>LspTroubleToggle loclist<cr>", {silent = true, noremap = true})
nmap("<leader>xq", "<cmd>LspTroubleToggle quickfix<cr>", {silent = true, noremap = true})
nmap("gR", "<cmd>LspTrouble lsp_references<cr>", {silent = true, noremap = true})
