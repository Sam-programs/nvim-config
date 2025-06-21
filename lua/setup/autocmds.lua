local autocmd = vim.api.nvim_create_autocmd

--preserves the last edit postion
vim.api.nvim_create_autocmd("BufRead", {
    callback = function()
        -- Only move when at the start of the file
        if (vim.api.nvim_win_get_cursor(0)[1] == 1) then
            local lastpos = vim.api.nvim_buf_get_mark(0, '\"')
            -- The mark is not set
            if (lastpos[1] == 0) then
                return
            end
            vim.api.nvim_win_set_cursor(0, lastpos)
        end
    end
})

--autocmd({ "FileType" }, {
--    pattern = "git",
--    callback = function()
--        vim.wo[0].spell = false
--    end
--})

autocmd({ "FileType" }, {
    pattern = { "c", "cpp", "lua" },
    callback = function()
        vim.wo[0].spell = true
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

autocmd({ "FileType" }, {

    pattern = "md",
    nested = true,
    callback = function(opts)
        vim.bo[opts.buf].ft = 'markdown';
    end,
})

vim.api.nvim_create_autocmd("WinScrolled", {
    pattern = "*",
    callback = function()
        local curwin = vim.api.nvim_get_current_win()
        local changes = vim.v.event[tostring(curwin)]
        if (not changes) then
            return
        end
        -- don't center floating windows
        local config = vim.api.nvim_win_get_config(curwin)
        if config.relative ~= "" then
            return
        end
        -- only center when fully leaving the viewport
        local height = vim.api.nvim_win_get_height(curwin)
        if changes.topline > height then
            pcall(vim.cmd, 'normal! zz')
        end
    end,
})

autocmd({ "User" }, {
    pattern = "LspProgressUpdate",
    callback = function()
        if vim.lsp.status == nil then
            return
        end
        local v = vim.lsp.status()[1]
        if v and v.done then
            print(v.name, 'loaded!')
        end
    end,
})

autocmd({ "BufEnter", "TermOpen" }, {
    pattern = "term://*",
    callback = function()
        vim.cmd("startinsert")
        vim.wo[0].spell = true
        vim.wo[0].nu = false
        vim.wo[0].rnu = false
        vim.wo[0].scl = "no"
        vim.wo[0].scrolloff = 0
    end,
})

autocmd({ "BufLeave" }, {
    pattern = "term://*",
    callback = function()
        if (vim.api.nvim_win_get_config(0).relative ~= "") then
            vim.api.nvim_win_hide(0)
        end
    end,
})
