local cmp = require('cmp')
local cmp_win = require('cmp.utils.window')
local cmp_performance = nil
if eopts.cmp_ghost_text_only then
   cmp_win.update = function() end
   cmp_win.open = function(self, style)
      local yes = {
         relative = 'editor',
         style = 'minimal',
         -- placing it at the top right makes it blend with the theme
         col = vim.o.co,
         row = 0,
         width = 1,
         height = 1,
         zindex = 1,
      }
      self:set_style(yes)
      if self.win and vim.api.nvim_win_is_valid(self.win) then
         vim.api.nvim_win_set_config(self.win, yes)
      else
         self.win = vim.api.nvim_open_win(self:get_buffer(), false, yes)
      end
   end
   -- AS FAST AS FAST CAN BE
   cmp_performance = {
      confirm_resolve_timeout = 0,
      throttle                = 0,
      debounce                = 0,
      fetching_timeout        = 0,
      max_view_entries        = 1,
   }
end

local diagnosticsOn = true
local function InsertDiagnostics(fallback)
   diagnosticsOn = not diagnosticsOn
   vim.diagnostic.config({
      update_in_insert = diagnosticsOn,
   })
end

cmp.setup({
   mapping = cmp.mapping.preset.insert({
      ["<tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            return cmp.confirm({
               select = true
            })
         end
         fallback()
      end),
      ["<S-tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            return cmp.complete_common_string()
         end
         fallback()
      end),
      ["<c-d>"] = cmp.mapping(InsertDiagnostics),
   }),
   sources = {
      { name = "nvim_lsp", group_index = 1 },
      { name = "nvim_lua", group_index = 2 },
      { name = "path",     group_index = 2 },
   },
   matching = {
      disallow_prefix_unmatching = true,
   },
   snippet = {
      expand = function(args)
         unpack = unpack or table.unpack
         local line_num, col = unpack(vim.api.nvim_win_get_cursor(0))
         local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, true)[1]
         local replace = vim.split(args.body, '\n', true)
         local cursor_pos = col + #replace[1]
         replace[1] = line_text:sub(1, col) .. replace[1] .. line_text:sub(col + 1)

         vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, true, replace)
         vim.api.nvim_win_set_cursor(0, { line_num, cursor_pos })
      end,
   },
   experimental = {
      ghost_text = true
   },
   performance = cmp_performance,
})

local kind = cmp.lsp.CompletionItemKind
-- auto add semicolon
cmp.event:on('confirm_done', function(event)
   local entry = event.entry
   local item = entry:get_completion_item()
   local line = vim.api.nvim_get_current_line()
   local lastchar = line:sub(#line, #line)
   if lastchar ~= ';' and eopts.semicolon_langs[vim.o.filetype] then
      if item.kind == kind.Function or item.kind == kind.Method then
         vim.api.nvim_set_current_line(line .. ';')
      end
   else
      return
   end
end)
-- i don't use nvim-autopairs and this is simple enough for me
-- auto add pairs
local function pair_on_confirm(event)
   local entry = event.entry
   local item = entry:get_completion_item()
   local pairs = '()'
   local functionsig = item.label
   if item.kind == kind.Function or item.kind == kind.Method then
      -- auto skip empty functions
      if functionsig:sub(#functionsig - 1, #functionsig) ~= pairs then
         pairs = pairs .. '<left>'
         pairs = vim.api.nvim_replace_termcodes(pairs, true, false, true)
      end
      vim.api.nvim_feedkeys(pairs, "n", false)
   end
end

local function template_on_confirm(event)
   if not (vim.o.filetype == "c" or vim.o.filetype == "cpp")then
      return
   end
   local entry = event.entry
   local item = entry:get_completion_item()
   local _, c = unpack(vim.api.nvim_win_get_cursor(0))
   local line = vim.api.nvim_get_current_line()
   local pairs = ''
   local functionsig = item.label
   if line:sub(c, c) ~= '>' and
       (functionsig:sub(#functionsig, #functionsig) == '>' or
          functionsig == ' template')
   then
      if functionsig:sub(2, 8) == 'include' then
         pairs = ' '
      end
      pairs = pairs .. '<>'
      pairs = vim.api.nvim_replace_termcodes(pairs .. "<left>", true, false, true)
      vim.api.nvim_feedkeys(pairs, "n", false)
   end
end

cmp.event:on('confirm_done', template_on_confirm)

-- couldn't find a better place to put these
if true then
   cmp.event:on('confirm_done', pair_on_confirm)
   require('autopairs').setup()
   return
end


local npairs = require('nvim-autopairs')
npairs.setup({})
local rule = require('nvim-autopairs.rule')
local utils = require('nvim-autopairs.utils')
local ts_conds = require('nvim-autopairs.ts-conds')

local cpp_cond = function()
   local line = vim.api.nvim_get_current_line()
   -- only variable inits and structs/classes need semicolons
   local pattern = '^.*(.*)'

   if vim.fn.match({ line }, pattern) ~= 0 then
      return
   end
   return false
end

local conds = require('nvim-autopairs.conds')
npairs.add_rules({
   rule("{", "};", "cpp"):with_pair(
      cpp_cond
   ),
   rule("<", ">", "cpp"):
       with_pair(conds.none()):
       with_move(conds.done()),
})
local cond = require("nvim-autopairs.conds")
