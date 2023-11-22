vim.g.mapleader = " "
local keymap = vim.keymap.set

keymap('t', '<Esc>', '<C-\\><C-n>')

--very shmooth line movement
keymap("v", "J", function()
   local selbegin = vim.fn.getpos('v')[2]
   local selend = vim.fn.getpos('.')[2]
   local bufsize = vim.api.nvim_buf_line_count(0)
   if selbegin == bufsize or selend == bufsize then
      -- return '<ESC>o<ESC>gvJ' this would add a new line at the top if hit
      return ''
   end
   local old_lz = vim.o.lz
   vim.o.lz = true;
   return "<ESC><CMD>'<,'>m '>+1<CR>gv=gv<cmd>lua vim.o.lz =  " .. (old_lz and "true" or "false") .. "<cr>"
end, { expr = true, remap = true, silent = true })

keymap("v", "K", function()
   local selend = vim.fn.getpos(".")[2]
   local selbegin = vim.fn.getpos("v")[2]
   if selbegin == 1 or selend == 1 then
      -- return '<ESC>O<esc>gvK' this would add a new line at the bottom if hit
      return ''
   end
   vim.o.lz = true;
   local old_lz = vim.o.lz
   return "<ESC><CMD>'<,'>m '<-2<CR>gv=gv<cmd>lua vim.o.lz =  " .. (old_lz and "true" or "false") .. "<cr>"
end, { expr = true, remap = true, silent = true })

keymap("n", "J", "vJ<esc>", { remap = true })
keymap("n", "K", "vK<esc>", { remap = true })

-- shift K by default goes to help/man page
keymap({ "n", "v" }, "M", "K")

--lsp/writing

---@diagnostic disable-next-line: deprecated
local unpack = unpack or table.unpack
local function format()
   --https://github.com/neovim/neovim/issues/24297#issuecomment-1782245297
   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
   vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
   vim.lsp.buf.format()
end

local function write()
   format()
   vim.cmd.write()
end

keymap("n", "<leader>w", write)

keymap("n", "<leader>q", function()
   write()
   vim.cmd('qa!')
end)

-- save to the system clipboard
keymap("n", "y", "\"+y")
keymap("v", "y", "\"+y")

keymap("n", "p", "\"+P")

-- tab movement

keymap({ "n", "t" }, "<A-h>", "<cmd>tabprev<CR>")
keymap({ "n", "t" }, "<A-l>", "<cmd>tabnext<CR>")

keymap({ "n", "t", "i" }, "<A-L>", function()
   vim.cmd [[ silent! +tabmove ]]
   require('lualine').refresh({
      scope = 'tabpage',     -- scope of refresh all/tabpage/window
      place = { 'tabline' }, -- lualine segment ro refresh.
   })
end)

keymap({ "n", "t", "i" }, "<A-H>", function()
   vim.cmd [[ silent! -tabmove ]]
   require('lualine').refresh({
      scope = 'tabpage',     -- scope of refresh all/tabpage/window
      place = { 'tabline' }, -- lualine segment ro refresh.
   })
end)

keymap({ "n", "t", "i" }, "<A-1>", "1gt")
keymap({ "n", "t", "i" }, "<A-2>", "2gt")
keymap({ "n", "t", "i" }, "<A-3>", "3gt")
keymap({ "n", "t", "i" }, "<A-4>", "4gt")
keymap({ "n", "t", "i" }, "<A-5>", "5gt")
keymap({ "n", "t", "i" }, "<A-6>", "6gt")
keymap({ "n", "t", "i" }, "<A-7>", "7gt")
keymap({ "n", "t", "i" }, "<A-8>", "8gt")
keymap({ "n", "t", "i" }, "<A-9>", "9gt")
keymap({ "n", "t", "i" }, "<A-t>", ":tabe ")

keymap("n", "<C-a>", "ggVG")
keymap("v", "<C-a>", "<ESC>ggVG")

keymap("n", "<A-space>", "<cmd>echo \"saved session\"<cr><CMD>mksession! lastsession.vim<CR>")
keymap("n", "<C-space>", "<CMD>source lastsession.vim<CR><cmd>echo \"loaded session\"<cr><esc>")

-- got this idea from fuadsaud on github
keymap({ "o", "n", "v" }, "L", "$")
keymap({ "o", "n", "v" }, "H", "0")

keymap({ "o", "n", "v" }, "$", "")
keymap({ "o", "n", "v" }, "0", "")

--insert/command mode mappings
keymap({ "c" }, "<A-j>", "<down>")
keymap({ "i", "c" }, "<A-k>", "<up>")
keymap({ "i", "c" }, "<A-l>", "<right>")
keymap({ "i", "c" }, "<A-h>", "<left>")
keymap({ "i", "c", "n" }, "<C-x>", "<DEL>")

-- fun mappings i use to write code quickly and correct errors
-- if u just want to take these the AddSemi command is in commands.lua
keymap("i", "<A-j>", "<cmd>AddSemi<cr><end><cr>")              -- create a line and add semicolon
keymap("i", "<A-s>", "<cmd>AddSemi<cr><down><cmd>SemiEnd<cr>") -- go onto statement's pair add semicolon
keymap("i", "<C-j>", "<cmd>AddSemi<cr><down><end><cr>")        -- jump out of pair and add semicolon

local function esc(str)
   return vim.api.nvim_replace_termcodes(str, true, false, true)
end


local function get_hl(r, pos)
   pos = pos - 1
   local result = vim.inspect_pos(0, r, pos)
   local lsp_hls = result.semantic_tokens
   if #lsp_hls ~= 0 then
      local hl
      local priority = 0
      for _, lsp_hl in pairs(lsp_hls) do
         local opts = lsp_hl.opts
         if priority < opts.priority and
             not hl_iscleared(opts.hl_group_link)
         then
            hl = opts.hl_group_link
            priority = opts.priority
         end
      end
      if hl then
         return hl
      end
   end
   local ts_hls = result.treesitter
   if #ts_hls ~= 0 then
      for i = #ts_hls, 1, -1 do
         if not hl_iscleared(ts_hls[i].hl_group_link) then
            return ts_hls[i].hl_group_link
         end
      end
   end
   local syntax_hls = result.syntax
   if #syntax_hls ~= 0 then
      return syntax_hls[#syntax_hls].hl_group_link
   end
   return "Normal"
end

local buf = -1
keymap('i', '<C-q>', function()
   local r, c = unpack(vim.api.nvim_win_get_cursor(0))
   r = r - 1
   local hls = {}
   local line = vim.api.nvim_get_current_line()
   for i = c, #line, 1 do
      local result = vim.inspect_pos(0, r, i - 1, {})
      local syntax_hls = result.syntax
      if #syntax_hls ~= 0 then
         table.insert(hls, syntax_hls[#syntax_hls].hl_group_link)
      end
   end
   vim.print(hls)
end, { expr = true })

keymap({ 'n', 'v', 'c' }, '<M-CR>', 'gx');
-- macros are annoying
keymap('i', '<A-a>', function()
   print(vim.fn.pumvisible())
end);

vim.keymap.set('c', '<tab>', '<C-z>', { silent = false }) -- to fix cmp
if DEBUG_BUFER == nil then
   DEBUG_BUFER = -1
end

keymap('n', '<A-d>', function()
   vim.cmd('normal ' .. esc('<C-v><C-l><cmd>e m<cr>'))
   DEBUG_BUFER = vim.api.nvim_get_current_buf()
   vim.cmd('normal ' .. esc('<C-h>'))
end)

-- - 5 hours + 0 progress should have went to neovim's c code rather than trying to make work arounds
-- update still didn't go to the source code
--keymap('i', '<A-l>', function()
--   local keys = 'text'
--   vim.cmd ('normal i' .. keys)
--   vim.api.nvim_feedkeys(esc('<cmd>echo getreg(\'.\')<cr>'),'i',false)
--end)

function clear()
   vim.api.nvim_buf_set_lines(DEBUG_BUFER, 0, -1, false, {})
end

last_data = "None"
function log(data)
   last_data = data
   if DEBUG_BUFER == -1 then
      return
   end
   if type(data) == 'string' then
      data = vim.split(data, '\n')
      vim.api.nvim_buf_set_lines(DEBUG_BUFER, -2, -2, false, data)
      return
   end
   vim.api.nvim_buf_set_lines(DEBUG_BUFER, -1, -1, false, data)
end

keymap("n", "p", "\"+P")


local diagnosticsOn = false
keymap('i', '<C-d>', function()
   diagnosticsOn = not diagnosticsOn
   vim.diagnostic.config({
      update_in_insert = diagnosticsOn,
   })
end)

-- window shortcuts
keymap({ 't', 'i', 'n' }, "<C-l>", "<esc><C-w>l", { remap = true })
keymap({ 't', 'i', 'n' }, "<C-h>", "<esc><C-w>h", { remap = true })
keymap({ 't', 'i', 'n' }, "<C-j>", "<esc><C-w>j", { remap = true })
keymap({ 't', 'i', 'n' }, "<C-k>", "<esc><C-w>k", { remap = true })
keymap({ 't', 'i', 'n' }, "<C-q>", "<esc><C-w>q", { remap = true })
-- ctrl-v in insert mode places keys letteraly
keymap({ 't', 'n' }, "<C-v>", "<esc><C-w>v", { remap = true })

keymap('c', "<C-q>", "<cmd>redraw!<cr>")
keymap('c', "<C-a>", "<cmd>redraw<cr>")
keymap('n', "<C-a>",function()
   vim.notify(vim.wo[win].winhl .. "blend:" ..  
      vim.wo[win].winblend
   )
end)

ns = vim.api.nvim_create_namespace('cmdline_testing')

vim.api.nvim_set_decoration_provider(ns, {
   on_win = function(_,win,...)
      if win == vim.api.nvim_get_current_win() then
      end
      return false
   end
})
