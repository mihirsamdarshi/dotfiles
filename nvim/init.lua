local api = vim.api
local window_options = vim.wo

window_options.number = true
window_options.wrap = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.smartindent = true
vim.opt.wrap = false

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "sumneko_lua", "rust_analyzer", "tsserver", "pyright" }
})
require('hlargs').setup()
require('Comment').setup()

require('cmd')
require('keys')
require('languages')
require('options')

