local cmp = require('cmp')
local luasnip_installed, luasnip = pcall(require, "luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
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
   Snippet = "",
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

      ["<C-n>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            cmp.select_next_item()
         elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
         else
            fallback()
         end
      end),

      ["<C-p>"] = cmp.mapping(function(fallback)
         if cmp.visible() then
            cmp.select_prev_item()
         elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
         else
            fallback()
         end
      end),
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

   snippet = {
      expand = function(args)
         luasnip.lsp_expand(args.body)
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
