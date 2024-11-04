-- bootstrap lazy.vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ' '

require("lazy").setup({
    -- load and set theme it right away
    {
        "catppuccin/nvim",
	    lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function() 
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        "liuchengxu/vista.vim",
        ft = { "rust", "markdown" },
        event = { "BufReadPre", "BufNewFile" },
    },
    { 
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim"},
        config = function(plugin, opts)
            require "telescope".setup {
                defaults = {
                    layout_strategy = "vertical",
                    layout_config = {
                        height = vim.o.lines, -- maximally available lines
                        --width = vim.o.columns, -- maximally available columns
                        width = 0.6,
                        prompt_position = "bottom",
                        preview_height = 0.6, -- 60% of available lines
                    },
                    prompt_prefix = " ",
                },
            }
        end,
        keys = {
            { "<leader>f", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
            { "<leader>g", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
            { "<leader>r", "<cmd>Telescope lsp_references<CR>", desc = "Find References" },
            { "<leader>s", "<cmd>Telescope lsp_document_symbols ignore_symbols={'field','enummember','function'}<CR>", desc = "List Symbols" },
        }
    },
    {
        "hrsh7th/nvim-cmp",
        name = 'cmp',
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
        },
        config = function(plugin, opts)
          vim.cmd([[set shortmess+=c]])

          local cmp = require("cmp")
          cmp.setup({
          preselect = 'item',
          completion = {
              completeopt = 'menuone,noinsert,menu'
          },
          snippet = {
            expand = function(args)
                vim.snippet.expand(args.body)
            end,
          },
            mapping = {
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            }),
         },
             sources = {
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "path" },
            },
          })
        end

    },
    {
        "godlygeek/tabular",
        ft = { "markdown" },
        name = "tabular",
    },
    {
        "preservim/vim-markdown",
        ft = { "markdown" },
        name = "vim-markdown",
        config = function(_, ops) 
            vim.g.markdown_no_default_mappings = 1
        end,
    },
    {
        "tikhomirov/vim-glsl",
        ft = { "glsl" },
        name = "vim-glsl",
    },
    {
        "Canop/nvim-bacon",
        ft = { "rust" },
        name = "bacon",
        config = function(_, ops)
            vim.keymap.set("n", "dl", ":BaconList<CR>", {noremap = false })
            vim.keymap.set("n", "dn", ":BaconLoad<CR>:w<CR>:BaconNext<CR>", {noremap = false })
            vim.keymap.set("n", "dp", ":BaconLoad<CR>:w<CR>:BaconPrevious<CR>", {noremap = false })
        end,
    },
    --lsp
    {
        "neovim/nvim-lspconfig",
        ft = { "rust", "markdown", "wgsl" },
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function(_, opts)
            local capabilities = require("cmp_nvim_lsp").default_capabilities() 
            for server, server_opts in pairs(opts.servers) do 
                server_opts.capabilities = capabilities
                require("lspconfig")[server].setup(server_opts)
            end

            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = true,
                    style = 'minimal',
                    border = 'rounded',
                    source = 'always',
                    header = '',
                    prefix = '',
                },
            })

            local sign = function(opts)
                vim.fn.sign_define(opts.name, {
                    texthl = opts.name,
                    text = opts.text,
                    numhl = ''
                })
            end

            sign({name = 'DiagnosticSignError', text = '✘'})
            sign({name = 'DiagnosticSignWarn', text = '▲'})
            sign({name = 'DiagnosticSignHint', text = '⚑'})
            sign({name = 'DiagnosticSignInfo', text = ''})

            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern={"*.rs"},
                callback=function() vim.lsp.buf.format({async=false}) end,
            }) 
        end,
        opts = {
            servers = {
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            check = { command = "clippy"},
                            diagnostics = { enable = true },
                            cargo = { allFeatures = true },
                        },
                    },
                    on_attach = function(bufnr) 
                        vim.keymap.set("n", "K", vim.lsp.buf.hover, {noremap = false })
                        vim.keymap.set("n", "gK", vim.diagnostic.open_float, { noremap = false })
                        vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { noremap = false })
                        vim.keymap.set("n", "gr", vim.lsp.buf.rename, { noremap = false })
                        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { noremap = false })
                        vim.keymap.set("n", "g]", vim.lsp.buf.definition, { noremap = false })
                        vim.keymap.set("n", "g[", vim.lsp.buf.declaration, { noremap = false })
                        vim.keymap.set("n", "gs", vim.lsp.buf.workspace_symbol, { noremap = false })
                        vim.keymap.set("n", "<leader>t", ":Vista!!<CR>", { noremap = false })
                        vim.keymap.set("n", "gh", function() 
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                        end, { noremap = false })
                    end
                },
                marksman = {
                    on_attach = function(bufnr) 
                        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = false })
                        vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { noremap = false })
                        vim.keymap.set("n", "gs", vim.lsp.buf.workspace_symbol, { noremap = false })
                    end
                },
                wgsl_analyzer = {
                }
            },
        },
    }
})

vim.cmd([[filetype plugin indent on]])
vim.cmd([[filetype plugin on]])                                                                                                                                         

-- general settings 
vim.opt.textwidth = 120
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.title = true
vim.opt.conceallevel = 3
vim.opt.clipboard:append { 'unnamedplus' }
vim.opt.shada = ""  -- disable shada file. No need to keep commands/jump lists or buffers around 
vim.opt.hlsearch = false  -- highlighting search is annoying

--DEBUGGER     
vim.cmd([[packadd termdebug]])

--vertical split
vim.g.termdebug_wide = 1

-- buffer movement
vim.keymap.set("n", "<leader>b", "<cmd>bnext<cr>", { noremap = false })
vim.keymap.set("n", "<leader>p", "<cmd>bprev<cr>", { noremap = false })
vim.keymap.set("n", "<leader><leader>", "<cmd>b#<CR>", { noremap = false })

-- map it so that ESC will go to normal mode,
-- even when TermDebug is active
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {})

-- center cursor after scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = false })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = false })
-- vim.keymap.set("v", "n", "", { noremap = false })

-- -- auto close quotes, brackets, etc
-- vim.keymap.set("i", "(", "()<left>", { noremap = false })
-- vim.keymap.set("i", "{", "{}<left>", { noremap = false })
-- vim.keymap.set("i", "\"", "\"\"<left>", { noremap = false })
-- vim.keymap.set("i", "[", "[]<left>", { noremap = false })


vim.cmd [[
let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction

nnoremap <S-h> :call ToggleHiddenAll()<CR>
]]

-- Auto-create parent directories (except for URIs "://").
vim.api.nvim_create_autocmd({"BufWritePre", "FileWritePre"}, {
  pattern = "*",
  callback = function()
    local file_path = vim.fn.expand("<afile>:p:h")
    if not file_path:match("://") then
      vim.fn.mkdir(file_path, "p")
    end
  end
})
