require("mason").setup({
   ui = {
      icons = {
         package_installed = "",
         package_pending = "",
         package_uninstalled = ""
      }
   }
})

local masonLspconfig = require("mason-lspconfig");
masonLspconfig.setup {
   ensure_installed = {
      "lua_ls",
      "cmake",
      "clangd",
   },
}

local masonBin = os.getenv("HOME") .. '/.local/share/nvim/mason/bin/'
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
                  globals = { "vim" },
               },
            },
         },
      }
   end,
}

local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
   local hl = "DiagnosticSign" .. type
   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

require("lsp_signature").setup({
   bind = true, -- This is mandatory, otherwise border config won't get registered.
   hint_prefix = "󰇥 ", -- 󰇥 debugging duck
   handler_opts = {
      border = "rounded"
   }
})

vim.diagnostic.config({
  virtual_text = { prefix=' '},
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<C-t>", vim.lsp.buf.hover)
vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float)
vim.keymap.set("n", "<C-f>", vim.diagnostic.goto_next)
vim.keymap.set("n", "<C-d>", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<C-c>", vim.cmd.CodeActionMenu)
