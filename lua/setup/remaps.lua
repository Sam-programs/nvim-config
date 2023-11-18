vim.g.mapleader = " "
local keymap = vim.keymap.set

keymap('t', '<Esc>', '<C-\\><C-n>')
keymap('t', '<C-w>', '<Esc><C-w>', { remap = true })

--very shmooth line movement
keymap("v", "<C-j>", function()
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

keymap("v", "<C-k>", function()
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

keymap("n", "<C-j>", "v<C-j>", { remap = true })
keymap("n", "<C-k>", "v<C-k>", { remap = true })

keymap({ "n", "v" }, "J", "<C-d>zz")
keymap({ "n", "v" }, "K", "<C-u>zz")


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
keymap("n", "p", "\"+P")
keymap("n", "y", "\"+y")
keymap("v", "y", "\"+y")

keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/<Left>]])
keymap("n", "<leader>g", [[:%s/<C-r><C-w>/<C-r><C-w>/<Left>]])

keymap("n", "<A-l>", "<cmd>tabnext<CR>")
keymap("n", "<A-h>", "<cmd>tabprev<CR>")
keymap("n", "<A-1>", "1gt")
keymap("n", "<A-2>", "2gt")
keymap("n", "<A-3>", "3gt")
keymap("n", "<A-4>", "4gt")
keymap("n", "<A-5>", "5gt")
keymap("n", "<A-6>", "6gt")
keymap("n", "<A-7>", "7gt")
keymap("n", "<A-8>", "8gt")
keymap("n", "<A-t>", ":tabe ")

keymap("n", "<C-a>", "ggVG")
keymap("v", "<C-a>", "<ESC>ggVG")

keymap("n", "<C-s>", "<cmd>echo \"saved session\"<cr><CMD>mksession! lastsession.vim<CR>")
keymap("n", "<C-l>", "<CMD>source lastsession.vim<CR><cmd>echo \"loaded session\"<cr>")

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
      for _,lsp_hl in pairs(lsp_hls)  do
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
      for i = #ts_hls,1,-1 do
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
   local r,c = unpack(vim.api.nvim_win_get_cursor(0))
   r = r - 1
   local hls = {}
   local line = vim.api.nvim_get_current_line()
   for i = c, #line, 1 do
      local result = vim.inspect_pos(0,r,i - 1,{})
      local syntax_hls = result.syntax
      if #syntax_hls ~= 0 then
         table.insert(hls,syntax_hls[#syntax_hls].hl_group_link)
      end
   end
   vim.print(hls)
end,{expr = true})

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
   DEBUG_BUFER = vim.api.nvim_get_current_buf()
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

function log(data)
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

if false then
   -- highlight links when on the cursor
   -- made while learning Extmarks

   local https_ns = vim.api.nvim_create_namespace('https_links')
   vim.api.nvim_set_hl(0, "https_underline", { bold = true })
   local link = nil

   vim.api.nvim_create_autocmd({ "InsertEnter" }, {
      pattern = "*",
      callback = function()
         if id then
            vim.api.nvim_buf_del_extmark(0, https_ns, id)
         end
      end
   })

   local not_link_pat = '\\S'
   vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      pattern = "*",
      callback = function()
         local r, c = unpack(vim.api.nvim_win_get_cursor(0))
         local line = vim.api.nvim_get_current_line()
         r = r - 1
         local index = 1
         for i = c + 1, 1, -1 do
            if vim.fn.matchstr(line:sub(i, i), not_link_pat) == "" then
               index = i + 1
               break;
            end
         end
         line = line:sub(index)
         index = index - 1
         link = vim.fn.matchstr(line, '\\M^https://' .. not_link_pat .. '\\*')
         if link ~= "" then
            id = vim.api.nvim_buf_set_extmark(0, https_ns, r, index, {
               id = id,
               end_col = #link + index,
               hl_group = "https_underline",
               hl_mode = "replace",
            })
         else
            if id then
               vim.api.nvim_buf_del_extmark(0, https_ns, id)
            end
         end
      end,
   })
   -- https://google.com   foo boo https://youtube.com
end
