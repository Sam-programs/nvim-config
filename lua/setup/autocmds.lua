local autocmd = vim.api.nvim_create_autocmd

--preserves the last edit postion
autocmd({ "BufRead" }, {
   pattern = { "*" },
   callback = function()
      vim.cmd("silent! '\"")
   end
})

local new_file = false
autocmd({ "BufWritePre" }, {
   pattern = { "*.c", "*.cpp" },
   callback = function(ev)
      if vim.fn.filereadable(ev.file) == 0 then
         new_file = true
      end
   end
})



autocmd({ "ModeChanged" }, {
   pattern = "*",
   callback = function(ev)
      log(vim.v.event.old_mode)
      log(vim.v.event.new_mode)
   end
})




local do_not_cmake = false
local command = vim.api.nvim_create_user_command
command("TCmake", function()
   do_not_cmake = not do_not_cmake
end, {})

autocmd({ "BufWritePost" }, {
   pattern = { "*.c", "*.cpp" },
   callback = function()
      if not do_not_cmake then
         if new_file then
            if #vim.fn.glob("src/CMakeLists.txt") ~= 0 then
               vim.fn.system(
                  [[ /usr/bin/cmake src ]]
               )
            end
         end
      end
      new_file = false
   end
})


-- hardcoded until i get bored enough to read the lsp docs
local lsp_langs = {
   c = true,
   cpp = true,
   lua = true,
}

autocmd({ "FileType" }, {
   pattern = { "*" },
   callback = function()
      if lsp_langs[vim.o.filetype] then
         vim.wo[0].scl = "yes"
      else
         vim.wo[0].scl = "no"
      end
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
      vim.wo[0].nu = false
      vim.wo[0].rnu = false
      vim.wo[0].scl = "no"
      -- 48 leaves 80 coulmns for code
      vim.api.nvim_win_set_width(0, 48)
   end,
})
