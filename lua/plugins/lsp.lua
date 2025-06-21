return {
    {
        'williamboman/mason.nvim',
        dependencies = {
            { 'williamboman/mason-lspconfig.nvim' },
            { 'neovim/nvim-lspconfig' },
        },
        priority = 998,
        config = function()
            require('mason').setup {
                ui = {
                    icons = eopts.mason_icons
                }
            }
            for type, icon in pairs(eopts.lsp_signs) do
                local hl = "DiagnosticSign" .. type
                local virthl = "DiagnosticVirtualText" .. type
                local linehl = "DiagnosticLine" .. type
                local hl_data = vim.api.nvim_get_hl(0, { name = virthl })
                hl_data.fg = nil
                vim.api.nvim_set_hl(0, linehl, hl_data)
                vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl, linehl = linehl })
            end

            local masonLspconfig = require("mason-lspconfig");
            masonLspconfig.setup {
                ensure_installed = eopts.lsps,
                exclude = {
                    "lua_ls"
                }
            }
            require 'lspconfig'.lua_ls.setup {
                on_init = function(client)
                    local path = client.workspace_folders and client.workspace_folders[1].name or '.'
                    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                        client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                            Lua = {
                                runtime = {
                                    -- Tell the language server which version of Lua you're using
                                    -- (most likely LuaJIT in the case of Neovim)
                                    version = 'LuaJIT'
                                },
                                -- Make the server aware of Neovim runtime files
                                workspace = {
                                    checkThirdParty = false,
                                    library = {
                                        vim.env.VIMRUNTIME
                                        -- "${3rd}/luv/library"
                                        -- "${3rd}/busted/library",
                                    }
                                    -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                                    -- library = vim.api.nvim_get_runtime_file("", true)
                                }
                            }
                        })

                        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                    end
                    return true
                end,
            }

            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                underline = false,
                update_in_insert = false,
                severity_sort = true,
            })

            -- some lsp remaps are in telescope.lua
            vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

            vim.keymap.set('n', '<C-e>', function()
                vim.diagnostic.open_float({
                    focusable = false,
                    border = "rounded",
                })
            end)
            vim.keymap.set('n', '<C-g>', function()
                vim.diagnostic.jump({
                    count = 1,
                    severity = vim.diagnostic.severity.ERROR,
                    wrap = false,
                    float = true,
                })
            end)
            vim.keymap.set('n', '<C-f>', function()
                vim.diagnostic.jump({
                    count = -1,
                    severity = vim.diagnostic.severity.ERROR,
                    wrap = false,
                    float = true,
                })
            end)

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    -- Use a sharp border with `FloatBorder` highlights
                    border = "rounded",
                    -- add the title in hover float window
                }
            )
            vim.keymap.set("n", "<c-h>", vim.lsp.buf.hover)
            local notify = vim.notify
            vim.notify = function(str, ...)
                if (str == 'No code actions available') then
                    return
                end
                notify(str, ...)
            end
            vim.keymap.set("n", "<leader>h", function()
                vim.cmd("ClangdSwitchSourceHeader")
            end)
            vim.keymap.set("i", "<A-h>", vim.lsp.buf.signature_help)

            vim.keymap.set("n", "<C-c>", function()
                local first = true
                vim.lsp.buf.code_action({
                    apply = true,
                    context = {
                        only = {
                            "quickfix"
                        }
                    },
                    filter = function(want_action)
                        if first then
                            first = false
                            return true
                        end
                        return false
                    end
                })
            end)
        end,
    },
}
