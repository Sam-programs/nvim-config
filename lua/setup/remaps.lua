vim.g.mapleader = " "

local map = vim.keymap.set
--keymap('t', '<Esc>', '<C-\\><C-n>')
map('t', '<C-w>', '<C-\\><C-n><C-w>')
map('t', '<C-k>', '<C-\\><C-n>k')


map({'n','v'},'<leader>cn','<cmd>cn<cr>')
map({'n','v'},'<leader>cp','<cmd>cp<cr>')

--very shmooth line movement
map("v", "J", function()
    local selend = vim.fn.getpos('.')[2]
    local selbegin = vim.fn.getpos('v')[2]
    local buflen = vim.api.nvim_buf_line_count(0)
    if selbegin == buflen or selend == buflen then
        return ''
    end
    local old_lz = vim.o.lz
    vim.o.lz = true;
    return "<ESC><CMD>'<,'>m '>+1<CR>gv=gv<cmd>lua vim.o.lz =  " ..
        (old_lz and "true" or "false") .. "<cr>"
end, { expr = true })

map("v", "K", function()
    local selbegin = vim.fn.getpos("v")[2]
    local selend = vim.fn.getpos(".")[2]
    if selbegin == 1 or selend == 1 then
        return ''
    end
    local old_lz = vim.o.lz
    vim.o.lz = true;
    return "<ESC><CMD>'<,'>m '<-2<CR>gv=gv<cmd>lua vim.o.lz =  " ..
        (old_lz and "true" or "false") .. "<cr>"
end, { expr = true })

map("n", "K", "vK<esc>", { remap = true })
map("n", "J", "vJ<esc>", { remap = true })
map("n", "<c-d>", "<cmd>set lz<cr><c-d>zz<cmd>set nolz<cr>")
map("n", "<c-u>", "<cmd>set lz<cr><c-u>zz<cmd>set nolz<cr>")

-- shift k by default goes to help/man page
map({ "n", "v" }, "M", "K")

--lsp/writing

---@diagnostic disable-next-line: deprecated
local function format()
    vim.lsp.buf.format({
        async = true
    })
end

local function write(arg, should_format)
    local bufname = vim.api.nvim_buf_get_name(0)
    if (arg) then
        bufname = #arg.fargs ~= 0 and arg.args or bufname
    else
        arg = {}
    end
    if (bufname ~= "") then
        print("\"" ..
            bufname .. "\" " .. vim.api.nvim_buf_line_count(0) .. "L, " .. vim.fn.getfsize(bufname) .. 'B written')
        -- schedule so that the write becomes async and doesn't freeze the editor
        vim.schedule(function()
            local bang = arg.bang and "!" or ""
            local errmsg = vim.v.errmsg
            if (should_format) then
                vim.v.errmsg = ''
                vim.cmd("silent! lua vim.lsp.buf.format() ")
                if (vim.v.errmsg ~= '') then
                    vim.notify(vim.v.errmsg, vim.log.levels.ERROR, {})
                    return
                end
            end
            vim.v.errmsg = ''
            vim.cmd("silent! w" .. bang .. " " .. (arg.args or ''))
            if (vim.v.errmsg ~= '') then
                vim.notify(vim.v.errmsg, vim.log.levels.ERROR, {})
                return
            end
            vim.v.errmsg = errmsg
            require('lualine').refresh()
        end)
    end
end
vim.api.nvim_create_user_command('W', write, { nargs = "*", bang = true, complete = 'file' })
vim.api.nvim_create_user_command('Wq', "wq", { nargs = "*", bang = true, complete = 'file' })
vim.api.nvim_create_user_command('Wa', 'wa', { nargs = "*", bang = true, complete = 'file' })
vim.api.nvim_create_user_command('Wqa', 'wqa!', { nargs = "*", bang = true, complete = 'file' })
vim.api.nvim_create_user_command('OldWrite', function() vim.cmd.w() end, {})

map("n", "<leader>w", function() write({ fargs = {} }, true) end)
map("n", "<leader>f", format)
map("n", "<C-w>f", ":!zsh<cr>", { remap = true })
map("n", "<C-w><C-f>", ":!zsh<cr>", { remap = true })

map("n", "<leader>q", function()
    write()
    vim.cmd('qa!')
end)

-- save to the system clipboard
map("n", "y", "\"+y")
map("v", "y", "\"+y")

-- "paste"
map("n", "p", "\"+gP")

map({ "n", "t", "i" }, "<A-S>", "<C-\\><C-n>2gt")
map({ "n", "t", "i" }, "<A-A>", "<C-\\><C-n>1gt")
map({ "n", "t", "i" }, "<A-D>", "<C-\\><C-n>3gt")
map({ "n", "t", "i" }, "<A-F>", "<C-\\><C-n>4gt")
map({ "n", "t", "i" }, "<A-G>", "<C-\\><C-n>5gt")
map({ "n", "t", "i" }, "<A-H>", "<C-\\><C-n>6gt")
map({ "n", "t", "i" }, "<A-J>", "<C-\\><C-n>7gt")
map({ "n", "t", "i" }, "<A-K>", "<C-\\><C-n>8gt")
map({ "n", "t", "i" }, "<A-L>", "<C-\\><C-n>9gt")

map({ "n", "t", "i" }, "<A-t>", "<C-\\><C-n>:tabe ", { remap = true })

map("n", "<A-space>", function()
    local cwd = vim.fn.getcwd()
    local file = vim.fn.expand("~/.config/nvim/sessions/") .. cwd:gsub('/', '\\%%');
    vim.cmd('mksession! ' .. file)
    vim.notify('Session Saved', vim.log.levels.INFO)
end)
map("n", "<C-space>", function()
    local cwd = vim.fn.getcwd()
    local file = vim.fn.expand("~/.config/nvim/sessions/") .. cwd:gsub('/', '\\%%');
    vim.cmd('source ' .. file)
    vim.notify('Session Loaded', vim.log.levels.INFO)
    -- exit insert mode
    vim.api.nvim_input('<esc>')
end)

-- got this idea from fuadsaud on github
map({ "o", "n", "v" }, "L", "$")
map({ "o", "n", "v" }, "H", "0")

map({ "o", "n", "v" }, "$", "")
map({ "o", "n", "v" }, "0", "")

--insert/command mode mappings
map({ "c" }, "<A-j>", "<down>")
map({ "i", "c" }, "<A-k>", "<up>")
map({ "i", "c" }, "<A-l>", "<right>", { remap = true })
map({ "i", "c" }, "<A-h>", "<left>")

map("i", "<A-s>", "<cmd>AddSemi<cr><down><end><left>") -- go onto statement's pair
map("i", "<C-j>", "<cmd>AddSemi<cr><down><end><cr>")   -- jump out of pair and add semicolon

local function esc(str)
    return vim.api.nvim_replace_termcodes(str, true, false, true)
end


if DEBUG_BUFER == nil then
    DEBUG_BUFER = -1
end

---@diagnostic disable-next-line: lowercase-global
function clear()
    if DEBUG_BUFER == -1 then
        return
    end
    vim.api.nvim_buf_set_lines(DEBUG_BUFER, 0, -1, false, {})
end

---@diagnostic disable-next-line: lowercase-global
log = vim.schedule_wrap(function(...)
    local vargs = { ... }
    vargs = vim.deepcopy(vargs)
    if vim.in_fast_event() then
        vim.schedule(function()
            log(vargs)
        end)
        return
    end
    if DEBUG_BUFER == -1 then
        vim.cmd('normal! ' .. esc('<C-w><C-v><C-w><C-l>'))
        DEBUG_BUFER = vim.api.nvim_create_buf(true,false)
        vim.api.nvim_set_current_buf(DEBUG_BUFER)
        vim.treesitter.start(0, 'lua')
        vim.bo[0].buftype = "nofile"
        vim.cmd('normal! ' .. esc('<C-w><C-h>'))
    end
    for _, data in pairs(vargs) do
        if data == nil then
            data = '<nil>'
        end
        if data == '' then
            data = '"<empty>"'
        else
            data = vim.inspect(data)
        end
        data = vim.split(data, '\n')
        vim.api.nvim_buf_set_lines(DEBUG_BUFER, -2, -2, false, data)
    end
    vim.api.nvim_buf_set_lines(DEBUG_BUFER, -2, -2, false, { " " })
end)

local diagnosticsOn = false
map('i', '<C-d>', function()
    diagnosticsOn = not diagnosticsOn
    vim.diagnostic.config({
        update_in_insert = diagnosticsOn,
    })
end)

map({ 'i', 'n', 't', 'c' }, "<A-Enter>", "<Enter>", { remap = true })

map('n', ";", ":",{remap = true})
map({ 't' }, "<A-l>", "<right>")
map({ 't' }, '<A-h>', '<left>')
map({ 'n', 'v' }, ',', '@')

map('i', '<C-u>', '<cmd>undo<cr>')

local k = vim.keycode

-- backwards can be nil to follow depth's direction
-- negative depth true
-- positive depth false
local search = function(depth, pattern, backwards, on_match)
    local curline = vim.api.nvim_win_get_cursor(0)[1]
    local buflen = vim.api.nvim_buf_line_count(0)
    if (curline + depth < 0) then
        depth = -curline
    end
    if (curline + depth > buflen) then
        depth = curline - buflen
    end
    local lines
    if (depth < 0) then
        lines = vim.api.nvim_buf_get_lines(0, curline + depth, curline + 1, false)
    else
        lines = vim.api.nvim_buf_get_lines(0, curline, curline + depth + 1, false)
    end
    local start, end_, inc
    if (backwards == nil) then
        backwards = depth < 0
    end
    if (backwards) then
        start = math.abs(depth);
        end_ = 1;
        inc = -1;
    else
        start = 1;
        end_ = math.abs(depth);
        inc = 1;
    end
    for i = start, end_, inc do
        local line = lines[i]
        local match = line:match(pattern)
        if (match) then
            vim.print(start - i)
            if (on_match(match) == false) then
                return
            end
        end
    end
end

map('n', 'za', "zfa{")
map('n', 'zi', "za")
map('v', 'za', "zf")


-- vulkan sType
map('i', '<C-k>', function()
    local result
    search(-5, "Vk(%a*)", nil, function(match)
        match = match:gsub("%l+%u", function(str)
            return str:sub(1, #str - 1) .. "_" .. str:sub(#str, #str)
        end)
        match = match:upper()
        match = ".sType = VK_STRUCTURE_TYPE_" .. match .. "," .. k "<cr>"
        result = match
        return false
    end)
    if (result) then
        return result
    end
    -- we might be in an array
    search(-100, "^%s*(.sType = VK_STRUCTURE_TYPE_.*)", nil, function(match)
        result = match .. k "<cr>"
        return false
    end)
    return result
end, { expr = true })

-- pointersss
map({ 'i', 't' }, '-', function()
    if (vim.o.ft ~= 'c' and vim.o.buftype ~= 'terminal') then
        return "-"
    end
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)[2]
    line = line:sub(1, cursor)
    if line:match("%s*%w+$") then
        return "->"
    end
    if line:match("[a-z1-9[]]+->[a-z1-9[]]+$") then
        return "->"
    end
    return "-"
end, { expr = true })


map('i', ';', function()
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)[2]
    line = line:sub(1, cursor)
    if line:match("->$") then
        return "<bs>-;"
    end
    return ";"
end, { expr = true })


map('v', 'R', function()
    return "<cmd>'<,>'s/" .. vim.fn.getcharstr() .. "/" .. vim.fn.getcharstr() .. "/g<cr>"
end, { expr = true })

map('i', '<C-e>', '—')
