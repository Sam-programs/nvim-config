return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-tree/nvim-web-devicons' } }, -- optional
        event = "VeryLazy",
        config = function()
            require('telescope').setup {
                defaults = {
                    prompt_prefix = ' ',
                    selection_caret = ' ',
                    layout_strategy = 'horizontal',
                    sorting_strategy = 'ascending',
                    results_title = '',
                    layout_config = {
                        horizontal = {
                            height = 0.9,
                            preview_cutoff = 120,
                            prompt_position = 'top',
                            width = 0.9,
                            preview_width = 0.5,
                        }
                    },
                    mappings = {
                        i = {
                            ["<C-n>"] = "move_selection_next",
                            ["<C-p>"] = "move_selection_previous",
                            ["<C-i>"] = "select_default",
                        },
                    }
                },
            }
            vim.keymap.set('n', '<leader>pf', function()
                require('telescope.builtin').find_files()
            end)
            vim.keymap.set('n', '<leader>pv', function() require('telescope.builtin').git_files() end)
            vim.keymap.set('n', '<leader>ps', function() require('telescope.builtin').live_grep() end)
            vim.keymap.set('n', '<leader>vh', function() require('telescope.builtin').help_tags() end)
            vim.keymap.set('n', '<leader>rr', function() require('telescope.builtin').lsp_references() end)
            vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end)
            vim.keymap.set('n', '<leader>m', function()
                require('telescope.builtin').man_pages({ sections = { "3X", "3", "2", "1" } })
            end)
            vim.keymap.set('n', '<leader>e', "<cmd>lua require(\'telescope.builtin\').diagnostics()<cr>")
        end,
    },
}
