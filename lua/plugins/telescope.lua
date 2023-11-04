return {
   {
      'nvim-telescope/telescope.nvim',
      branch = '0.1.x',
      dependencies = {
         { 'nvim-lua/plenary.nvim' },
         { 'nvim-tree/nvim-web-devicons' } }, -- optional
      config = function()
         require('telescope').setup {
            defaults = {
               prompt_prefix = ' ',
               selection_caret = ' ',
               layout_strategy = 'horizontal',
               results_title = '',
               layout_config = {
                  horizontal = {
                     height = 0.9,
                     preview_cutoff = 120,
                     prompt_position = "top",
                     width = 0.9,
                     preview_width = 0.5,
                  }
               },
               sorting_strategy = 'ascending',
            },
         }
         vim.keymap.set('n', '<leader>pf', "<cmd>lua require(\'telescope.builtin\').find_files()<cr>")
         vim.keymap.set('n', '<leader>pv', "<cmd>lua require(\'telescope.builtin\').git_files()<cr>")
         vim.keymap.set('n', '<leader>ps', "<cmd>lua require(\'telescope.builtin\').live_grep()<cr.")
         vim.keymap.set('n', '<leader>vh', "<cmd>lua require(\'telescope.builtin\').help_tags()<cr>")
         vim.keymap.set('n', '<leader>rr', "<cmd>lua require(\'telescope.builtin\').lsp_references()<cr>")
         vim.keymap.set('n', 'gd', "<cmd>lua require(\'telescope.builtin\').lsp_definitions()<cr>")
         vim.keymap.set('n', '<leader>m',
            "<cmd>lua require(\'telescope.builtin\').man_pages({ sections = { \"3\", \"2\", \"1\" } })<cr>")
         vim.keymap.set('n', '<leader>e', "<cmd>lua require(\'telescope.builtin\').diagnostics()<cr>")
      end,
   },
}
