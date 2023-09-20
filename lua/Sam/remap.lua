---@diagnostic disable: deprecated
vim.g.mapleader = " "

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
--lsp
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
local function write()
   vim.lsp.buf.format()
   vim.cmd('wa!')
end

vim.keymap.set("n", "J", "VJ", { remap = true })
vim.keymap.set("n", "K", "VK", { remap = true })

--very shmooth line movement
vim.keymap.set("v", "J", function()
   local selbegin = vim.fn.getpos('v')[2]
   local selend = vim.fn.getpos('.')[2]
   local bufsize = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
   if selbegin == bufsize or selend == bufsize then
      -- return '<ESC>o<ESC>gvJ' this would add a new line at the top if hit
      -- make sure to also add remap = true after expr 
      return ''
   end
   return "<ESC><CMD>'<,'>m '>+1<CR>gv=gv"
end, { expr = true })

vim.keymap.set("v", ">",">gv")
vim.keymap.set("v", "<","<gv")

vim.keymap.set("v", "K", function()
   local selbegin = vim.fn.getpos("v")[2]
   local selend = vim.fn.getpos(".")[2]
   if selbegin == 1 or selend == 1 then
      -- return '<ESC>O<esc>gvK' this would add a new line at the bottom if hit
      -- make sure to also add remap = true after expr -
      return ''
   end
   if selbegin > selend then
      selbegin = selend
   end
   return "<ESC><CMD>'<,'>m " .. selbegin .. "-2<CR>gv=gv"
end, { expr = true })

vim.keymap.set({ "n", "v" }, "M", "K")
vim.keymap.set("n", "<leader>w", write)

vim.keymap.set("n", "<leader>q", function()
   write()
   vim.cmd('qa!')
end)
vim.keymap.set("n", "q:", function()
   write()
   vim.cmd('qa!')
end)


vim.keymap.set("n", "p", "\"+P")
vim.keymap.set("v", "y", "\"+y")
vim.keymap.set("n", "y", "0\"+y$")
--huh so C-o doesn't always exit insertmode
--seems to be the == operator only
vim.keymap.set("i", "<A-p>", "<C-o>p", { remap = true }) -- remap = true means it uses other mappings

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

vim.keymap.set("n", "<C-s>", "<CMD>mksession! lastsession.vim<CR>")
vim.keymap.set("n", "<C-l>", "<CMD>source lastsession.vim<CR>")

vim.keymap.set({ "i", "c" }, "<C-h>", "<left>")
vim.keymap.set({ "i", "c" }, "<C-j>", "<down>")
vim.keymap.set({ "i", "c" }, "<C-k>", "<up>")
vim.keymap.set({ "i", "c" }, "<C-l>", "<right>")
vim.keymap.set({ "i", "c", "n" }, "<C-x>", "<DEL>")

-- got this idea from fuadsaud on github
vim.keymap.set({"n","v"}, "L", "$")
vim.keymap.set({"n","v"}, "H", "0")

vim.keymap.set({"n","v"}, "0","")
vim.keymap.set({"n","v"}, "$","")
