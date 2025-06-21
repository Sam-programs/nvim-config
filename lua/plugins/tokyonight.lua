return {
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            local opts = {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                style = "storm",     -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
                light_style = "day", -- The theme is used when the background is set to light
                transparent = true, -- Enable this to disable setting the background color
                terminal_colors = false, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
                styles = {
                    -- Style to be applied to different syntax groups
                    -- Value is any valid attr-list value for `:help nvim_set_hl`
                    comments = { italic = true },
                    keywords = { italic = true },
                    functions = {},
                    variables = {},

                },
                sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
            }
            require('tokyonight').setup(opts)
            vim.cmd [[ colorscheme tokyonight]]
            vim.api.nvim_set_hl(0, "TermNormal", {
                bg = "#222436"
            })
            vim.api.nvim_set_hl(0, 'MsgArea', { link = 'TermNormal' })
            vim.api.nvim_set_hl(0, '@lsp.typemod.variable.globalScope.c', { link = '@constant' })
            vim.api.nvim_create_autocmd({ "TermOpen" }, {
                pattern = "*",
                callback = function()
                    vim.wo[0].winhl = 'Normal:TermNormal'
                end,
            })
            vim.api.nvim_create_autocmd({ "FileType" }, {
                pattern = "man",
                callback = function()
                    vim.wo[0].winhl = 'Normal:TermNormal'
                end,
            })
            local bg = "#101010"
            local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
            normal.bg = bg
            vim.api.nvim_set_hl(0, "Normal", normal)
            vim.api.nvim_set_hl(0, "NormalNC", normal)
            vim.api.nvim_set_hl(0, "SignColumn", normal)

            local normalSB = vim.api.nvim_get_hl(0, { name = "NormalSB" })
            normalSB.bg = nil
            normalSB = {
                fg = "#7aa2f7",
            }
            vim.api.nvim_set_hl(0, "@lsp.type.comment.lua", {})
            vim.api.nvim_set_hl(0, "WinSeparator", normalSB)
            -- this is what every good developer does
            vim.api.nvim_set_hl(0, "@lsp.type.unresolvedReference.rust", {})
            vim.o.fillchars = 'vert:▕'

            vim.api.nvim_set_hl(0, "@lsp.type.macro.cpp", {})
        end,
    },

}
