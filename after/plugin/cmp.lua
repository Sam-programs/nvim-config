local cmp = require('cmp')
local icons = {
   Text = "",
   Method = "",
   Function = "",
   Constructor = "",
   Field = "",
   Variable = "",
   Class = "",
   Interface = "",
   Module = "",
   Property = "",
   Unit = "",
   Value = "",
   Enum = "",
   Keyword = "",
   Color = "",
   File = "",
   Reference = "",
   Folder = "",
   EnumMember = "",
   Constant = "",
   Struct = "",
   Event = "",
   Operator = "",
   TypeParameter = "",
}
cmp.setup.buffer({
   mapping = cmp.mapping.preset.insert({
      ["<cr>"] = cmp.mapping.confirm({
         select = true,
      }),

      ["<Tab>"] = cmp.mapping.confirm({
         select = true,
      }),

      ["<C-n>"] = cmp.mapping.select_next_item(),

      ["<C-p>"] = cmp.mapping.select_prev_item(),
   }),

   sources = {
      { name = "path",     group_index = 1 },
      { name = "nvim_lsp", group_index = 2 },
      { name = "buffer",   group_index = 2 },
   },
   formatting = {
      expandable_indicator = false,
      fields = { 'kind', 'abbr' },
      format = function(entry, item)
         item.kind = icons[item.kind] or " "
         return item
      end,
   },
   matching = {
      disallow_partial_matching = true,
   },

   window = {
      completion = {
         border = "rounded",
         scrollbar = false,
      },
      documentation = cmp.config.disable
   },

   experimental = {
      ghost_text = true,
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
      { name = 'path' }
   }, {
      {
         name = 'cmd',
         option = {
            ignore_cmds = { 'Man', '!' }
         }
      }
   })
})
