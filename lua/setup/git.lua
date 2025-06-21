local uv = vim.loop or vim.uv
-- wrapper that runs git with args
local function git(args, opts)
    opts = opts or {}
    local stdin = uv.new_pipe()
    local stdout = uv.new_pipe()
    local stderr = uv.new_pipe()
    local _, pid = uv.spawn("git", {
        stdio = { stdin, stdout, stderr },
        args = args
    }, function() end) -- on exit
    local stdout_data = ""
    local stderr_data = ""
    local stdout_done
    if opts.stdin then
        stdin:write(opts.stdin)
        stdin:close()
    end
    -- start of the last line
    local last_line = ""
    uv.read_start(stdout, function(err, data)
        assert(not err, err)
        if data then
            stdout_data = stdout_data .. data
            if (opts.on_stdout) then
                local lines = vim.split(data, '\n')
                opts.on_stdout(last_line .. lines[1])
                for i = 2, #lines - 1, 1 do
                    opts.on_stdout(lines[i])
                end
                last_line = lines[#lines]
            end
        else
            if (opts.on_stdout_done) then
                opts.on_stdout_done(stdout_data)
            end
            stdout_done = true
            uv.kill(pid, 0)
        end
    end)
    uv.read_start(stderr, function(err, data)
        assert(not err, err)
        if data then
            stderr_data = stderr_data .. data
        end
    end)
    if (not opts.async) then
        vim.wait(opts.timeout or (5 * 60), function()
            return stdout_done
        end, 2)
    end
    if (stdout_data == "") then
        vim.notify(vim.trim(stderr_data), vim.log.levels.WARN, {})
    end
    return stdout_data, stderr_data
end
local function refresh_bufs()
    local old_lz = vim.o.lz
    vim.o.lz = true
    local curbuf = vim.api.nvim_get_current_buf()
    -- update all open buffers after the new patch
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if (vim.api.nvim_buf_get_name(bufnr) ~= "") then
            vim.cmd('b ' .. bufnr)
        end
    end
    vim.cmd('b ' .. curbuf)
    vim.o.lz = old_lz
end

------------------------------------------------------------------------------------------------------------------------------
-- Git mappings
------------------------------------------------------------------------------------------------------------------------------

local map = vim.keymap.set

map("n", "<leader>ap", function()
    local stdout = git({ 'apply', '-', }, {
        stdin = vim.fn.getreg("+")
    })
    if (stdout == "") then
        return
    end
    refresh_bufs()
end)

map("n", "<leader>yd", function()
    local range
    if (vim.v.count ~= 0) then
        range = 'HEAD~' .. vim.v.count
    end
    local stdout = git({ 'diff', range, 'HEAD' })
    if (stdout == "") then
        return
    end
    vim.fn.setreg("+", stdout)

end)

------------------------------------------------------------------------------------------------------------------------------
-- Git commands
------------------------------------------------------------------------------------------------------------------------------

local command = vim.api.nvim_create_user_command
local branch_complete = function(arglead, _, _)
    local stdout = git({ "branch", "--list" })
    if (stdout == "") then
        return
    end
    local branches = vim.split(stdout, '\n')
    -- the last splited line is empty
    branches[#branches] = nil
    for i = 1, #branches, 1 do
        -- skip white space
        branches[i] = branches[i]:sub(3)
        if (branches[i]:sub(1, #arglead) ~= arglead) then
            branches[i] = nil
        end
    end
    local list = {}
    for _, branch in pairs(branches) do
        list[#list + 1] = branch
    end
    return list
end

command("GitSwitch",
    function(args)
        git({ "switch", vim.trim(args.args) })
    end,
    {
        complete = branch_complete,
        nargs = 1,
    })
command("GitBranch",
    function(args)
        local stdout = git({ "branch", unpack(args.fargs or {}) }, {})
        if stdout == "" then
            return
        end
        local output = {}
        local branches = vim.split(stdout, '\n')
        for i = 1, #branches, 1 do
            if (branches[i]:sub(1, 1) == "*") then
                output[i] = { branches[i] .. "\n", "MatchParen" }
            else
                if i == #branches then
                    output[i] = { branches[i], "ModeMsg" }
                else
                    output[i] = { branches[i] .. "\n", "ModeMsg" }
                end
            end
        end
        vim.api.nvim_echo(output, false, {})
    end, { nargs = "*", complete = branch_complete })

command("GitLog",
    function()
        local buf = vim.api.nvim_create_buf(true, false)
        vim.bo[buf].ft = 'git'
        vim.bo[buf].buftype = 'nofile'
        vim.keymap.set("n", 'j', function()
            local line = vim.fn.search('^commit', 'Wnz')
            if (line == 0) then
                return
            end
            return line .. "G"
        end, { buffer = buf, expr = true })
        vim.keymap.set("n", 'k', function()
            local line = vim.fn.search('^commit', 'nzb')
            local curline = vim.api.nvim_win_get_cursor(0)[1]
            -- W doesn't work with backward search
            if (line > curline) then
                return
            end
            return line .. "G"
        end, { buffer = buf, expr = true })
        local win = vim.api.nvim_open_win(buf, true, {
            relative = 'editor',
            width = math.floor(0.8 * vim.o.co),
            height = math.floor(0.8 * vim.o.lines),
            row = math.floor(0.1 * vim.o.lines),
            col = math.floor(0.1 * vim.o.co),
            border = "rounded"
        })
        vim.wo[win].nu = false
        vim.wo[win].rnu = false
        vim.bo[buf].bufhidden = 'wipe'
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "git log loading..." })
        git({ "log" }, {
            async = true,
            on_stdout_done = vim.schedule_wrap(function(stdout)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(stdout, '\n'))
                vim.cmd.normal("ggw")
            end)
        })
    end, {})
