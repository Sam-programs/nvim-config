return {
   {
      'weilbith/nvim-code-action-menu',
      cmd = 'CodeActionMenu',
      event = 'VeryLazy',
   },
   {
      'williamboman/mason.nvim',
      dependencies = {
         { 'williamboman/mason-lspconfig.nvim' },
         { 'neovim/nvim-lspconfig' },
      },
      config = function()
         require('mason').setup {
            ui = {
               icons = eopts.mason_icons
            }
         }
         for type, icon in pairs(eopts.lsp_signs) do
            local hl = "DiagnosticSign" .. type
            -- don't ask why DiffChange
            vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl, linehl = "DiffChange" })
         end

         local masonLspconfig = require("mason-lspconfig");
         masonLspconfig.setup {
            ensure_installed = eopts.lsps,
         }

         local lspconfig = require("lspconfig")
         masonLspconfig.setup_handlers {
            -- The first entry (without a key) will be the default handler
            -- and will be called for each installed server that doesn't have
            -- a dedicated handler.
            function(server_name) -- default handler (optional)
               lspconfig[server_name].setup {}
            end,
            -- Next, you can provide a dedicated handler for specific servers.
            -- For example, a handler override for the `rust_analyzer`:
            ["lua_ls"] = function()
               lspconfig.lua_ls.setup {
                  settings = {
                     Lua = {
                        diagnostics = {
                           globals = { "vim", "eopts" },
                        },
                     },
                  },
               }
            end,
         }

         vim.diagnostic.config({
            virtual_text = { prefix = ' ' },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
         })

         -- some lsp remaps are in telescope.lua
         vim.keymap.set("n", "<leader>rn", function()
            -- https://github.com/neovim/neovim/issues/24297#issuecomment-1782245297
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.lsp.buf.rename()
         end)
         vim.keymap.set('n', '<leader>f', function()
            -- https://github.com/neovim/neovim/issues/24297#issuecomment-1782245297
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.lsp.buf.format()
         end)
         vim.keymap.set("n", "<c-h>", vim.lsp.buf.hover)
         vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float)
         vim.keymap.set("n", "<C-f>", vim.diagnostic.goto_next)
         vim.keymap.set("n", "<C-d>", vim.diagnostic.goto_prev)
         vim.keymap.set("n", "<C-c>", vim.cmd.CodeActionMenu)
      end,
   }
}
