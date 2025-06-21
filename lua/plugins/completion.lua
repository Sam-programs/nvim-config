if true  then
    return {}
end
if true then
    return {
        {
            "Sam-programs/autopairs.nvim",
            event = 'VeryLazy',
            opts = {}
        },
        {
            "Sam-programs/expand.nvim",
            dependencies = { 'Sam-Programs/indent.nvim' },
            event = 'InsertEnter',
            opts = {
                filetypes = {
                    c = {
                        -- for functions
                        --                    { '\\w\\+ \\w\\+(.*)', { '<cr>{', '}' } },
                        { 'Vk\\a*.*\\[\\d*\\]', { function(match)
                            local k = vim.keycode
                            vim.api.nvim_feedkeys(k("{{}};<left><left><left>"), "n", false)
                            vim.api.nvim_input("<cr><c-k>")
                        end } },
                        { 'Vk\\a*.*', { function(match)
                            local k = vim.keycode
                            vim.api.nvim_feedkeys(k("{};<left><left>"), "n", false)
                            vim.api.nvim_input("<cr><c-k>")
                        end } },
                        { '^%s*$',             { '{', '},' }, { lua_pattern = true } },
                        { '^%s*\\.%w+%s*=%s*', { '{', '},' }, { lua_pattern = true } },

                        { '\\w*\\s*(.*)',      { '{', '}' } },
                        { 'else',              { '{', '}' },  { lua_pattern = true } },
                        { '',                  { '{', '};' } },
                    },
                    lua = {
                        { '^%s+[a-zA-z.]+%s*=%s*$',       { '{', '},' },      { lua_pattern = true } },
                        { '^%s*$',                        { '{', '},' },      { lua_pattern = true } },

                        -- regex for a lua variable
                        { '^%s*%w*%s*[a-zA-z.]+%s*=%s*$', { '{', '}' },       { lua_pattern = true } },
                        -- if we are expanding on an unnamed function might as well add the pairs
                        { 'function[^(]*$',               { '()', 'end' },    { lua_pattern = true, go_to_end = false } },
                        { 'function',                     { '', 'end' },      { lua_pattern = true } },
                        { 'if',                           { ' then', 'end' }, { lua_pattern = true } },
                        { 'loops',                        { ' do', 'end' },   { lua_pattern = true } },
                    },

                }
            }
        },
    }
end
local oldcmp = {
    {
        'Sam-programs/nvim-cmp',
        branch = 'toggle_completion_menu',
        dependencies = {
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lsp' },
        },
        event = 'VeryLazy',
        config = function()
            if true then
                return
            end
            local cmp = require('cmp')
            local cmp_win = require('cmp.utils.window')
            local cmp_performance = nil
            local kind = cmp.lsp.CompletionItemKind
            GhostText = vim.api.nvim_get_hl(0, { name = "Comment" })
            GhostText.italic = false
            vim.api.nvim_set_hl(0, "CmpGhostText", GhostText)

            if eopts.cmp_ghost_text_only then
                cmp_win.update = function() end
                cmp_win.open = function(self, style)
                    local yes = {
                        relative = 'editor',
                        style = 'minimal',
                        -- placing it at the top right makes it blend with the theme
                        col = vim.o.co,
                        row = 0,
                        width = 1,
                        height = 1,
                        zindex = 1,
                    }
                    self:set_style(yes)
                    if self.win and vim.api.nvim_win_is_valid(self.win) then
                        vim.api.nvim_win_set_config(self.win, yes)
                    else
                        self.win = vim.api.nvim_open_win(self:get_buffer(), false, yes)
                    end
                end
                cmp_performance = {
                    confirm_resolve_timeout = 0,
                    throttle                = 0,
                    debounce                = 0,
                    fetching_timeout        = 100,
                    -- useful for S-Tab
                    max_view_entries        = 50,
                }
            end
            local compare = require('cmp.config.compare')
            local cmp_comparators = {
                compare.order,
                compare.score,
            }
            cmp.setup({
                enabled = function()
                    if vim.o.ft == 'TelescopePrompt' then
                        return
                    end
                    return true
                end,
                mapping = cmp.mapping.preset.insert({
                    ["<C-l>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            return cmp.confirm({
                                select = true
                            })
                        end
                        fallback()
                    end),
                    ["<S-tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            return cmp.complete_common_string()
                        end
                        fallback()
                    end),
                    ["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

                    ["<c-e>"] = cmp.config.disable,
                    ["<c-d>"] = cmp.config.disable,
                }),
                sources = {
                    { name = "nvim_lsp", group_index = 1 },
                    { name = "path",     group_index = 2 },
                },
                matching = {
                    disallow_prefix_unmatching = true,
                },
                snippet = {
                    expand = function(args)
                        unpack = unpack or table.unpack
                        local line_num, col = unpack(vim.api.nvim_win_get_cursor(0))
                        local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, true)[1]
                        local replace = vim.split(args.body, '\n', true)
                        local cursor_pos = col + #replace[1]
                        replace[1] = line_text:sub(1, col) .. replace[1] .. line_text:sub(col + 1)
                        replace = { replace[1] }
                        vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, true, replace)
                        vim.api.nvim_win_set_cursor(0, { line_num, cursor_pos })
                    end,
                },
                window = {
                    auto_hide = true,
                },
                sorting = {
                    comparators = cmp_comparators
                },
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    }
                },
                performance = cmp_performance,
            })
            -- i don't use nvim-autopairs and this is simple enough for me
            -- auto add pairs
            local function pair_on_confirm(event)
                local entry = event.entry
                local item = entry:get_completion_item()
                local pairs = '()'
                local functionsig = item.label
                local c = vim.api.nvim_win_get_cursor(0)[2]
                local line = vim.api.nvim_get_current_line()
                if line:sub(c + 1, c + 1) ~= '(' and
                    item.kind == kind.Function or item.kind == kind.Method then
                    -- auto skip empty functions
                    if functionsig:sub(#functionsig - 1, #functionsig) ~= pairs then
                        pairs = pairs .. vim.api.nvim_replace_termcodes('<left>', true, false, true)
                    end
                    vim.api.nvim_feedkeys(pairs, "n", false)
                end
            end
            cmp.event:on('confirm_done', pair_on_confirm)
        end
    }
}
