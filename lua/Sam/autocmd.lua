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
