---@diagnostic disable: deprecated
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
   { '\'', '\'' },
   { '\"', '\"' },
}

--  don't get confused you are not a compiler
-- (;) -> ();
-- {;} -> {};
local semiOutBrackets = {
   ['{'] = true,
   ['('] = true,
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
}

local api = vim.api

vim.keymap.set("i", ";", function()
   local r, c = unpack(api.nvim_win_get_cursor(0));
   r = r - 1 -- i hate lua
   local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
   local prev = stri(line, c - 1)
   if semiOutBrackets[prev] ~= nil then
      line = insertChar(line, c + 1, ';');
      api.nvim_buf_set_lines(0, r, r + 1, false, { line });
   else
      api.nvim_feedkeys(';', 'n', false)
   end
end)

local function brackets(open, close)
   local r, c = unpack(api.nvim_win_get_cursor(0));
   r = r - 1;
   local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
   local next = stri(line, c);
   local right = api.nvim_replace_termcodes("<right>", true, false, true);
   local dataBeforeCursor = strsub(line, 0, c - 1);
   local dataAfterCursor = strsub(line, c);
   local openBrackets = strcontains(dataBeforeCursor, open) - strcontains(dataBeforeCursor, close)
   local closedBrackets = strcontains(dataAfterCursor, close) - strcontains(dataAfterCursor, open)
   line = insertChar(line, c - 1, open);
   --this might not be the best way to check if there are missing end brackets
   --but its good enough
   if closedBrackets >= openBrackets then
      -- word wrapping
      while letters[next] do
         c = c + 1;
         next = stri(line, c);
      end
      line = insertChar(line, c, close);
   end
   api.nvim_buf_set_lines(0, r, r + 1, false, { line });
   api.nvim_feedkeys(right, 'n', false);
end
for i, bracket in pairs(bracketList) do
   vim.keymap.set("i", bracket[1], function()
      brackets(bracket[1], bracket[2])
   end)
end

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

--this works better than <ESC>O with lsps and statuslines
--this took hours of trying to perfect it all thanks to feedkeys
vim.keymap.set("i", "<CR>", function()
   local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
   local buf = api.nvim_buf_get_lines(0, 0, -1, false)
   local line = buf[cursorRow]
   local prev = strsub(line,cursorCol - 1, cursorCol - 1)
   local count = tostring(cursorCol)
   if prev == '{' then
      return '<CR><CMD>normal k$<CR><right><CR>';
   end
   return '<CR>'
end,{expr = true, noremap = true})
