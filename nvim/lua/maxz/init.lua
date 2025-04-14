require("maxz.set")
require("maxz.remap")
require("maxz.lazy_init")


vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})


local MaxzGroup = vim.api.nvim_create_augroup('maxz', {})

vim.api.nvim_create_autocmd('LspAttach', {
    group = MaxzGroup,
    callback = function(e)
        --  "grn" is mapped in Normal mode to vim.lsp.buf.rename()
        --  "gra" is mapped in Normal and Visual mode to vim.lsp.buf.code_action()
        --  "grr" is mapped in Normal mode to vim.lsp.buf.references()
        --  "gri" is mapped in Normal mode to vim.lsp.buf.implementation()
        --  "gO" is mapped in Normal mode to vim.lsp.buf.document_symbol()
        --  CTRL-S is mapped in Insert mode to vim.lsp.buf.signature_help()
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.api.nvim_create_autocmd({"BufWritePre"}, {
    group = MaxzGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

