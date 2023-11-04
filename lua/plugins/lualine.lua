return {{
   'nvim-lualine/lualine.nvim',
   dependencies = { 'nvim-tree/nvim-web-devicons' }, --optional
   event = 'VimEnter',
   config = function()
      --disable the startup screen since lua line clears it anyway
      vim.cmd("set shortmess+=I")
      local lualine = require('lualine')
      local colors = {}
      show_time = true
      local function get_time()
         if show_time then
            return os.date("  %H:%M")
         end
         return '  ??:??'
      end

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

      vim.api.nvim_create_autocmd({ "WinEnter" }, {
         pattern = "*",
         callback = function()
            math.randomseed(os.time())
            mode_icon = mode_icons[math.random(#mode_icons)] .. ' '
         end,
         once = false,
      })

      local config = {
         lualine_a = {
            { 'mode', fmt = function(str) return mode_icon .. str end }
         },
         lualine_b = { { 'branch', icon = '' } },
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
            path = 0,              -- 0: Just the filename
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
         },
         },
         lualine_x = { {
            'diff',
            colored = true, -- Displays a colored diff status if set to true
            diff_color = {
               added = { fg = colors.green },
               modifed = { fg = colors.yellow },
               removed = { fg = colors.red },
            },
            symbols = { added = '+', modified = '󰦒', removed = '-' }, -- Changes the symbols used by the diff.
         } },
         lualine_y = { 'location' },
         lualine_z = { { get_time } }
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
}}