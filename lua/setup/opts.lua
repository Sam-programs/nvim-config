vim.o.guicursor = "a:block"

vim.o.nu = false
vim.o.rnu = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.wrap = false

vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.config/nvim/undo/"
vim.o.undofile = true
vim.o.undolevels = 10000

vim.o.hlsearch = false
vim.o.termguicolors = true

vim.o.incsearch = true
vim.o.scrolloff = 8

vim.o.mousem = 'extend'
vim.o.showmode = false
vim.o.showcmd = false

vim.g.netrw_bufsettings = 'noma nomod ro wbuftype=nofile'
-- shutup
vim.g.netrw_banner = 0
vim.o.report = 999999999
vim.o.updatetime = 1000
vim.o.scl = "no"

vim.g.asmsyntax = "nasm"
