---@diagnostic disable: deprecated
--
-- my first neovim plugin that am not bothered to put in another repo!
--

-- get an element by index in a string
-- 0 indexing
local function stri(str, i)
   return str:sub(i + 1, i + 1)
end

-- str:sub but with 0 indexing
local function strsub(str, b, e)
   if e then
      return str:sub(b + 1, e + 1)
   end
   return str:sub(b + 1)
end
-- insert an element to a string
-- 0 indexing
local function insertChar(str, i, c)
   return str:sub(1, i + 1) .. c .. str:sub(i + 2, #str)
end
-- returns the number of occurences of c in str
-- c is a character
local function strcontains(str, c)
   local i = 0
   local count = 0;
   while i < #str do
      if stri(str, i) == c then
         count = count + 1
      end
      i = i + 1
   end
   return count
end

local bracketList = {
   { '{',  '}' },
   { '(',  ')' },
   { '[',  ']' },
   { '\"', '\"' },
   { '\'', '\'' },
}
local leaveableBrackets = {
   { '(', ')' },
   { '[', ']' },
}
--  don't get confused you are not a compiler
-- (;) -> ();
-- {;} -> {};
local semiOutBrackets = {
   {
      ['{'] = true,
      ['('] = true,
   },
   {
      [')'] = true,
      ['}'] = true,
   }
}
--i could use a string contains
--but this is cooler
local letters = {
   ['a'] = true,
   ['b'] = true,
   ['c'] = true,
   ['d'] = true,
   ['e'] = true,
   ['f'] = true,
   ['g'] = true,
   ['h'] = true,
   ['i'] = true,
   ['j'] = true,
   ['k'] = true,
   ['l'] = true,
   ['m'] = true,
   ['n'] = true,
   ['o'] = true,
   ['p'] = true,
   ['q'] = true,
   ['r'] = true,
   ['s'] = true,
   ['t'] = true,
   ['u'] = true,
   ['v'] = true,
   ['w'] = true,
   ['x'] = true,
   ['y'] = true,
   ['z'] = true,
   ['A'] = true,
   ['B'] = true,
   ['C'] = true,
   ['D'] = true,
   ['E'] = true,
   ['F'] = true,
   ['G'] = true,
   ['H'] = true,
   ['I'] = true,
   ['J'] = true,
   ['K'] = true,
   ['L'] = true,
   ['M'] = true,
   ['N'] = true,
   ['O'] = true,
   ['P'] = true,
   ['Q'] = true,
   ['R'] = true,
   ['S'] = true,
   ['T'] = true,
   ['U'] = true,
   ['V'] = true,
   ['W'] = true,
   ['X'] = true,
   ['Y'] = true,
   ['Z'] = true,
   ['0'] = true,
   ['1'] = true,
   ['2'] = true,
   ['3'] = true,
   ['4'] = true,
   ['5'] = true,
   ['6'] = true,
   ['7'] = true,
   ['8'] = true,
   ['9'] = true,
   ['\\'] = true,
   ['/'] = true,
   [':'] = true,
   ['_'] = true,
   ['.'] = true,
}

local api = vim.api

vim.keymap.set("i", ";", function()
   local r, c = unpack(api.nvim_win_get_cursor(0));
   r = r - 1 -- i hate lua
   local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
   local current = stri(line, c)
   if semiOutBrackets[1][current] ~= nil then
      local next = stri(line, c + 2)
      if next == ';' then
         return ''
      end
      return '<right><right>;<left><left>'
   end
   if semiOutBrackets[2][current] ~= nil then
      local next = stri(line, c + 1)
      if next == ';' then
         return ''
      end
      return '<right>;<left><left>'
   end
   return ';'
end, { expr = true, noremap = true })

vim.keymap.set("n", ";", function()
   local r, c = unpack(api.nvim_win_get_cursor(0));
   r = r - 1 -- i hate lua
   local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
   local current = stri(line, c)
   if semiOutBrackets[1][current] ~= nil then
      local next = stri(line, c + 2)
      if next == ';' then
         return ''
      end
      return 'a<right>;<left><left><ESC>'
   end
   if semiOutBrackets[2][current] ~= nil then
      local next = stri(line, c + 1)
      if next == ';' then
         return ''
      end
      return 'a;<left><ESC>'
   end
   return ';'
end, { expr = true, noremap = true })

local function brackets(open, close)
   local r, c = unpack(api.nvim_win_get_cursor(0));
   r = r - 1;
   local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
   local next = stri(line, c);
   local dataBeforeCursor = strsub(line, 0, c - 1);
   local dataAfterCursor = strsub(line, c);
   local openBrackets = strcontains(dataBeforeCursor, open) - strcontains(dataBeforeCursor, close)
   local closedBrackets = strcontains(dataAfterCursor, close) - strcontains(dataAfterCursor, open)
   line = insertChar(line, c - 1, open);
   --this might not be the best way to check if there are missing end brackets
   --but its good enough
   if closedBrackets <= openBrackets then
      -- word wrapping
      while letters[next] do
         c = c + 1;
         next = stri(line, c);
         if letters[next] == nil then
            c = c - 1
         end
      end
      line = insertChar(line, c, close);
   end
   api.nvim_buf_set_lines(0, r, r + 1, false, { line });
   local cmd = api.nvim_replace_termcodes("<CMD>", true, false, true);
   local enter = api.nvim_replace_termcodes("<CR>", true, false, true);
   api.nvim_feedkeys(cmd .. 'normal ==f' .. close .. enter, 'n', false);
end

for i, bracket in pairs(bracketList) do
   vim.keymap.set("i", bracket[1], function()
      brackets(bracket[1], bracket[2])
   end)
end

vim.keymap.set("i", "\'", function()
   local r, c = unpack(api.nvim_win_get_cursor(0));
   r = r - 1;
   local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
   local prev = stri(line, c - 1)
   if letters[prev] then
      return "\'"
   end
   return "\'\'<left>"
end, { expr = true, noremap = true })

vim.keymap.set("i", "<BS>", function()
   local r, c = unpack(api.nvim_win_get_cursor(0));
   r = r - 1;
   local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
   local prev = stri(line, c - 1)
   local next = stri(line, c)
   for i, bracket in pairs(bracketList) do
      if prev == bracket[1] then
         if next == bracket[2] then
            return '<right><BS><BS>';
         end
      end
   end
   return '<BS>';
end, { expr = true, noremap = true })

--perfer (;) over this when adding semicolons
--l to leave pair
vim.keymap.set("i", "l", function()
   local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
   local line = api.nvim_buf_get_lines(0, cursorRow - 1, cursorRow, false)[1]
   local current = stri(line, cursorCol)
   for i, bracket in pairs(leaveableBrackets) do
      if current == bracket[2] then
         return '<right>';
      end
   end
   return 'l';
end, { expr = true, noremap = true })

--this works better than <ESC>O because it only draws the cursor once
--this took hours of trying to perfect it all thanks to feedkeys
vim.keymap.set("i", "<CR>", function()
   local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
   local line = api.nvim_buf_get_lines(0, cursorRow - 1, cursorRow, false)[1]
   local prev = stri(line, cursorCol - 1)
   if prev == '{' then
      --had a weird indentation thats why ==
      return '<CR><CMD>normal ==k$<CR><right><CR>';
   end
   return '<CR>'
end, { expr = true, noremap = true })
