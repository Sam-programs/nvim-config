--preserves the last edit postion
local autocmd = vim.api.nvim_create_autocmd
autocmd({ "BufRead" }, {
   pattern = { "*" },
   callback = function(ev)
      --the " mark points to the postion you exited from
      vim.cmd("silent! '\"")
      --the . mark points to the postion of the last write
      --vim.cmd("silent! '.")
      --silent because if the file was modified outside neovim it may be too small to jump to the last position
   end
})


autocmd({ "User" }, {
   pattern = "LspProgressUpdate",
   callback = function()
      local v = vim.lsp.util.get_progress_messages()[1]
      if v and v.done then
         print(v.name, 'loaded!')
      end
   end,
})

-- TermOpen because for startinsert doesn't get registered
autocmd({ "BufEnter", "TermOpen" }, {
   pattern = "term://*",
   callback = function()
      vim.cmd("startinsert")
      if vim.o.nu then
         vim.wo[0].nu = false
         vim.wo[0].rnu = false
         vim.wo[0].scl = "no"
         vim.api.nvim_win_set_width(0, 50)
      end
   end,
})
