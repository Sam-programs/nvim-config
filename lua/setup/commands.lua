local command = vim.api.nvim_create_user_command
command("T", function()
    local old_lz = vim.o.lz
    vim.o.lz = true
    vim.cmd [[exe "normal! \<C-w>v\<C-w>l\<Cmd>term\<Cr>" ]]
    vim.o.lz = old_lz
    vim.api.nvim_win_set_width(0,48)
end, {})

local get_line = function(i)
    return vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
end
local match =
    function(str, pat)
        if vim.fn.match({ str }, pat) == 0 then
            return true
        end
        return false
    end

local function is_in_pair(search_start)
    local line = get_line(search_start + 1)
    for i = search_start, math.max(0, search_start - vim.o.mfd), -1 do
        line = get_line(i)
        if match(line, '{') then
            if not match(line, '}') then
                return true
            end
        else
            if match(line, '}') then
                return false
            end
        end
    end
    return false
end

local function lua_coma(line, lastchar)
    local r = vim.api.nvim_win_get_cursor(0)[1]
    if not is_in_pair(r - 1 - 1) then -- 1 for the indexing 1 for checking the line before us
        return
    end
    line = line .. ','
    vim.api.nvim_set_current_line(line)
    return true
end

local function c_coma(line, lastchar)
    local pattern = '^\\s*\\.'
    if lastchar == ',' then
        return
    end
    if match(line, pattern) then
        line = line .. ','
        vim.api.nvim_set_current_line(line)
        return true
    end
end

-- smartly place SemiColons or Comas
command("AddSemi", function()
    local line = vim.api.nvim_get_current_line()
    local empty_pattern = '^\\s*$'
    if match(line, empty_pattern) then
        return
    end
    local lastchar = line:sub(#line, #line)
    if lastchar == ',' or lastchar == ';' then
        return
    end

    if (vim.o.filetype == 'lua')
        and
        (lua_coma(line)) then
        return
    end
    if (vim.o.filetype == 'c' or vim.o.filetype == 'cpp')
        and
        ((c_coma(line)) or
            match(line, "#include") or match("template"))
    then
        return
    end
    if eopts.semicolon_langs[vim.o.filetype] then
        line = line .. ';'
        vim.api.nvim_set_current_line(line)
    end
end, {})
