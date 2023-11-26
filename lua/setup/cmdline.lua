-- i was trying to learn the ui to fix an issue in noice
-- the issue ended up being me having an older noevim version
-- but honestly tho i really like using this over noice.
-- TODO: fix the search icon at the top right flicker
local cmdbuf = vim.api.nvim_create_buf(false, true)
local emptybuf = vim.api.nvim_create_buf(false, true)
vim.bo[cmdbuf].buftype = 'nowrite'
vim.bo[emptybuf].buftype = 'nowrite'
local win = 0
local cusor_mark = nil
vim.o.wildmode = ""

local title_map = {
   [":"] = "Cmdline",
   ["?"] = "Search ",
   ["/"] = "Search ",
   ["="] = "Calculator",
}

local type_sign = {
   [":"] = "Cmdline",
   ["/"] = "Search",
   ["?"] = "Search",
   ["="] = "Calculator",
}

local title = function(type, _, prompt)
   if (gtype == '/' or gtype == '?') and gdata == '' then
      return
   end
   if prompt ~= "" then
      return prompt:match('(.*):%s*$') or prompt
   end
   return title_map[type] or type
end

local border = function(_, _, _)
   if not ((gtype == '/' or gtype == '?') and gdata == '') then
      return "rounded"
   end
end



local row = function(_, _, _)
   return -3
end
local col = function(type, content, _)
   local col = -3
   if type == '/' or type == '?' then
      col = - #content - 3
   end
   return col
end

local width = function(type, content, prompt)
   local title = title(type, content, prompt)
   if title and #title > 25 then
      return #title + 8
   end
   if #content < 25 then
      return 30
   end
   -- ceil(content / 10)
   return (#content / 8 + 1) * 8
end

local relative = function(_, _, _)
   return 'Cursor'
end

local height = function(_, _, _) return 1 end



local title_pos = function(type, content, prompt)
   local title = title(type, content, prompt)
   if not title then
      return
   end
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
       vim.api.nvim_open_win(emptybuf, false, {
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
   vim.wo[win].winblend = 100
end

open()
vim.api.nvim_create_autocmd("TabEnter", {
   pattern = "*",
   callback = function()
      if vim.api.nvim_win_is_valid(win) then
         vim.api.nvim_win_hide(win)
      end
      open()
   end
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
   pattern = "*",
   callback = function()
      if vim.api.nvim_get_current_win() == win then
         vim.cmd('normal! ' .. esc('<C-w><C-w>'))
         return
      end
   end
})


vim.fn.sign_define('Cmdline', { text = " ", texthl = "FloatBorder" })
vim.fn.sign_define('Search', { text = " ", texthl = "FloatBorder" })
vim.fn.sign_define('Calculator', { text = " ", texthl = "FloatBorder" })
local ts_started = false
local old_data = ""
local old_pos = 0
local cmdline_ns = vim.api.nvim_create_namespace('cmdline')

vim.api.nvim_set_hl(0, 'HIDDEN', { blend = 100, nocombine = true })

local call_c = 0
local data = "             "
local gpos = 0
local handler = {
   ["cmdline_hide"] = function()
      call_c = 0
      local old_ei = vim.o.ei
      vim.o.ei = 'all'
      vim.api.nvim_win_set_buf(win, emptybuf)
      vim.api.nvim_win_set_config(win, {
         relative = 'editor',
         row = 1,
         col = 1,
         width = 1,
         height = 1,
         border = 'none',
         title = '',
         zindex = 1,
      })
      vim.go.guicursor = "a:block"
      vim.wo[win].winblend = 100

      if ts_started then
         vim.treesitter.stop(cmdbuf)
         ts_started = false
      end
      vim.o.ei = old_ei
      vim.schedule(function()
         vim.cmd.redraw()
      end)
   end,
   -- only useful for forward movement outside of cmd preview
   ["cmdline_pos"] = function(pos, _)
      if pos == mov_old_pos then
         return
      end
      mov_old_pos = pos
      gpos = pos
      vim.api.nvim_input(' <bs>')
      vim.schedule(function()
         vim.cmd([[ redraw ]])
      end)
   end,
   -- self note runs before on_win
   ["cmdline_show"] = function(content, pos, type, prompt, _, _)
      call_c = call_c + 1
      if not ((type == '/' or type == '?') and data == '') then
         -- HACK: taken from noice
         -- hide the cursor
         vim.go.guicursor = "a:HIDDEN"
         vim.wo[win].winblend = 0
      end

      -- parse the argument
      data = ""
      for i = 1, #content, 1 do
         data = data .. content[i][2]
      end
      -- store info for rendering
      gpos = pos
      gdata = data
      gtype = type
      gprompt = prompt
      local old_ei = vim.o.eventignore
      vim.o.ei = 'all'
      -- the space is for the cursor mark
      vim.api.nvim_buf_set_lines(cmdbuf, 0, -1, false, { data .. ' ' })

      if not ts_started then
         if type == ":" or type == "=" then
            vim.treesitter.start(cmdbuf, 'vim')
            ts_started = true
         end
      end

      vim.o.ei = old_ei
      -- the first redraw renders the window and triggers cmdline_show again
      -- then we need another redraw to render the icon
      -- then finally we get an extra call from the icon redraw
      if call_c == 2 then
         vim.api.nvim_win_set_buf(win, cmdbuf)
      end
      if call_c > 2 then
         if type ~= '/' and type ~= '?' then
            -- moves get sent here instead of cmdline_pos
            if pos ~= old_pos then
               vim.api.nvim_input(' <bs>')
               old_pos = pos
               vim.schedule(function()
                  vim.cmd([[ redraw ]])
               end)
            else
               return
            end
         end
         if (old_data == data) then
            return
         end
         log(data)
         if type ~= '/' and type ~= '?' then
            vim.api.nvim_input(' <bs>')
         end
         old_pos = pos
         old_data = data
      end
      vim.schedule(function()
         vim.cmd([[ redraw ]])
      end)
   end,
}

vim.api.nvim_set_decoration_provider(cmdline_ns, {
   on_win = function(_, rwin)
      if rwin == win then
         if vim.fn.getcmdtype() == "" then
            return false
         end
         if not ((gtype == '/' or gtype == '?') and data == '') then
            cusor_mark = vim.api.nvim_buf_set_extmark(cmdbuf, cmdline_ns, 0, gpos, {
               id = cusor_mark,
               end_col = gpos + 1,
               hl_group = "Cursor",
            })
            vim.api.nvim_win_set_config(win, {
               relative = relative(gtype, gdata, gprompt),
               row = row(gtype, gdata, gprompt),
               col = col(gtype, gdata, gprompt),
               width = width(gtype, gdata, gprompt),
               height = height(gtype, gdata, gprompt),
               border = border(gtype, gdata, gprompt),
               title = title(gtype, gdata, gprompt),
               title_pos = title_pos(gtype, gdata, gprompt),
               zindex = 1000,
            })
            if gprompt == "" then
               vim.fn.sign_place(0, "", type_sign[gtype] or "Cmdline", cmdbuf, { lnum = 1 })
               vim.wo[win].scl = "yes"
            else
               vim.wo[win].scl = "no"
            end
         end
         -- the window needs 2 redraws for a border bug
         -- somehow this doesn't trigger and infinite loop of redraws
         -- probably becuase there are no events for command window after the redraw
         -- i think i got lucky with cmdline_show updating the window by writing to the buffer
         if gtype ~= '/' and gtype ~= '?' then
            vim.api.nvim_input(' <bs>')
         else
            -- search really hates the <space><bs> hack
            vim.schedule(function()
               vim.cmd([[ redraw ]])
            end)
         end
      end
      return false
   end
})

vim.ui_attach(cmdline_ns, { ext_cmdline = true, },
   function(name, ...)
      if handler[name] then
         handler[name](...)
      end
   end
)
