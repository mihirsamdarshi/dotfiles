require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- nice-to-have defaults
vim.o.foldcolumn = "1" -- show fold column
vim.o.foldlevel = 99 -- start with folds open
vim.o.foldlevelstart = 99
vim.o.foldenable = true
