local cmp = require('cmp')

cmp.setup.buffer({
   mapping = cmp.mapping.preset.insert({
      ["<tab>"] = cmp.mapping(function(fallback)
         if cmp.visible() == false then
            cmp.complete()
         end
         cmp.confirm({
            select = true,
         })
      end),
   }),
   sources = {
      { name = "path",     group_index = 1 },
      { name = "nvim_lsp", group_index = 2 },
      { name = "buffer",   group_index = 3 },
   },
   matching = {
      disallow_partial_matching = true,
   },
   completion = {
      autocomplete = false
   },
   snippet = {
      expand = function(args)
         unpack = unpack or table.unpack
         local line_num, col = unpack(vim.api.nvim_win_get_cursor(0))
         local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, true)[1]
         local indent = string.match(line_text, '^%s*')
         local replace = vim.split(args.body, '\n', true)
         local surround = string.match(line_text, '%S.*') or ''
         local surround_end = surround:sub(col)

         replace[1] = surround:sub(0, col - 1) .. replace[1]
         replace[#replace] = replace[#replace] .. (#surround_end > 1 and ' ' or '') .. surround_end
         if indent ~= '' then
            for i, line in ipairs(replace) do
               replace[i] = indent .. line
            end
         end

         vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, true, replace)
         vim.api.nvim_win_set_cursor(0,{line_num,#replace[1]})
      end,
   },
})

-- '/' cmdline setup
cmp.setup.cmdline('/', {
   mapping = cmp.mapping.preset.cmdline(),
   sources = {
      { name = 'buffer' }
   },
   formatting = {
      fields = { 'abbr' }
   }
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
   mapping = cmp.mapping.preset.cmdline({
      ["<tab>"] = cmp.mapping.complete(),
   }),
   formatting = {
      fields = { 'abbr' }
   },
   sources = cmp.config.sources({
      {
         name = 'cmd',
      }
   })
})
