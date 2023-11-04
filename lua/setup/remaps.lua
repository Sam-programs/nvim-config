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


if DEBUG_BUFER == nil then
   DEBUG_BUFER = -1
end

keymap('n', '<A-d>', function()
   DEBUG_BUFER = vim.api.nvim_get_current_buf()
end)


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

local ts = vim.treesitter
local mark_ns = vim.api.nvim_create_namespace('myplugin')

local function print_family(parent, depth)
   if parent:named() then
      local text = ts.get_node_text(parent, 0, {})
      log(string.format(string.rep('\t', depth) .. "%s %d,%d,%d,%d " .. (parent:named() and "Named" or "UnNamed"),
         text, parent:range()))
   end
   for kid in parent:iter_children() do
      if kid:child_count() ~= 0 then
         print_family(kid, depth + 1)
      else
         if kid:named() then
            local text = ts.get_node_text(kid, 0, {})
            log(string.format(string.rep('\t', depth) .. "%s %d,%d,%d,%d " .. (kid:named() and "Named" or "UnNamed"),
               text, kid:range()))
         end
      end
   end
end

local ignored_chars = {
   [" "] = true,
   [":"] = true,
   [","] = true,
   [";"] = true,
   ["("] = true,
   [")"] = true,
   ["["] = true,
   ["]"] = true,
   ["*"] = true,
   ["."] = true,
}

local inspect_calls = 0
local function ts_get_hl(r, start_pos)
   local hl = "Normal"
   inspect_calls = inspect_calls + 1
   local result = vim.inspect_pos(0, r, start_pos).treesitter
   if #result ~= 0 then
      hl = result[#result].hl_group
      if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = result[#result].hl_group_link })) then
         hl = result[#result - 1].hl_group
      end
   end
   return hl
end
local cached = 0

local test_str = "Comment {}c"

keymap('i', '<A-d>',
   function()
      local info = "foobar"
      local r, cl = unpack(vim.api.nvim_win_get_cursor(0))
      local col = cl
      r = r - 1
      local line = vim.api.nvim_get_current_line()

      local uv = vim.loop
      local _, sms = uv.gettimeofday()

      local nodes = { { info, "Comment" } }
      cl = cl + 1
      local start_pos = cl
      inspect_calls = 0
      cached = 0
      for i = cl, #line, 1 do
         local char = line:sub(i, i)
         if ignored_chars[char] then
            local text
            if i ~= start_pos then
               text = line:sub(start_pos, i - 1)
            else
               text = line:sub(start_pos, i)
               cached = cached + 1
               nodes[#nodes + 1] = { text, "Normal" }
               start_pos = i + 1
               goto continue
            end
            local hl = ts_get_hl(r, start_pos - 1)
            nodes[#nodes + 1] = { text, hl }
            start_pos = i + 1
            nodes[#nodes + 1] = { char, "Normal" }
         end
         if i == #line then
            local text = line:sub(start_pos)
            local hl
            if ignored_chars[text] then
               cached = cached + 1
               hl = "Normal"
            else
               hl = ts_get_hl(r, start_pos - 1)
            end

            nodes[#nodes+1] = { text, hl }
         end
         ::continue::
      end
      local _, sme = uv.gettimeofday()
      local delay = sme - sms
      clear()
      for i = 1,#nodes,1 do
         log(nodes[i][1] .. ','.. nodes[i][2])
      end
      log("took:" .. delay)
      log("inspect calls:" .. inspect_calls)
      log("cached:" .. cached)

      id = vim.api.nvim_buf_set_extmark(0, mark_ns, r, col, {
         id = id,
         virt_text_pos = "overlay",
         virt_text = nodes,
      })
   end
)

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
