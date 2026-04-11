vim.pack.add {
    { src = "https://github.com/rose-pine/neovim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/ThePrimeagen/harpoon", version="harpoon2" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/tpope/vim-sleuth" },
}
vim.pack.add {
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/hrsh7th/cmp-nvim-lsp",
    "https://github.com/hrsh7th/cmp-buffer",
    "https://github.com/hrsh7th/cmp-path",
    "https://github.com/hrsh7th/cmp-cmdline",
    "https://github.com/hrsh7th/nvim-cmp",
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/saadparwaiz1/cmp_luasnip",
    "https://github.com/j-hui/fidget.nvim",
}

function ColorMyPencils(color)
	color = color or "rose-pine-moon"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

local function setup()
    -- color scheme
    require('rose-pine').setup({
        disable_background = true,
        styles = {
            italic = false,
        },
    })

    ColorMyPencils();

    -- telescope
    require('telescope').setup({})

    local tbuiltin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>pf', tbuiltin.find_files, {})
    vim.keymap.set('n', '<C-p>', tbuiltin.git_files, {})
    vim.keymap.set('n', '<leader>pws', function()
        local word = vim.fn.expand("<cword>")
        tbuiltin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>pWs', function()
        local word = vim.fn.expand("<cWORD>")
        tbuiltin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>ps', function()
        tbuiltin.grep_string({ search = vim.fn.input("Grep > ") })
    end)
    vim.keymap.set('n', '<leader>vh', tbuiltin.help_tags, {})

    -- treesitter
    require("nvim-treesitter").install({
        "vimdoc", "c", "lua", "rust",
        "jsdoc", "bash", "python", "zig"
    })

    -- harpoon
    local harpoon = require("harpoon")

    harpoon:setup()

    vim.keymap.set("n", "<leader>A", function() harpoon:list():prepend() end)
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

    vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
    vim.keymap.set("n", "<leader><C-h>", function() harpoon:list():replace_at(1) end)
    vim.keymap.set("n", "<leader><C-t>", function() harpoon:list():replace_at(2) end)
    vim.keymap.set("n", "<leader><C-n>", function() harpoon:list():replace_at(3) end)
    vim.keymap.set("n", "<leader><C-s>", function() harpoon:list():replace_at(4) end)

    -- gitsigns
    require('gitsigns').setup({
       signs = {
         add = { text = '+' },
         change = { text = '~' },
         delete = { text = '_' },
         topdelete = { text = '‾' },
         changedelete = { text = '~' },
       },
    })
end

setup()

local function setup_lsp()
    require("conform").setup({
        formatters_by_ft = {
        }
    })
    local cmp = require('cmp')
    local cmp_lsp = require("cmp_nvim_lsp")
    local luasnip = require('luasnip')
    local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities())

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = {
            "lua_ls", "pyright"
        },
        handlers = {
            function(server_name) -- default handler (optional)
                require("lspconfig")[server_name].setup {
                    capabilities = capabilities
                }
            end,

            zls = function()
                local lspconfig = require("lspconfig")
                lspconfig.zls.setup({
                    root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                    settings = {
                        zls = {
                            enable_inlay_hints = true,
                            enable_snippets = true,
                            warn_style = true,
                        },
                    },
                })
                vim.g.zig_fmt_parse_errors = 0
                vim.g.zig_fmt_autosave = 0

            end,
            ["lua_ls"] = function()
                local lspconfig = require("lspconfig")
                lspconfig.lua_ls.setup {
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            runtime = { version = "Lua 5.1" },
                            diagnostics = {
                                globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                            }
                        }
                    }
                }
            end,
            ["pyright"] = function()
                local lspconfig = require("lspconfig")
                lspconfig.pyright.setup {
                    capabilities = capabilities,
                    settings = {
                      python = {
                        analysis = {
                          autoSearchPaths = true,
                          diagnosticMode = "workspace",
                          useLibraryCodeForTypes = true
                        }
                      }
                    }
                }
            end,
        }
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<C-e>'] = cmp.mapping.close(),
            ['<C-l>'] = cmp.mapping.complete(),
            ['<tab>'] = cmp.mapping(function (original)
                if cmp.visible() then
                  cmp.select_next_item(cmp_select)
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                     original()
                end
            end, {"i", "s"}),
            ['<S-tab>'] = cmp.mapping(function (original)
                if cmp.visible() then
                    cmp.select_prev_item(cmp_select)
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump(-1)
                else
                    original()
                end
            end, {"i", "s"}),
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' }, -- For luasnip users.
            { name = 'buffer' },
        })
    })

    vim.diagnostic.config({
        -- update_in_insert = true,
        float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    })
end

setup_lsp()
