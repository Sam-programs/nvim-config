if true then
    return {
        {
            'Sam-programs/cmdline-hl.nvim',
            event = 'VimEnter',
            config = function()
                local cmdline_hl = require('cmdline-hl')
                cmdline_hl.setup({
                    custom_types = {
                    },
                    aliases = {
                        ['w'] = { str = 'W' },
                        ['git branch'] = { str = 'GitBranch' },
                        ['git log'] = { str = 'GitLog' },
                        ['git switch'] = { str = 'GitSwitch' },
                    },
                    ghost_text = true,
                })
                require('cmdline-hl.scripts').Bang_command()
                cmdline_hl.setup({
                    custom_types = {
                        ['Bang'] = { icon = "!", lang = "bash", show_cmd = false }
                    },
                    aliases = {
                        ['!'] = { str = 'Bang ' }
                    }
                })
                require('cmdline-hl.scripts').Cd_command()
                cmdline_hl.setup({
                    custom_types = {
                        ['Cd'] = { show_cmd = true }
                    },
                    aliases = {
                        ['cd'] = { str = 'Cd' }
                    }
                })

                vim.keymap.set('c', '<C-l>', '<up>')
            end
        },
    }
end
return {
    -- lazy.nvim
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        config = function()
            require('noice').setup({
                lsp = {
                    signature = { enabled = false },
                },
                commands = {
                    history = {
                        -- options for the message history that you get with `:Noice`
                        view = "split",
                        opts = { enter = true, format = "details" },
                        filter = {
                            clear_filters = true,
                        },
                    },
                }
            })
        end,
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    }
}
