---@diagnostic disable: deprecated
vim.g.mapleader = " "

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>>')

vim.keymap.set({ "v", "n" }, "J", ":m '>+1<CR>gv=gv")
vim.keymap.set({ "v", "n" }, "K", ":m '<-2<CR>gv=gv")
--lsp

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
local function write()
   vim.lsp.buf.format()
   vim.cmd('wa!')
end

vim.keymap.set("n", "<leader>w", write)

vim.keymap.set("n", "<leader>q", function()
   write()
   vim.cmd('qa!')
end)
vim.keymap.set("n", "q:", function()
   write()
   vim.cmd('qa!')
end)



vim.keymap.set("n", "<C-f>", function()
   vim.cmd.CodeActionMenu()
end)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "p", "\"+p")
vim.keymap.set("v", "y", "\"+y")

vim.keymap.set("n", "y", "\"+Y")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>h", "<cmd>tabnext<CR>")
vim.keymap.set("n", "<leader>l", "<cmd>tabprev<CR>")
vim.keymap.set("n", "<leader>1", "1gt")
vim.keymap.set("n", "<leader>2", "2gt")
vim.keymap.set("n", "<leader>3", "3gt")
vim.keymap.set("n", "<leader>4", "4gt")
vim.keymap.set("n", "<leader>5", "5gt")
vim.keymap.set("n", "<leader>t", ":tabe ")

vim.keymap.set("n", "<C-a>", "ggVG")
vim.keymap.set("v", "<C-a>", "<ESC>ggVG")

vim.keymap.set("n", "<C-s>", "<CMD>mksession lastsession.vim<CR>")
vim.keymap.set("n", "<C-l>", "<CMD>source lastsession.vim<CR>")

vim.keymap.set("i", "<C-h>", "<left>")
vim.keymap.set("i", "<C-j>", "<down>")
vim.keymap.set("i", "<C-k>", "<up>")
vim.keymap.set("i", "<C-l>", "<right>")
