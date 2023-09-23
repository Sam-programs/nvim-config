require("mason").setup({
   ui = {
      icons = {
         package_installed = "",
         package_pending = "",
         package_uninstalled = ""
      }
   }
})

local signs = {
   Error = "",
   Warn = "",
   Hint = "",
   Info = ""
}
for type, icon in pairs(signs) do
   local hl = "DiagnosticSign" .. type
   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local masonLspconfig = require("mason-lspconfig");
masonLspconfig.setup {
   ensure_installed = {
      "lua_ls",
      "cmake",
      "clangd",
   },
}
local masonBin = vim.fn.stdpath("data") .. 'mason/bin/'
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


require("lsp_signature").setup({
   bind = true, -- This is mandatory, otherwise border config won't get registered.
   hint_prefix = "󰇥 ", -- 󰇥 debugging duck
   handler_opts = {
      border = "rounded"
   },
   floating_window_off_x = -1, -- negative 1 to align with the border
   max_height = 2,             -- if u can't explain a function in 1 line i am going to your docs
})

vim.diagnostic.config({
   virtual_text = { prefix = ' ' },
   signs = true,
   underline = true,
   update_in_insert = false,
   severity_sort = true,
})

-- some lsp remaps are in telescope.lua
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<C-t>", vim.lsp.buf.hover)
vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float)
vim.keymap.set("n", "<C-f>", vim.diagnostic.goto_next)
vim.keymap.set("n", "<C-d>", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<C-c>", vim.cmd.CodeActionMenu)
