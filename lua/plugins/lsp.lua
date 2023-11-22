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
         vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
         vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
         vim.keymap.set("n", "<c-h>", vim.lsp.buf.hover)
         vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float)
         vim.keymap.set("n", "<C-f>", vim.diagnostic.goto_next)
         vim.keymap.set("n", "<C-d>", vim.diagnostic.goto_prev)
         vim.keymap.set("n", "<C-c>", vim.cmd.CodeActionMenu)
      end,
   },
   {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      config = function()
         local opts = {
            bind = true,   -- This is mandatory, otherwise border config won't get registered.
            -- If you want to hook lspsaga or other signature handler, pls set to false
            doc_lines = 0, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
            -- set to 0 if you DO NOT want any API comments be shown

            max_height = 3,                        -- max height of signature floating_window
            max_width = 80,                        -- max_width of signature floating_window
            floating_window = true,                -- show hint in a floating window, set to false for virtual text only mode

            floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
            -- will set to true when fully tested, set to false will use whichever side has more space
            -- this setting will be helpful if you do not want the PUM and floating win overlap

            floating_window_off_x = 1, -- adjust float windows x position.
            -- can be either a number or function
            floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
            -- can be either number or function, see examples

            close_timeout = 4000,                         -- close floating window after ms when laster parameter is entered
            fix_pos = true,                               -- set to true, the floating window will not auto-close until finish all parameters
            hint_enable = false,                          -- virtual hint enable
            hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
            handler_opts = {
               border = "rounded"                         -- double, rounded, single, shadow, none, or a table of borders
            },

            always_trigger = false,   -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

            auto_close_after = nil,   -- autoclose signature float win after x sec, disabled if nil.
            extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
            zindex = 200,             -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

            padding = '',             -- character to pad on left and right of signature can be ' ', or '|'  etc

            timer_interval = 100,     -- default timer check interval set to lower value if you want to reduce latency
         }
         require 'lsp_signature'.on_attach(opts)
      end
   }
}
