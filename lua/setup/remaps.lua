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

keymap("n", "<leader>l", "<cmd>tabnext<CR>")
keymap("n", "<leader>h", "<cmd>tabprev<CR>")
keymap("n", "<leader>1", "1gt")
keymap("n", "<leader>2", "2gt")
keymap("n", "<leader>3", "3gt")
keymap("n", "<leader>4", "4gt")
keymap("n", "<leader>5", "5gt")
keymap("n", "<leader>t", ":tabe ")

keymap("n", "<C-a>", "ggVG")
keymap("v", "<C-a>", "<ESC>ggVG")

keymap("n", "<C-s>", "<CMD>mksession! lastsession.vim<CR>")
keymap("n", "<C-l>", "<CMD>source lastsession.vim<CR>")

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

-- big boi stuff now

local function esc(str)
   return vim.api.nvim_replace_termcodes(str, true, false, true)
end

keymap("i", "<C-u>", function() -- delete function
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

keymap('i', '<C-q>', function()
   local keys = vim.api.nvim_get_keymap('i');
   for _, map in pairs(keys) do
      if map.lhs == '<C-q>' then
         print('success')
         return map.callback()
      end
   end
end, { expr = true })
keymap({ 'n', 'v' }, '<M-CR>', 'gx');
-- macros are annoying
keymap('n', 'q', '');
keymap('n', '<A-c>', '1z=');

local mark_ns = vim.api.nvim_create_namespace('myplugin')
local ts = vim.treesitter
keymap('n', '<C-q>', function()
   local r, c = unpack(vim.api.nvim_win_get_cursor(0))
   r = r - 1
   local line = vim.api.nvim_get_current_line()
   local nodes = { { "foobar", "MatchParen" } }
   for i = 1, #line - c, 1 do
      local inspect = vim.inspect_pos(0, r, i + c - 1)
      local result = inspect.treesitter
      local node1 = line:sub(i + c, i + c)
      local lsp_hls = inspect.semantic_tokens
      local hl = nil
      local priority = 0
      for j = 1, #lsp_hls, 1 do
         if lsp_hls[j].opts.priority > priority then
            if vim.tbl_isempty(
                   vim.api.nvim_get_hl(0, {
                      name = lsp_hls[j].hl_group_link
                   })) == false
            then
               priority = lsp_hls[j].opts.priority
               hl = lsp_hls[j].opts.hl_group_link
            end
         end
      end
      if not hl then
         for j = 1, #result, 1 do
            if not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = result[j].hl_group_link })) then
               hl = result[j].hl_group_link
            end
         end
      end
      if not hl then
         hl = "Normal"
      end
     nodes[i + 1] = { node1, hl }
   end
   vim.inspect(nodes)
   id = vim.api.nvim_buf_set_extmark(0, mark_ns, r, c, {
      id = id,
      virt_text = nodes,
      virt_text_pos = "overlay",
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
