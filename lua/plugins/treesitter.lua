return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = {
                    -- for cmdline-hl
                    "regex",
                    -- for general TODO comments
                    "comment",

                    -- bundled with neovim, but I have them here just in case their queries differ / the bundled ones get outdated
                    -- IDK
                    "vimdoc",
                    "vim",
                    "lua",
                    "c",

                    -- gotta love  me some web dev
                    "javascript",
                    "css",
                    "html",

                    -- c/c++ stuff
                    "cmake",
                    "cpp",
                    "glsl",
                    
                    -- storage files
                    "yaml",
                    "json",
                },
                sync_install = false,
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true
                },
            })
            vim.api.nvim_create_autocmd('BufRead', {
                pattern = '*.c*',
                callback = function()
                    -- removed ':'
                    vim.o.indentkeys = '0{,0},0),0],0#,!^F,o,O,e'
                end
            })
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
    {
        "nvim-treesitter/nvim-treesitter-context",
        after = "nvim-treesitter",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require 'treesitter-context'.setup {
                enable = true,           -- Enable this plugin (Can be enabled/disabled later via commands)
                max_lines = math.floor(vim.o.lines * 0.25),           -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0,   -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 6, -- Maximum number of lines to show for a single context
                trim_scope = 'outer',    -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',         -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }
        end
    },

}
