-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local ensure_packer = function()
   local fn = vim.fn
   local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
   if fn.empty(fn.glob(install_path)) > 0 then
      fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
      vim.cmd [[packadd packer.nvim]]
      return true
   end
   return false
end

local packer_bootstrap = ensure_packer()
-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
   -- Packer can manage itself
   use 'wbthomason/packer.nvim'

   use 'folke/tokyonight.nvim'

   use {
      'nvim-telescope/telescope.nvim', tag = '0.1.0',
      requires = {
         { 'nvim-lua/plenary.nvim' },
         { 'nvim-tree/nvim-web-devicons' } } -- optional
   }
   use({
      'weilbith/nvim-code-action-menu',
      cmd = 'CodeActionMenu',
   })

   use({
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
   })

   use({
      "nvim-treesitter/nvim-treesitter-textobjects",
      after = "nvim-treesitter",
      requires = "nvim-treesitter/nvim-treesitter",
   })

   use {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-cmdline' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-nvim-lsp' },
      -- Snippets
       { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
   }

   use "ray-x/lsp_signature.nvim"

   use {
      'nvim-lualine/lualine.nvim',
      requires = { 'nvim-tree/nvim-web-devicons' } --optional
   }

   if packer_bootstrap then
      require('packer').sync()
   end
end)
