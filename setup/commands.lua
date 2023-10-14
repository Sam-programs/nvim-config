vim.api.nvim_create_user_command("T", function()
   local keys = vim.api.nvim_replace_termcodes("<C-w>v<C-w>l<cmd>term<cr>", true, false, true)
   vim.api.nvim_feedkeys(keys, 'n', false)
end, {})
vim.cmd("command Ps PackerSync")

local get_line = function(i)
   return vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
end

local function is_in_pair(search_start)
   for i = search_start, math.max(0, search_start - vim.o.mfd), -1 do
      local line = get_line(i)
      if vim.fn.match({ line }, '{') == 0 then
         if vim.fn.match({ line }, '}') < 0 then
            return true
         end
      else
         if vim.fn.match({ line }, '}') == 0 then
            return false
         end
      end
   end
   return false
end

local function lua_coma(line, lastchar)
   local r = vim.api.nvim_win_get_cursor(0)[1]
   if not is_in_pair(r - 1 - 1) then -- 1 for the indexing 1 for checking the line before us
      return
   end
   line = line .. ','
   vim.api.nvim_set_current_line(line)
   return true
end

local function c_coma(line, lastchar)
   local pattern = '^\\s*\\.'
   if lastchar == ',' then
      return
   end
   if vim.fn.match({ line }, pattern) == 0 then
      line = line .. ','
      vim.api.nvim_set_current_line(line)
      return true
   end
end

-- smartly place SemiColons or Comas
vim.api.nvim_create_user_command("AddSemi", function()
   local line = vim.api.nvim_get_current_line()
   local empty_pattern = '^\\s*$'
   if vim.fn.match({ line }, empty_pattern) == 0 then
      return
   end
   local lastchar = line:sub(#line, #line)
   if lastchar == ',' or lastchar == ';' then
      return
   end

   if (vim.o.filetype == 'lua')
       and
       (lua_coma(line)) then
      return
   end
   if (vim.o.filetype == 'c' and vim.o.filetype == 'cpp')
       and
       (c_coma(line)) then
      return
   end

   if eopts.semicolon_langs[vim.o.filetype] then
      line = line .. ';'
      vim.api.nvim_set_current_line(line)
   end
end, {})

vim.api.nvim_create_user_command("SemiEnd", function()
   local line = vim.api.nvim_get_current_line()
   local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
   if line:sub(#line, #line) == ';' then
      vim.api.nvim_win_set_cursor(0, { r, #line - 1 })
      return
   end
   vim.api.nvim_win_set_cursor(0, { r, #line })
end, {})

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
