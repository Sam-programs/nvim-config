require("tokyonight").setup({
   -- your configuration comes here
   -- or leave it empty to use the default settings
   style = "storm",                 -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
   light_style = "day",             -- The theme is used when the background is set to light
   transparent = false,             -- Enable this to disable setting the background color
   terminal_colors = true,          -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
   styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = { italic = true },
      keywords = { italic = true },
   },
   sidebars = { "qf", "help" },          -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
})
vim.cmd [[colorscheme tokyonight]]

