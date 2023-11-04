return { {
   'lukas-reineke/indent-blankline.nvim',
   event = 'VeryLazy',
   main = 'ibl',
   opts = {
      indent = {
         char = '▏',
         smart_indent_cap = true,
      },
      scope = { enabled = false }
   },
} }
