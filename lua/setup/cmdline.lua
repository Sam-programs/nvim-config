-- TODO: simplify the redrawing logic
cmdbuf = vim.api.nvim_create_buf(false, true)
emptybuf = vim.api.nvim_create_buf(false, true)


vim.o.wildmode = ""

local row = function(_, content, prompt)
   return -3
end

local last_col = 0
local col = function(type, content, prompt)
   local col = 0
   if type == '/' or type == '?' then
      col = - #content - 3
   else
      col = -3 - #prompt
   end
   return col
end

local width = function(_, content, prompt)
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

local title = function(type, content, prompt)
   if prompt ~= "" then
      return " "
   end
   return title_map[type]
end

local title_pos = function(type, content, prompt)
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
   if not in_cmd then
      return
   end
   log('update')
   vim.api.nvim_win_set_config(win, {
      relative = relative(),
      row = row(t, d, p),
      col = col(t, d, p),
      width = width(t, d, p),
      height = height(t, d),
   })
end

vim.api.nvim_create_autocmd("CmdLineChanged", {
   pattern = "*",
   callback = function()
      vim.api.nvim_win_set_config(win, {
         relative = relative(),
         row = row(t, d, p),
         col = col(t, d, p),
         width = width(t, d, p),
         height = height(t, d),
         border = "rounded",
         title = title(type, d, p),
      })
      vim.cmd.redraw()
   end
})

local last_win = vim.api.nvim_get_current_win()
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


local redrawing = false
local cmdlinens = vim.api.nvim_create_namespace('cmdline')
vim.api.nvim_set_hl(0, 'HIDDEN', { blend = 100, nocombine = true })
local call_c = 0
local handler = {
   ["cmdline_hide"] = function()
      vim.wo[win].winblend = 100
      vim.api.nvim_win_set_buf(win, emptybuf)
      vim.api.nvim_win_set_config(win, {
         relative = 'editor',
         row = 1,
         col = 1,
         width = 1,
         height = 1,
         border = 'none',
         title = '',
         title_pos = "left",
      })
      vim.go.guicursor = "a:Cursor"
      call_c = 0
      in_cmd = false
   end,
   ["cmdline_pos"] = function(pos, level)
      in_cmd = true
      cid = vim.api.nvim_buf_set_extmark(cmdbuf, cmdlinens, 0, pos + #p, {
         id = cid,
         end_col = pos + #p + 1,
         hl_group = "Cursor",
      })
      if redrawing then
         return
      end
      redrawing = true
      vim.schedule(function()
         vim.cmd([[ redraw ]])
         redrawing = false
      end)
   end,
   ["cmdline_show"] = function(content, pos, type, prompt, _, _)
      -- hack taken from noice
      vim.go.guicursor = "a:HIDDEN"
      local data = ""
      for i = 1, #content, 1 do
         data = data .. content[i][2]
      end

      local prefix = ""
      if prompt == "" then
         vim.fn.sign_place(0, "", type_sign[type] or "CmdLine", cmdbuf, { lnum = 1 })
         vim.wo[win].scl = "yes"
      else
         vim.wo[win].scl = "no"
         prefix = prompt
      end
      -- the space is for the extmark
      vim.api.nvim_buf_set_lines(cmdbuf, 0, -1, false, { prefix .. data .. ' ' })
      cid = vim.api.nvim_buf_set_extmark(cmdbuf, cmdlinens, 0, pos + #prefix, {
         id = cid,
         end_col = pos + #prefix + 1,
         hl_group = "Cursor",
      })
      vim.api.nvim_win_set_buf(win, cmdbuf)
      t = type
      d = data
      p = prompt
      pid = vim.api.nvim_buf_set_extmark(cmdbuf, cmdlinens, 0, 0, {
         id = pid,
         end_col = #prefix,
         hl_group = "FloatBorder",
      })
      if type ~= "" then
         if not ts_started then
            vim.treesitter.start(cmdbuf, 'vim')
            ts_started = true
            if pid then
               vim.api.nvim_buf_del_extmark(pid)
               pid = false
            end
         end
      else
         if ts_started then
            vim.treesitter.stop(cmdbuf, 'vim')
            ts_started = false
         end
      end
      -- 2 calls are enought to load the sign
      -- use set decortor to fix hlsearch
      call_c = call_c + 1
      -- search gets updates with the window decortor very hacky 
      if (type == '/' or type == '?') and call_c >= 3 then
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
      })
      if redrawing then
         return
      end
      redrawing = true
      vim.schedule(function()
         vim.wo[win].winblend = 0
         vim.cmd([[ redraw! ]])
         redrawing = false
      end)
   end,
}

local call_w = 0
vim.api.nvim_set_decoration_provider(cmdlinens, {
   on_win = function(_, rwin, ...)
      if rwin == win then
         if vim.fn.mode() ~= 'c' then
            call_w = 0
            return false
         end
         -- infite loop with : debug later
         if vim.fn.getcmdtype() ~= '/' and vim.fn.getcmdtype() ~= '?' then
            return
         end
         if call_c == call_w then
            return false
         end
         call_w = call_c
         vim.schedule(function()
            update_pos()
            vim.cmd.redraw()
         end
         )
      end
      return false
   end
})


vim.ui_attach(cmdlinens,
   {
      ext_cmdline = true,
   },
   function(name, ...)
      handler[name](...)
   end
)
