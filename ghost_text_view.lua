-- don't add this file to your init.lua
local config = require('cmp.config')
local misc = require('cmp.utils.misc')
local str = require('cmp.utils.str')
local types = require('cmp.types')
local api = require('cmp.utils.api')

---@class cmp.GhostTextView
local ghost_text_view = {}

ghost_text_view.ns = vim.api.nvim_create_namespace('cmp:GHOST_TEXT')

-- ghost text emulation tables

-- items that split the line since i didn't find an effient way to parse TSNodes
local split_chars = {
   [" "] = true,

   [","] = true,
   ["."] = true,

   [":"] = true,
   [";"] = true,


   ["["] = true,
   ["]"] = true,

   ["{"] = true,
   ["}"] = true,

   ["("] = true,
   [")"] = true,

   ["0"] = true,
   ["1"] = true,
   ["2"] = true,
   ["3"] = true,
   ["4"] = true,
   ["5"] = true,
   ["6"] = true,
   ["7"] = true,
   ["8"] = true,
   ["9"] = true,

   -- operators for insane people that write operators with no spaces
   ["#"] = true,
   ["="] = true,
   ["+"] = true,
   ["-"] = true,
   ["*"] = true,
   ["/"] = true,
}

-- first time each is used will be memomized for the next usages
-- saved per filetype
local memomize = {
   [" "] = true,

   [","] = true,
   ["."] = true,

   [":"] = true,
   [";"] = true,

   ["["] = true,
   ["]"] = true,

   ["{"] = true,
   ["}"] = true,

   ["("] = true,
   [")"] = true,

   ["#"] = true,
   ["="] = true,
   ["+"] = true,
   ["-"] = true,
   ["*"] = true,
   ["/"] = true,

   ["0"] = true,
   ["1"] = true,
   ["2"] = true,
   ["3"] = true,
   ["4"] = true,
   ["5"] = true,
   ["6"] = true,
   ["7"] = true,
   ["8"] = true,
   ["9"] = true,
}

local cache = {}
local inspect_calls = 0
local function ts_get_hl(r, start_pos)
   local hl = "Normal"
   inspect_calls = inspect_calls + 1
   local result = vim.inspect_pos(0, r, start_pos).treesitter
   if #result ~= 0 then
      hl = result[#result].hl_group_link
      if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = hl })) then
         -- lets hope the 2nd last one is valid
         hl = result[#result - 1].hl_group_link
      end
   end
   return hl
end





ghost_text_view.new = function()
   local self = setmetatable({}, { __index = ghost_text_view })
   self.win = nil
   self.entry = nil
   vim.api.nvim_set_decoration_provider(ghost_text_view.ns, {
      on_win = function(_, win)
         return win == self.win
      end,
      on_line = function(_, _, _, on_row)
         local c = config.get().experimental.ghost_text
         if not c then
            return
         end

         if not self.entry then
            return
         end

         local row, col = unpack(vim.api.nvim_win_get_cursor(0))
         if on_row ~= row - 1 then
            return
         end

         local line = vim.api.nvim_get_current_line()

         local config_hl = type(c) == 'table' and c.hl_group or "Comment"
         local r, cl = unpack(vim.api.nvim_win_get_cursor(0))
         r = r - 1
         local text = self.text_gen(self, line, col)
         local nodes = { { text, config_hl } }
         cl = cl + 1
         local start_pos = cl
         local lang = vim.o.filetype
         if not cache[lang] then
            cache[lang] = {}
         end
         inspect_calls = 0
         for i = cl, #line, 1 do
            local char = line:sub(i, i)
            if split_chars[char] then
               local text
               if i ~= start_pos then
                  text = line:sub(start_pos, i - 1)
               else
                  -- we matched 2 ignored_chars
                  if not cache[lang][char] and memomize[char] then
                     cache[lang][char] = {char,ts_get_hl(r,i - 1)}
                  end
                  text = line:sub(start_pos, i)
                  nodes[#nodes + 1] = cache[lang][char] or { text,"Normal" }
                  start_pos = i + 1
                  goto continue
               end
               local hl = ts_get_hl(r, start_pos - 1)
               nodes[#nodes + 1] = { text, hl }
               start_pos = i + 1
               if not cache[lang][char] and memomize[char] then
                  cache[lang][char] = {char,ts_get_hl(r,i - 1)}
               end
               nodes[#nodes + 1] = cache[lang][char] or { char, "Normal" }
            end
            if i == #line then
               local text = line:sub(start_pos)
               local hl
               if split_chars[text] then
                  if not cache[lang][char] and memomize[char] then
                     cache[lang][char] = {char,ts_get_hl(r,i - 1)}
                  end
                  hl = cache[lang][char] or {text,"Normal"}
               else
                  hl = ts_get_hl(r, start_pos - 1)
               end

               nodes[#nodes + 1] = { text, hl }
            end
            ::continue::
         end
         text = text .. inspect_calls
         nodes[1] = {text,config_hl}
         if #text > 0 then
            vim.api.nvim_buf_set_extmark(0, ghost_text_view.ns, row - 1, col, {
               right_gravity = false,
               virt_text = nodes,
               virt_text_pos = 'overlay',
               ephemeral = true,
            })
         end
      end,
   })
   return self
end

---Generate the ghost text
---  This function calculates the bytes of the entry to display calculating the number
---  of character differences instead of just byte difference.

local kind = require('cmp.types.lsp').CompletionItemKind
local semicolon_langs = {
   cpp = true,
   c = true,
}
ghost_text_view.text_gen = function(self, line, cursor_col)
   local word = self.entry:get_insert_text()
   if self.entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
      word = vim.lsp.util.parse_snippet(word)
   end
   word = str.oneline(word)
   local word_clen = vim.str_utfindex(word)
   local cword = string.sub(line, self.entry:get_offset(), cursor_col)
   local cword_clen = vim.str_utfindex(cword)
   -- Number of characters from entry text (word) to be displayed as ghost thext
   local nchars = word_clen - cword_clen
   -- Missing characters to complete the entry text
   local text
   if nchars > 0 then
      text = string.sub(word, vim.str_byteindex(word, word_clen - nchars) + 1)
      local item = self.entry:get_completion_item()
      if item.kind == kind.Function or item.kind == kind.Method then
         text = text .. '()'
         if semicolon_langs[vim.o.ft] and
             cursor_col == #line and
             line:sub(#line, #line) ~= ';'
         then
            text = text .. ';'
         end
      else
         if vim.o.ft == "cpp" and
             vim.fn.match(item.label, '<.*>') ~= -1
         then
            text = text .. '<>'
         end
      end
   else
      text = ''
   end
   return text
end

---Show ghost text
---@param e cmp.Entry
ghost_text_view.show = function(self, e)
   if not api.is_insert_mode() then
      return
   end
   local c = config.get().experimental.ghost_text
   if not c then
      return
   end
   local changed = e ~= self.entry
   self.win = vim.api.nvim_get_current_win()
   self.entry = e
   if changed then
      misc.redraw(true) -- force invoke decoration provider.
   end
end

ghost_text_view.hide = function(self)
   if self.win and self.entry then
      self.win = nil
      self.entry = nil
      misc.redraw(true) -- force invoke decoration provider.
   end
end

return ghost_text_view
