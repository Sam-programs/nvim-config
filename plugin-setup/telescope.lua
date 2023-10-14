local builtin = require('telescope.builtin')
local telescope = require('telescope')
telescope.setup {
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

vim.keymap.set('n', '<leader>pf', builtin.find_files)

vim.keymap.set('n', '<leader>pg', function()
   builtin.find_files({cwd = vim.fn.expand("~/code")})
end)

vim.keymap.set('n', '<leader>pv', builtin.git_files)
vim.keymap.set('n', '<leader>gc', builtin.git_commits)

vim.keymap.set('n', '<leader>ps', function()
   builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags)
vim.keymap.set('n', '<leader>rr', builtin.lsp_references)
vim.keymap.set('n', 'gd', builtin.lsp_definitions)

vim.keymap.set('n', '<leader>m', function()
   builtin.man_pages({ sections = { "3", "2", "1" } })
end)
vim.keymap.set('n', '<leader>e', builtin.diagnostics)
