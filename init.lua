eopts = {
    -- options that i think might be a bit weird for some people
    -- but i like em

    -- don't show a pop up menu with many options
    -- suggest a 1 completion option with ghosted text that looks like this comment
    cmp_ghost_text_only = false,
    -- lualine themes have mode colors with each mode which are a bit too flashy for me
    -- insert mode green,command yellow,etc
    -- so i disable them
    lualine_no_mode_colors = true,
    lsp_signs = {
        Error = "",
        Warn = "",
        Hint = "",
        Info = ""
    },
    mason_icons = {
        package_installed = "",
        package_pending = "",
        package_uninstalled = ""
    },
    lsps = {
        "lua_ls",
        "clangd",
    },
    semicolon_langs = {
        c = true,
        cpp = true,
        cs = true,
    },
}
require('setup')
vim.cmd("runtime! lazy.lua")
vim.uv.sleep(1000)
