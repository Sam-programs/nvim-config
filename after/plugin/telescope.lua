local builtin = require('telescope.builtin')
local telescope = require('telescope')
telescope.setup {
   defaults = {
      prompt_prefix = '-> ',
      selection_caret = '> ',
      layout_strategy = 'flex',
   },
}
vim.keymap.set('n', '<leader>pf', builtin.find_files)
vim.keymap.set('n', '<leader>pv', builtin.git_files)
vim.keymap.set('n', '<leader>ps', function()
   builtin.grep_string({ search = vim.fn.input("Grep > ")})
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>rr', builtin.lsp_references, {})
vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})

