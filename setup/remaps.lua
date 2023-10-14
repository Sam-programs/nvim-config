vim.g.mapleader = " "

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')

--very shmooth line movement
vim.keymap.set("v", "J", function()
   local selbegin = vim.fn.getpos('v')[2]
   local selend = vim.fn.getpos('.')[2]
   local bufsize = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
   if selbegin == bufsize or selend == bufsize then
      -- return '<ESC>o<ESC>gvJ' this would add a new line at the top if hit
      return ''
   end
   return "<ESC><CMD>'<,'>m '>+1<CR>gv=gv"
end, { expr = true, remap = true })

vim.keymap.set("v", "K", function()
   local selend = vim.fn.getpos(".")[2]
   local selbegin = vim.fn.getpos("v")[2]
   if selbegin == 1 or selend == 1 then
      -- return '<ESC>O<esc>gvK' this would add a new line at the bottom if hit
      return ''
   end
   if selbegin > selend then
      selbegin = selend
   end
   return "<ESC><CMD>'<,'>m " .. selbegin .. "-2<CR>gv=gv"
end, { expr = true, remap = true })

vim.keymap.set("n", "J", "vJ", { remap = true })
vim.keymap.set("n", "K", "vK", { remap = true })

-- shift K by default goes to help/man page
vim.keymap.set({ "n", "v" }, "M", "K")

--lsp/writing
local function write()
   vim.lsp.buf.format()
   vim.cmd('wa!')
end
vim.keymap.set("n", "<leader>w", write)

vim.keymap.set("n", "<leader>q", function()
   write()
   vim.cmd('qa!')
end)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- save to the system clipboard instead of the register non-sense
vim.keymap.set("n", "p", "\"+P")
vim.keymap.set("n", "y", "\"+y")
vim.keymap.set("v", "p", "\"+P")
vim.keymap.set("v", "y", "\"+y")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/<Left>]])
vim.keymap.set("n", "<leader>g", [[:%s/<C-r><C-w>/<C-r><C-w>/<Left>]])

vim.keymap.set("n", "<leader>l", "<cmd>tabnext<CR>")
vim.keymap.set("n", "<leader>h", "<cmd>tabprev<CR>")
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

-- got this idea from fuadsaud on github
vim.keymap.set({ "o", "n", "v" }, "L", "$")
vim.keymap.set({ "o", "n", "v" }, "H", "0")

vim.keymap.set({ "o", "n", "v" }, "$", "")
vim.keymap.set({ "o", "n", "v" }, "0", "")

--insert/command mode mappings
vim.keymap.set({ "c" }, "<A-j>", "<down>")
vim.keymap.set({ "i", "c" }, "<A-k>", "<up>")
vim.keymap.set({ "i", "c" }, "<A-l>", "<right>")
vim.keymap.set({ "i", "c" }, "<A-h>", "<left>")
vim.keymap.set({ "i", "c", "n" }, "<C-x>", "<DEL>")
vim.keymap.set("i", "<C-w>", "<esc><C-w>")

-- fun mappings i use to write code quickly and correct errors
-- if u just want to take these the AddSemi command is in commands.lua
vim.keymap.set("i", "<A-j>", "<cmd>AddSemi<cr><end><cr>")              -- create a line and add semicolon
vim.keymap.set("i", "<A-s>", "<cmd>AddSemi<cr><down><cmd>SemiEnd<cr>") -- go onto statement's pair add semicolon
vim.keymap.set("i", "<C-j>", "<cmd>AddSemi<cr><down><end><cr>")        -- jump out of pair and add semicolon

-- big boi stuff now
-- check commands.lua for commands that big boi stuff uses
local function esc(str)
   return vim.api.nvim_replace_termcodes(str, true, false, true)
end

vim.api.nvim_create_user_command("StatementAddSemi", function()
   local line = vim.api.nvim_get_current_line()
   -- only variable inits and structs/classes need semicolons
   local pattern = '^.*(.*)'

   if eopts.semicolon_langs[vim.o.filetype] and
       vim.fn.match({ line }, pattern) ~= 0
   then
      line = line .. ';'
      vim.api.nvim_set_current_line(line)
      return
   end
end, {})

local match = vim.fn.match
local function get_lua_pair(line)
   if match({ line }, 'function') == 0 then
      return '', 'end'
   end
   if match({ line }, 'if') == 0 then
      return ' then', 'end'
   end
   -- if it's none of the above it's a while or for loop
   return ' do', 'end'
end

local function get_sh_pair(line)
   if match({ line }, 'elif') == 0 then
      return ' then', '<home><bs><down>'
   end
   if match({ line }, 'if') == 0 then
      return ' then', 'if'
   end
   if match({ line }, 'case') == 0 then
      return '', 'esac'
   end
   -- if it's none of the above it's a while or for loop
   return ' do', 'done'
end

local indent = require('indent')

-- i might move this into it's own plugin
-- ehh it's a bit annoying to package StatementAddSemi
-- if someone wants to do it feel free to do so
vim.keymap.set('i', '<C-Space>', function()
   indent.enable_ctrl_f_formatting()
   local pair_open, pair_close = '{', '}'

   local line = vim.api.nvim_get_current_line()
   if vim.o.filetype == 'lua' then
      pair_open, pair_close = get_lua_pair(line)
   end
   if match(vim.o.filetype, 'sh') == 0 then
      pair_open, pair_close = get_sh_pair(line)
   end

   vim.api.nvim_feedkeys(
      esc('<end><cmd>StatementAddSemi<cr>' ..
         pair_open .. '<cr><cr>' ..
         pair_close .. '<C-f><up><C-f>' .. '<C-g>u' ..
         '<cmd>lua require(\'indent\').restore_user_configuration()<cr>'),
      'n', false)
end)

vim.keymap.set("i", "<C-u>", function() -- delete function
   -- undo blocks didn't work well for all situations so i made this
   local line = vim.api.nvim_get_current_line()
   local r, c = unpack(vim.api.nvim_win_get_cursor(0))
   local prev = line:sub(c, c)
   local current = line:sub(c + 1, c + 1)
   local after_cursor = line:sub(c + 1)
   local wordend = c
   if prev == ')' then
      local pairs_left = 0
      for i = c - 1, 1, -1 do
         local char = line:sub(i, i)
         if char == ')' then
            pairs_left = pairs_left + 1
         end
         if char == '(' then
            if pairs_left == 0 then
               line = line:sub(1, i - 1)
               if i ~= 1 then
                  wordend = i - 1
               end
               break
            end
            pairs_left = pairs_left - 1
         end
      end
      for i = wordend, 1, -1 do
         local char = line:sub(i, i)
         if char:match("%w") == nil then
            line = line:sub(1, i)
            break
         end
         if i == 1 then
            line = ''
            break
         end
      end
      c = #line
      line = line .. after_cursor
      vim.api.nvim_set_current_line(line)
      vim.api.nvim_win_set_cursor(0, { r, c })
      vim.api.nvim_feedkeys(esc("<C-g>u"), "n", false)
      return
   end
   vim.cmd("undo")
end)

-- next idea
-- make <space> add a coma when inside functions after a word or a prefix
-- actually no make space letter add a coma
-- make the search go at least vim.o.mfd lines (for you c(++) disagnated inits)
