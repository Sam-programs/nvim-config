vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.rnu = true
vim.opt.scl = "yes" 

vim.opt.tabstop = 3
vim.opt.softtabstop = 3
vim.opt.shiftwidth = 3
vim.opt.expandtab = true
vim.opt.smartindent = true 

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undo_history/"
vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

-- removed : cuz it's annoying in c++
vim.opt.cinkeys = '0{,0},0),0],0#,!^F,o,O,e'

-- usually pretty useless at least for me
vim.opt.showmode = false
vim.opt.showcmd = false
