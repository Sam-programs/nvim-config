-- TODO: simplify the redrawing logic
cmdbuf = vim.api.nvim_create_buf(false, true)
emptybuf = vim.api.nvim_create_buf(false, true)

vim.o.wildmode = ""

local row = function(_, _, _)
   return -3
end

local col = function(type, content, prompt)
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

local width = function(_, content, _)
   if #content < 25 then
      return 30
   end
   -- ceil(content / 10)
   return (#content / 8 + 1) * 8
end
local relative = function(_, _, _)
   return 'Cursor'
end

local height = function(_, _) return 1 end

local title_map = {
   [":"] = "CmdLine",
   ["?"] = "Search ",
   ["/"] = "Search ",
   ["="] = "Calculator",
}

local title = function(type, _, prompt)
   if prompt ~= "" then
      return prompt
   end
   return title_map[type]
end

local title_pos = function(_, _, prompt)
   if prompt ~= "" then
      return "center"
   end
   return "left"
end

local function esc(str)
   return vim.api.nvim_replace_termcodes(str, true, false, true)
end

function open()
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
      vim.api.nvim_win_hide(win)
      open()
   end
})

local t = ""
local d = ""
local p = ""

function update_pos()
   vim.api.nvim_win_set_config(win, {
      relative = relative(),
      row = row(t, d, p),
      col = col(t, d, p),
      width = width(t, d, p),
      height = height(t, d),
      title = title_pos(t, d, p),
      title_pos = title_pos(t, d, p),
      zindex = 1000,
   })
end

vim.api.nvim_create_autocmd({ "WinEnter" }, {
   pattern = "*",
   callback = function(ev)
      if vim.api.nvim_get_current_win() == win then
         vim.cmd('normal! ' .. esc('<C-w><C-w>'))
         return
      end
   end
})

local type_sign = {
   [":"] = "CmdLine",
   ["/"] = "Search",
   ["?"] = "Search",
   ["="] = "Calculator",
}

vim.fn.sign_define('CmdLine', { text = " ", texthl = "FloatBorder" })
vim.fn.sign_define('Search', { text = " ", texthl = "FloatBorder" })
vim.fn.sign_define('Calculator', { text = " ", texthl = "FloatBorder" })
local ts_started = false

local cmdlinens = vim.api.nvim_create_namespace('cmdline')
vim.api.nvim_set_hl(0, 'HIDDEN', { blend = 100, nocombine = true })
local call_c = 0
local handler = {
   ["cmdline_hide"] = function()
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
      vim.go.guicursor = "a:Cursor"
      vim.wo[win].winblend = 100
      vim.o.ei = old_ei

      call_c = 0
      r_call = 0
      if ts_started then
         vim.treesitter.stop(cmdbuf)
         ts_started = false
      end
   end,
   ["cmdline_pos"] = function(pos, level)
      if pos == old_pos then
         return
      end
      cid = vim.api.nvim_buf_set_extmark(cmdbuf, cmdlinens, 0, pos + #p, {
         id = cid,
         end_col = pos + #p + 1,
         hl_group = "Cursor",
      })
      old_pos = pos
      vim.schedule(function()
         vim.api.nvim_input(' <bs>')
      end)
   end,
   ["cmdline_show"] = function(content, pos, type, prompt, _, _)
      -- hack taken from noice
      vim.go.guicursor = "a:HIDDEN"
      vim.wo[win].winblend = 0
      call_c = call_c + 1
      local data = ""
      for i = 1, #content, 1 do
         data = data .. content[i][2]
      end

      if prompt == "" then
         vim.fn.sign_place(0, "", type_sign[type] or "CmdLine", cmdbuf, { lnum = 1 })
         vim.wo[win].scl = "yes"
      else
         vim.wo[win].scl = "no"
      end
      -- the space is for the cursor extmark
      vim.api.nvim_buf_set_lines(cmdbuf, 0, -1, false, { data .. ' ' })
      -- cursor extmark
      cid = vim.api.nvim_buf_set_extmark(cmdbuf, cmdlinens, 0, pos, {
         id = cid,
         end_col = pos + 1,
         hl_group = "Cursor",
      })
      if type ~= "" then
         if not ts_started then
            if type == ":" or type == "=" then
               vim.treesitter.start(cmdbuf, 'vim')
               ts_started = true
            end
         end
      end
      --- save info for update_pos
      t = type
      d = data
      p = prompt
      if call_c == 1 then
         vim.api.nvim_win_set_buf(win, cmdbuf)
      end
      -- the first redraw renders the window and triggers cmdline_show again
      -- then we need another redraw to render the icon
      -- then finally we get an extra call from the icon redraw
      if (type == '/' or type == '?') and call_c > 3 then
         return
      end

      vim.api.nvim_win_set_config(win, {
         relative = relative(),
         row = row(type, data, prompt),
         col = col(type, data, prompt),
         width = width(type, data, prompt),
         height = height(type, data),
         border = "rounded",
         title = title(type, data, prompt),
         title_pos = title_pos(type, data, prompt),
         zindex = 1000,
      })
      -- see the if statement above to why we need call_c less than 3
      if (old_data == data) and call_c > 3 then
         return
      end
      old_data = data
      vim.schedule(function()
         vim.cmd([[ redraw ]])
      end)
   end,
}

vim.ui_attach(cmdlinens,
   {
      ext_cmdline = true,
   },
   function(name, ...)
      log(name .. "")
      handler[name](...)
   end
)
