return { {
    'Sam-programs/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, --optional
    priority = 999,
    event = 'VimEnter',
    config = function()
        --disable the startup screen since lua line clears it anyway
        vim.cmd("set shortmess+=I")
        local lualine = require('lualine')
        local colors = {}
        local theme = require('lualine.themes.' .. vim.g.colors_name)
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
        local k = vim.keycode
        local normalize_key = {}
        local char2nr = vim.fn.char2nr
        local nr2char = vim.fn.nr2char
        -- keytrans sucks
        for i = char2nr('A'), char2nr('Z'), 1 do
            local char = nr2char(i)
            local index = k('<C-' .. char .. '>')
            normalize_key[index] = '^' .. char
        end
        normalize_key[k '<cr>'] = '󰌑 '
        normalize_key[k '<bs>'] = '⌫'
        normalize_key[k '<Del>'] = '󰆴'
        normalize_key[k '<esc>'] = '󱊷 '
        normalize_key[k '<Up>'] = ''
        normalize_key[k '<Down>'] = ''
        normalize_key[k '<Left>'] = ''
        normalize_key[k '<Right>'] = ''
        normalize_key[' '] = '󱁐'
        for i = 1, 4, 1 do
            normalize_key[k("<" .. i.. "-LeftMouse>")] = '󰍽'
            -- <A-LeftMouse> doesn't exist?
            normalize_key[k("<" .. i.. "-C-LeftMouse>")] = '󰍽'
            normalize_key[k("<" .. i.. "-S-LeftMouse>")] = '󰍽'

            normalize_key[k("<" .. i.. "-MiddleMouse>")] = '󰍽'

            normalize_key[k("<" .. i.. "-RightMouse>")] = '󰍽'
            normalize_key[k("<" .. i.. "-A-RightMouse>")] = '󰍽'
            normalize_key[k("<" .. i.. "-S-RightMouse>")] = '󰍽'
            normalize_key[k("<" .. i.. "-C-RightMouse>")] = '󰍽'

            normalize_key[k("<" .. i.. "-LeftDrag>")] = '󱕒'
            normalize_key[k("<" .. i.. "-RightDrag>")] = '󱕒'

            normalize_key[k("<" .. i.. "-LeftRelease>")] = ''
            normalize_key[k("<" .. i.. "-RightRelease>")] = ''
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


        -- q gets an extra space to separate macros
        normalize_key['q'] = 'q'

        normalize_key[k '<end>'] = ''
        local term_prefix = k '<Cmd>'
        term_prefix = term_prefix:sub(1, #term_prefix - 1)
        -- <C-d>
        normalize_key[term_prefix .. 'g'] = '^D'
        -- KE_NOP
        normalize_key[term_prefix .. 'a'] = ''
        normalize_key[k '<Cmd>'] = ''

        local show_key_limit = 25
        local in_macro = false
        vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
            pattern = "*",
            callback = function()
                in_macro = vim.fn.reg_recording()
            end
        })
        local stl_pressed_array = {}
        local pressed_array = {}
        vim.on_key(function(key)
            if key == 'q' then
                if (not in_macro) then
                    key = ' q'
                else
                    key = 'q '
                end
            end
            key = normalize_key[key] or key
            if key:sub(1,#key - 1):find('�') then
                vim.notify('UNHANDLED key sequence:' .. key .. ' trans:"' .. vim.fn.keytrans(key) .. '"',vim.log.levels.WARN,{})
                return
            end
            local curwin = vim.api.nvim_get_current_win()
            if (pressed_array[curwin]) then
                pressed_array[curwin] = pressed_array[curwin] .. key
            else
                pressed_array[curwin] = (' '):rep(show_key_limit - vim.fn.strcharlen(key)) .. key
            end
            local len = vim.fn.strcharlen(pressed_array[curwin])
            local diff = len - show_key_limit
            if diff > 0 then
                -- remove the first char
                pressed_array[curwin] = vim.fn.strcharpart(pressed_array[curwin], diff, len - diff)
            end
            stl_pressed_array[curwin] = pressed_array[curwin]:gsub('%%', '%%%%')
            -- a lot of stuff are unsafe in on_key so schedule
            vim.schedule(function()
                require('lualine').refresh()
                -- needed in cmdline
                vim.cmd.redraws()
            end)
        end)
        function get_pressed()
            return pressed_array[vim.api.nvim_get_current_win()]
        end

        function get_stl_pressed()
            return stl_pressed_array[vim.api.nvim_get_current_win()] or (" "):rep(show_key_limit)
        end

        function get_pos()
            local r, c = unpack(vim.api.nvim_win_get_cursor(0))
            return string.format("%d,%d", r, c)
        end

        -- i tried to standardize mode lengths as much as possible
        local mode_table = {
            ["n"]   = "NORMAL",
            ["no"]  = "O-Pend",
            ["nov"] = "C-Pend",
            ["noV"] = "L-Pend",
            ["no"] = "B-Pend",

            ["i"]   = "INSERT",
            ["ic"]  = "INSERT",
            ["ix"]  = "INSERT",
            ["niI"] = "INSERT",

            ["v"]   = "VISUAL",
            ["vs"]  = "VISUAL",
            ["niV"] = "VISUAL",

            [""]   = "VBLOCK",
            ["s"]  = "VBLOCK",

            ["V"]   = "V-LINE",
            ["Vs"]  = "V-LINE",

            -- no real good way to shrink this
            ["R"]   = "REPLACE",
            ["Rc"]  = "REPLACE",
            ["Rx"]  = "REPLACE",
            ["Rv"]  = "REPLACE",
            ["Rvc"] = "REPLACE",
            ["Rvx"] = "REPLACE",
            ["niR"] = "REPLACE",

            ["c"]   = "NORMAL",
            ["cr"]  = "NORMAL",
            ["cv"]  = "ExMode",
            ["cvr"] = "ExMode",
            ["r"]   = "NORMAL",
            ["rm"]  = "NORMAL",
            ["!"]   = "NORMAL",
            ["r?"]  = "NORMAL",

            ["t"]   = "TERM",
            ["nt"]  = "MOVE",
            ["ntT"] = "TERM",
        }

        -- while i was looking for a good indentation character for listchars
        -- i got distracted with these cute icons
        -- use a nerd font for these
        local mode_icons = {
            '', '', '', '', '',
            '', '', '', '󰅩', '',
            '', '󱡁', '󰵉', '',
            '', '', '󰝴', '', '󰮭', '', '󰩄', '󰞫',
            '', '󱥐', '', '', '', '', '󰋸', '',
            '󰔉', '', '',
        }
        math.randomseed(os.time())
        local mode_icon = mode_icons[math.random(#mode_icons)] .. ' '

        local last_mode = "NORMAL"
        function get_mode()
            local mode = vim.api.nvim_get_mode().mode
            mode = mode_icon .. mode_table[mode]
            -- if we are in a mapping don't react to mode changes
            if vim.fn.getchar(1) ~= 0 then
                return last_mode
            end
            last_mode = mode
            return mode
        end

        -- https://github.com/nvim-lualine/lualine.nvim/issues/1168#issuecomment-1868987586
        vim.api.nvim_create_autocmd({ "TabNewEntered" }, {
            pattern = "*",
            callback = function()
                require('lualine').refresh()
            end,
        })

        vim.api.nvim_create_autocmd({ "WinEnter" }, {
            pattern = "*",
            callback = function()
                math.randomseed(os.time())
                mode_icon = mode_icons[math.random(#mode_icons)] .. ' '
            end,
        })
        local config = {
            lualine_a = {
                'mode',
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
            }
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
                    'diff',
                    colored = true, -- Displays a colored diff status if set to true
                    diff_color = {
                        added = { fg = colors.green },
                        modifed = { fg = colors.yellow },
                        removed = { fg = colors.red },
                    },
                    symbols = { added = '+', modified = '󰦒', removed = '-' }, -- Changes the symbols used by the diff.
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
            sections = vim.deepcopy(config)
            ,
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
    end,
} }
