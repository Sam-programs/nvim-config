return { {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, --optional
    lazy = false,
    config = function()
        --disable the startup screen since lua line clears it anyway
        vim.o.shm = (vim.o.shm or '') .. 'I'
        local lualine = require('lualine')
        local theme = require('lualine.themes.' .. (vim.g.colors_name or "gruvbox"))
        theme.inactive = theme.normal
        if eopts.lualine_no_mode_colors then
            theme = {
                normal = theme.normal,
                insert = theme.normal,
                visual = theme.normal,
                replace = theme.normal,
                command = theme.normal,
                terminal = theme.normal,
                inactive = theme.inactive,
            }
        end
        -- vim.keycode at home
        local k = function(key)
            return vim.api.nvim_replace_termcodes(key, false, false, true)
        end
        -- i just keep adding keys to this when i find them
        local normalize_key = {}
        local char2nr = vim.fn.char2nr
        local nr2char = vim.fn.nr2char
        -- keytrans sucks
        for i = char2nr('A'), char2nr('Z'), 1 do
            local char = nr2char(i)
            local index = k('<C-' .. char .. '>')
            normalize_key[index] = '⌃' .. char
        end
        normalize_key[k '<cr>'] = '󰌑'
        normalize_key[k '<bs>'] = '⌫'
        normalize_key[k '<Del>'] = '󰆴'
        normalize_key[k '<esc>'] = '󱊷'
        normalize_key[k '<Up>'] = ''
        normalize_key[k '<Down>'] = ''
        normalize_key[k '<Left>'] = ''
        normalize_key[k '<Right>'] = ''
        normalize_key[' '] = '󱁐'
        normalize_key[k '<S-Space>'] = '⇧󱁐'

        for i = 1, 4, 1 do
            normalize_key[k("<" .. i .. "-LeftMouse>")] = '󰍽'
            -- <A-LeftMouse> doesn't exist?
            normalize_key[k("<" .. i .. "-C-LeftMouse>")] = '󰍽'
            normalize_key[k("<" .. i .. "-S-LeftMouse>")] = '󰍽'

            normalize_key[k("<" .. i .. "-MiddleMouse>")] = '󰍽'

            normalize_key[k("<" .. i .. "-RightMouse>")] = '󰍽'
            normalize_key[k("<" .. i .. "-A-RightMouse>")] = '󰍽'
            normalize_key[k("<" .. i .. "-S-RightMouse>")] = '󰍽'
            normalize_key[k("<" .. i .. "-C-RightMouse>")] = '󰍽'

            normalize_key[k("<" .. i .. "-LeftDrag>")] = '󱕒'
            normalize_key[k("<" .. i .. "-RightDrag>")] = '󱕒'

            normalize_key[k("<" .. i .. "-LeftRelease>")] = ''
            normalize_key[k("<" .. i .. "-RightRelease>")] = ''
        end

        normalize_key[k("<LeftMouse>")] = '󰍽'
        normalize_key[k("<C-LeftMouse>")] = '󰍽'
        normalize_key[k("<S-LeftMouse>")] = '󰍽'
        normalize_key[k("<LeftDrag>")] = ''
        normalize_key[k("<LeftRelease>")] = ''
        normalize_key[k("<MiddleMouse>")] = '󰍽'
        normalize_key[k("<RightMouse>")] = '󰍽'
        normalize_key[k("<A-RightMouse>")] = '󰍽'
        normalize_key[k("<S-RightMouse>")] = '󰍽'
        normalize_key[k("<C-RightMouse>")] = '󰍽'
        normalize_key[k("<RightDrag>")] = ''
        normalize_key[k("<RightRelease>")] = ''

        normalize_key['q'] = 'q'

        local term_prefix = k '<Cmd>'
        term_prefix = term_prefix:sub(1, #term_prefix - 1)
        -- lua mapping key
        normalize_key[term_prefix .. 'g'] = ''
        -- KE_NOP
        normalize_key[term_prefix .. 'a'] = ''
        normalize_key[k '<Cmd>'] = ''
        normalize_key[k '<SNR>'] = ''
        -- records about 500 keys since each key gets an extra space most of the time
        local show_key_limit = 1000
        local pressed_array = {}
        local mt = {}
        setmetatable(pressed_array, mt)
        function mt.__index(_, index)
            if (rawget(pressed_array, index) == nil) then
                pressed_array[index] = (" "):rep(show_key_limit)
            end
            return rawget(pressed_array, index)
        end

        vim.o.showcmd = true
        vim.o.showcmdloc = 'tabline'
        -- showcmd at home
        local function showcmd()
            return vim.api.nvim_eval_statusline('%S', { use_tabline = true }).str
        end
        vim.on_key(function(key)
            key = normalize_key[key] or key
            if key:find(term_prefix:sub(1, 1)) then
                key = vim.fn.keytrans(key)
            end
            local mode = vim.api.nvim_get_mode().mode
            local cmd = showcmd()
            -- add  a special case for operators since the showcmd hack doesn't work well with them
            -- and add macros because i like them being grouped
            if mode:find("o") or vim.fn.reg_recording() ~= "" then
                cmd = "valid"
            end
            mode = mode:sub(1, 1)
            if cmd == "" and mode == "n" or mode == "v" then
                if key ~= "" then
                    key = " " .. key
                end
            end
            local curwin = vim.api.nvim_get_current_win()
            pressed_array[curwin] = pressed_array[curwin] .. key
            local len = vim.fn.strcharlen(pressed_array[curwin])
            local diff = len - show_key_limit
            if diff > 0 then
                -- remove the first char
                pressed_array[curwin] = vim.fn.strcharpart(pressed_array[curwin], diff, len - diff)
            end
            vim.schedule(function()
                require('lualine').refresh()
                -- needed in cmdline
                vim.cmd.redrawstatus()
            end)
        end)

        vim.api.nvim_create_autocmd('WinClosed', {
            pattern = "*",
            callback = function(opt)
                local win = tonumber(opt.match)
                if win == nil then
                    return
                end
                if (pressed_array[win]) then
                    pressed_array[win] = nil
                end
            end
        })
        function LsKeys()
            for win, keys in pairs(pressed_array) do
                if (vim.api.nvim_win_is_valid(win)) then
                    local buf = vim.api.nvim_win_get_buf(win)
                    vim.print((vim.fn.bufname(buf):match('[^/]*$') or '') .. ': ' .. keys:gsub('^%s*', ''))
                end
            end
        end

        vim.api.nvim_create_user_command('LsKeys', LsKeys, {})

        local last_chars = {}
        local last_ret = {}
        local function get_stl_pressed()
            local win = vim.api.nvim_get_current_win()
            local chars = pressed_array[win]
            -- don't recalculate the width if we didn't press a key
            if chars == last_chars[win] then
                return last_ret[win]
            end
            local stl_limit = math.floor(vim.api.nvim_win_get_width(win) * .27)
            last_chars[win] = chars
            local ret = vim.fn.strcharpart(chars, show_key_limit - stl_limit,
                show_key_limit)
            -- we might have cut an %%
            ret = ret:gsub('%%', '%%%%')
            last_ret[win] = ret
            return ret
        end

        local function get_pos()
            local r, c = unpack(vim.api.nvim_win_get_cursor(0))
            return string.format("%d,%d", r, c)
        end

        -- i tried to standardize mode lengths as much as possible
        local mode_table = {
            ["n"]               = "NORMAL",
            ["no"]              = "O-Pend",
            ["nov"]             = "C-Pend",
            ["noV"]             = "L-Pend",
            ["no" .. k '<C-v>'] = "B-Pend",

            ["i"]               = "INSERT",
            ["ic"]              = "INSERT",
            ["ix"]              = "INSERT",
            ["niI"]             = "INSERT",

            [k '<C-v>']         = "VBLOCK",
            ["v"]               = "VISUAL",
            ["vs"]              = "VISUAL",
            ["niV"]             = "VISUAL",

            [""]                = "VBLOCK",
            ["s"]               = "VBLOCK",

            ["V"]               = "V-LINE",
            ["Vs"]              = "V-LINE",

            -- no real good way to shrink this
            ["R"]               = "REPLACE",
            ["Rc"]              = "REPLACE",
            ["Rx"]              = "REPLACE",
            ["Rv"]              = "REPLACE",
            ["Rvc"]             = "REPLACE",
            ["Rvx"]             = "REPLACE",
            ["niR"]             = "REPLACE",

            ["c"]               = "NORMAL",
            ["cr"]              = "NORMAL",
            ["cv"]              = "ExMode",
            ["cvr"]             = "ExMode",
            ["r"]               = "NORMAL",
            ["rm"]              = "NORMAL",
            ["!"]               = "NORMAL",
            ["r?"]              = "NORMAL",

            ["t"]               = "TERM",
            ["nt"]              = "MOVE",
            ["ntT"]             = "TERM",
        }

        local last_mode = "NORMAL"
        vim.api.nvim_create_autocmd({ 'CmdlineChanged' }, {
            pattern = '*',
            callback = function()
                if last_mode ~= mode_table['c'] then
                    if vim.fn.getchar(1) == 0 then
                        last_mode = mode_table['c']
                        require('lualine').refresh()
                        vim.cmd([[ redraws ]])
                    end
                end
            end,
        })

        local function get_mode()
            local mode = vim.api.nvim_get_mode().mode
            mode = ' ' .. mode_table[mode]
            -- if we are in a mapping don't react to mode changes
            if vim.fn.getchar(1) ~= 0 then
                return last_mode
            end
            last_mode = mode
            return mode
        end

        --        vim.api.nvim_create_autocmd({ "WinEnter" }, {
        --            pattern = "*",
        --            callback = function()
        --                math.randomseed(os.time())
        --                mode_icon = mode_icons[math.random(#mode_icons)] .. ' '
        --            end,
        --        })
        local config = {
            lualine_a = {
                get_mode,
            },
            lualine_b = {
            },
            lualine_c = { {
                "filetype",
                colored = true,
                icon_only = true,
                padding = 1,
                fmt = function(str)
                    if str ~= '' then
                        return str
                    end
                    return 'netrw'
                end
            }, {
                'filename',
                padding = 0,           -- For the icon
                file_status = true,    -- Displays file status (readonly status, modified status)
                newfile_status = true, -- Display new file status (new file means no write after created)
                path = 4,              -- 0: Just the filename
                -- 1: Relative path
                -- 2: Absolute path
                -- 3: Absolute path, with tilde as the home directory
                -- 4: Filename and parent dir, with tilde as the home directory

                shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                -- for other components. (terrible name, any suggestions?)
                symbols = {
                    modified = ' ', -- Text to show when the file is modified.
                    readonly = '', -- Text to show when the file is non-modifiable or readonly.
                    unnamed = '[Name Me]', -- Text to show for unnamed buffers.
                    newfile = '', -- Text to show for newly created file before first write
                }
            }, {
                get_pos }
            , {
                "diagnostics",
                sources = { "nvim_lsp" },
                sections = { "error", "warn" },
                symbols = { error = " ", warn = " " },
                colored = true,
                update_in_insert = false
            }
            , {
            },
            },
            lualine_x = {
                {
                },
            },
            lualine_y = {
                { 'branch', icon = '' },
            },
            lualine_z = {
                {
                    get_stl_pressed,
                    fmt = function(str)
                        return '󰥻 ' .. str
                    end
                }
            },
        }

        lualine.setup {
            options = {
                icons_enabled = true,
                theme = theme,
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = false,
                globalstatus = false,
                -- only really useful for the clock
                refresh = {
                    statusline = 30000,
                    tabline = 30000,
                    winbar = 30000,
                },
            },
            sections = vim.deepcopy(config),
            inactive_sections = vim.deepcopy(config)
            ,
            tabline = {
                lualine_a = {
                    {
                        'tabs',
                        max_length = function() return vim.o.columns end, -- Maximum width of tabs component.
                        -- Note:
                        -- It can also be a function that returns
                        -- the value of `max_length` dynamically.
                        mode = 2, -- 0: Shows tab_nr
                        -- 1: Shows tab_name
                        -- 2: Shows tab_nr + tab_name

                        -- Automatically updates active tab color to match color of other components (will be overidden if buffers_color is set)
                        use_mode_colors = false,

                        fmt = function(name, context)
                            -- Show + if buffer is modified in tab
                            local buflist = vim.fn.tabpagebuflist(context.tabnr)
                            local winnr = vim.fn.tabpagewinnr(context.tabnr)
                            local bufnr = buflist[winnr]
                            local mod = vim.fn.getbufvar(bufnr, '&mod')

                            return name .. (mod == 1 and ' 󰦒' or '')
                        end
                    }
                },
            },
        }
        lualine.refresh()
    end,
} }
