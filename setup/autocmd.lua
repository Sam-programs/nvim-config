--preserves the last edit postion
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
   pattern = { "*" },
   callback = function(ev)
      --the " mark points to the postion you exited from
      vim.cmd("silent! '\"")
      --the . mark points to the postion of the last write
      --vim.cmd("silent! '.")
      --silent because if the file was modified outside neovim it may be too small to jump to the last position
   end
})

-- got the idea from https://github.com/yutkat/dotfiles/blob/main/.config/nvim/lua/rc/autocmd.lua#L4
vim.api.nvim_create_autocmd({ "WinEnter", "InsertLeave" }, {
   pattern = "*",
   callback = function()
      if vim.o.nu then
         vim.wo[0].rnu = true
      end
   end,
   once = false,
})

vim.api.nvim_create_autocmd({ "WinLeave", "InsertEnter" }, {
   pattern = "*",
   callback = function()
      if vim.o.nu then
         vim.wo[0].rnu = false
      end
   end,
   once = false,
})

vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
   pattern = "term://*",
   callback = function()
      vim.cmd("startinsert")
      if vim.o.nu then
         vim.wo[0].nu = false
         vim.wo[0].rnu = false
         vim.wo[0].scl = "no" 
         vim.api.nvim_win_set_width(0,50)
      end
   end,
})
