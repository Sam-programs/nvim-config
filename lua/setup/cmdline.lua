local cmdbuf = vim.api.nvim_create_buf(false, true)
vim.bo[cmdbuf].buftype = 'nowrite'
local win = 0
local cusor_mark = nil
vim.o.wildmode = ""

local title_map = {
    [":"] = "CmdLine",
    ["?"] = "Search ",
    ["/"] = "Search ",
    ["="] = "Calculator",
}
local M = {}

function M.setup(opts)
    M = vim.tbl_extend("force", M, opts or {})
end

M.title = function(type, _, prompt)
    if prompt ~= "" then
        return prompt
    end
    return title_map[type]
end

M.row = function(_, _, _)
    return -3
end

M.col = function(type, content, _)
    local col = 0
    if type == '/' or type == '?' then
        col = - #content - 3
    else
        if type ~= "" then
            col = -3
        else
            col = -1 - #content
        end
    end
    return col
end

M.width = function(type, content, prompt)
    local title = M.title(type, content, prompt)
    if #title > 25 then
        return #title + 8
    end
    if #content < 25 then
        return 30
    end
    -- ceil(content / 10)
    return (#content / 8 + 1) * 8
end

M.relative = function(_, _, _)
    return 'Cursor'
end

M.height = function(_, _, _) return 1 end

M.title_pos = function(_, _, prompt)
    if prompt ~= "" then
        return "center"
    end
    return "left"
end

local function esc(str)
    return vim.api.nvim_replace_termcodes(str, true, false, true)
end

local function open()
    win =
        vim.api.nvim_open_win(cmdbuf, false, {
            relative = 'editor',
            row = 1,
            col = 1,
            width = 1,
            height = 1,
            noautocmd = true,
            zindex = 1000,
        })
    -- HACK: hide hlsearch
    vim.wo[win].winhl = "Normal:NormalFloat,Border:FloatBorder,CurSearch:HIDDEN,Search:HIDDEN"
    vim.wo[win].nu = false
    vim.wo[win].rnu = false
end

local type_sign = {
    [":"] = "CmdLine",
    ["/"] = "Search",
    ["?"] = "Search",
    ["="] = "Calculator",
}
vim.opt.guicursor:append { 'c:HIDDEN', 'ci:HIDDEN', 'cr:HIDDEN' }
vim.fn.sign_define('CmdLine', { text = " ", texthl = "FloatBorder" })
vim.fn.sign_define('Search', { text = " ", texthl = "FloatBorder" })
vim.fn.sign_define('Calculator', { text = " ", texthl = "FloatBorder" })
local ts_started = false
local gdata = ""
local gtype = ""
local prompt = ""
local gpos = 0
local old_pos = 0
local old_data = "anything"

local redrawing = false
vim.keymap.set('c', '<Plug>r', function()
    vim.fn.setcmdline(gdata, gpos + 1)
    redrawing = false
    return ''
end, { expr = true })
vim.keymap.set('n', '<Plug>r', function()
end)

local cmdline_ns = vim.api.nvim_create_namespace('cmdline')
-- id for signs
local id = 0
vim.api.nvim_set_hl(0, 'HIDDEN', { blend = 100, nocombine = true })
local call_c = 0
local handler = {
    ["cmdline_hide"] = function()
        local old_ei = vim.o.ei
        call_c = 0
        if ts_started then
            vim.treesitter.stop(cmdbuf)
            ts_started = false
        end
        vim.api.nvim_win_hide(win)
    end,
    ["cmdline_pos"] = function(pos, _)
        if pos == old_pos then
            return
        end
        old_pos = pos
        gpos = pos
        cusor_mark = vim.api.nvim_buf_set_extmark(cmdbuf, cmdline_ns, 0, pos, {
            id = cusor_mark,
            end_col = pos + 1,
            hl_group = "Cursor",
        })
        if gtype == '/' or gtype == '?' then
            return
        end
        vim.api.nvim_input('<home> <Plug>r')
    end,
    ["cmdline_show"] = function(content, pos, type, prompt, _, _)
        call_c = call_c + 1
        local data = ""
        for i = 1, #content, 1 do
            data = data .. content[i][2]
        end
        if call_c == 1 then
            open()
        end
        if call_c >= 3 then
            -- we got called again from a redraw
            if (old_data == data) then
                return
            end
        end
        old_data = data
        gdata = data
        gpos = pos
        gtype = type

        if prompt == "" then
            id = vim.fn.sign_place(id, "", type_sign[type] or "CmdLine", cmdbuf, { lnum = 1 })
            vim.wo[win].scl = "yes"
        else
            vim.wo[win].scl = "no"
        end

        -- the space is for the cursor mark
        vim.api.nvim_buf_set_lines(cmdbuf, 0, -1, false, { data .. ' ' })
        cusor_mark = vim.api.nvim_buf_set_extmark(cmdbuf, cmdline_ns, 0, pos, {
            id = cusor_mark,
            end_col = pos + 1,
            hl_group = "Cursor",
        })

        if not ts_started then
            if type == ":" or type == "=" then
                vim.treesitter.start(cmdbuf, 'vim')
                ts_started = true
            end
        end

        -- the first redraw renders the window and triggers cmdline_show again
        -- then we need another redraw to render the icon
        -- then finally we get an extra call from the icon redraw
        if call_c >= 3 then
            if (type == '/' or type == '?') then
                vim.schedule(function()
                    vim.api.nvim_input(' <bs>')
                end)
                return
            end
        end
        vim.api.nvim_input('<home> <Plug>r')
    end,
}

vim.api.nvim_set_decoration_provider(cmdline_ns, {
    on_win = function(_, winid)
        if winid == win then
            vim.api.nvim_win_set_config(win, {
                relative = M.relative(gtype, gdata, prompt),
                row = M.row(gtype, gdata, prompt),
                col = M.col(gtype, gdata, prompt),
                width = M.width(gtype, gdata, prompt),
                height = M.height(gtype, gdata, prompt),
                border = "rounded",
                title = M.title(gtype, gdata, prompt),
                title_pos = M.title_pos(gtype, gdata, prompt),
                zindex = 1000,
            })
        end
        return false
    end
})

vim.ui_attach(cmdline_ns, { ext_cmdline = true, },
    function(name, ...)
        handler[name](...)
    end
)

return M
