return {
   {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
         local configs = require("nvim-treesitter.configs")

         configs.setup({
            ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html" },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
         })
         vim.opt.indentkeys = '0{,0},0),0],0#,!^F,o,O,e'
      end,
   },
   {
      "nvim-treesitter/nvim-treesitter-textobjects",
      after = "nvim-treesitter",
      dependencies = "nvim-treesitter/nvim-treesitter",
      config = function()
         local opts = {
            textobjects = {
               move = {
                  enable = true,
                  set_jumps = false, -- whether to set jumps in the jumplist
                  goto_next_start = {
                     ["<C-n>"] = "@function.outer",
                  },
                  goto_previous_start = {
                     ["<C-p>"] = "@function.outer",
                  },
               },
            },
         }
         require('nvim-treesitter.configs').setup(opts)
      end
   },
}
