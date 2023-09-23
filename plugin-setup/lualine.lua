--disable the startup screen since lua line clears it anway
vim.opt.shortmess = 'filnxtToOFI'
local lualine = require 'lualine'

local diffcolors = {
   added = { fg = '#9ece6a' },
   modified = { fg = '#e0af68' },
   removed = { fg = '#f7768e' },
}

local config = {
   lualine_a = {
      'mode', },
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
      padding = 0,            -- For the icon
      file_status = true,     -- Displays file status (readonly status, modified status)
      newfile_status = false, -- Display new file status (new file means no write after created)
      path = 0,               -- 0: Just the filename
      -- 1: Relative path
      -- 2: Absolute path
      -- 3: Absolute path, with tilde as the home directory
      -- 4: Filename and parent dir, with tilde as the home directory

      shorting_target = 40, -- Shortens path to leave 40 spaces in the window
      -- for other components. (terrible name, any suggestions?)
      symbols = {
         -- the space here is because sometimes i modify readonly and the icons get mixed
         modified = ' ', -- Text to show when the file is modified.
         readonly = '', -- Text to show when the file is non-modifiable or readonly.
         unnamed = '', -- Text to show for unnamed buffers.
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
      diff_color = diffcolors,
      symbols = { added = '+', modified = '󰦒', removed = '-' }, -- Changes the symbols used by the diff.
   } },
   lualine_y = { 'location' },
   lualine_z = { { 'datetime', style = '  %H:%M' } }
}

lualine.setup {
   options = {
      icons_enabled = true,
      theme = 'tokyonight',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
         statusline = {},
         winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = false,
      globalstatus = false,
      refresh = {
         statusline = 30000,
         tabline = 30000,
         winbar = 30000,
      }
   },
   sections = vim.deepcopy(config)
   ,
   inactive_sections = vim.deepcopy(config)
   ,
   tabline = {
      lualine_a = {
         {
            'tabs',
            max_length = vim.o.columns, -- Maximum width of tabs component.
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
   winbar = {},
   inactive_winbar = {},
   extensions = {}
}
