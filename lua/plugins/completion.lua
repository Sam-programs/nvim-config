return {
   {
      "Sam-programs/autopairs.nvim",
      event = 'VeryLazy',
   },
   {
      "windwp/nvim-autopairs",
      event = "VeryLazy"
   },
   {
      'Sam-programs/nvim-cmp',
      dependencies = {
         { 'hrsh7th/cmp-buffer' },
         { 'hrsh7th/cmp-path' },
         { 'hrsh7th/cmp-nvim-lua' },
         { 'hrsh7th/cmp-nvim-lsp' },
      },
      event = 'VeryLazy',
      config = function()
         local cmp = require('cmp')
         local cmp_win = require('cmp.utils.window')
         local cmp_performance = nil
         local kind = cmp.lsp.CompletionItemKind
         GhostText = vim.api.nvim_get_hl(0, { name = "Comment" })
         GhostText.italic = false
         vim.api.nvim_set_hl(0, "CmpGhostText", GhostText)

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
               -- useful for S-Tab
               max_view_entries        = 50,
            }
         end

         cmp.setup({
            enabled = function()
               if vim.o.ft == 'TelescopePrompt' then
                  return
               end
               return true
            end,
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

               ["<c-e>"] = cmp.config.disable,
               ["<c-d>"] = cmp.config.disable,
            }),
            sources = {
               { name = "nvim_lsp", group_index = 1 },
               { name = "buffer", group_index = 2 },
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
                  replace = { replace[1] }
                  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, true, replace)
                  vim.api.nvim_win_set_cursor(0, { line_num, cursor_pos })
               end,
            },
            experimental = {
               ghost_text = {
                  hl_group = "CmpGhostText",
                  inline_emulation = true,
               }
            },
            performance = cmp_performance,
         })
         local cmp_config = require('cmp.config')
         local cmp_comparetors = cmp_config.get().sorting.comparators
         local unpack = unpack or table.unpack
         local function cpp_sort_cmp(entry1, entry2)
            local kind1 = entry1.completion_item.kind
            local kind2 = entry2.completion_item.kind
            if vim.o.filetype ~= "cpp" then
               return nil
            end
            if kind1 == kind.Constructor and kind2 == kind.Class then
               return false
            end
            if kind1 == kind.Class and kind2 == kind.Constructor then
               return true
            end
            return nil
         end
         -- i don't use nvim-autopairs and this is simple enough for me
         -- auto add pairs
         local function pair_on_confirm(event)
            local entry = event.entry
            local item = entry:get_completion_item()
            local pairs = '()'
            local functionsig = item.label
            local c = vim.api.nvim_win_get_cursor(0)[2]
            local line = vim.api.nvim_get_current_line()
            if line:sub(c + 1, c + 1) ~= '(' and
                item.kind == kind.Function or item.kind == kind.Method then
               -- auto skip empty functions
               if functionsig:sub(#functionsig - 1, #functionsig) ~= pairs then
                  pairs = pairs .. '<left>'
                  pairs = vim.api.nvim_replace_termcodes(pairs, true, false, true)
               end
               vim.api.nvim_feedkeys(pairs, "n", false)
            end
         end

         local function template_on_confirm(event)
            if not (vim.o.filetype == "c" or vim.o.filetype == "cpp") then
               return
            end
            local entry = event.entry
            local item = entry:get_completion_item()
            local _, c = unpack(vim.api.nvim_win_get_cursor(0))
            local line = vim.api.nvim_get_current_line()
            local pairs = ''
            local functionsig = item.label
            local is_function = item.kind == kind.Function
            if is_function then
               return
            end
            if line:sub(c, c) ~= '>' and
                (vim.fn.match(functionsig, '<.*>') ~= -1 or
                   functionsig == ' template')
            then
               if functionsig:sub(2, 8) == 'include' then
                  vim.api.nvim_feedkeys(" ", "n", false)
                  return
               end
               pairs = pairs .. '<>'
               local old_lz = vim.o.lz
               vim.o.lz = true
               pairs = vim.api.nvim_replace_termcodes(
                  pairs .. "<C-g>u<left>" .. "<cmd>lua vim.o.lz =" .. (old_lz and "true" or "false") .. "<cr>", true,
                  false, true)
               vim.api.nvim_feedkeys(pairs, "n", false)
            end
         end

         if loaded_cpp_sort == false then
            cmp.setup({
               sorting = {
                  comparators = {
                     cpp_sort_cmp,
                     unpack(cmp_comparetors),
                  }
               }
            })
            loaded_cpp_sort = true
         end
         require('autopairs').setup {}
         cmp.event:on('confirm_done', pair_on_confirm)
         cmp.event:on('confirm_done', template_on_confirm)

         cmp.event:on('confirm_done', function(event)
            local entry = event.entry
            local item = entry:get_completion_item()
            local line = vim.api.nvim_get_current_line()
            local lastchar = line:sub(#line, #line)
            if lastchar ~= ';' and eopts.semicolon_langs[vim.o.filetype] then
               if item.kind == kind.Function or item.kind == kind.Method then
                  local r = vim.api.nvim_win_get_cursor(0)[1]
                  r = r - 1
                  vim.api.nvim_buf_set_text(0, r, #line, r, #line, { ';' })
               end
            end
         end)
      end
   } }
