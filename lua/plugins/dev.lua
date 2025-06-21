return {
    {
        'max397574/better-escape.nvim',
        enabled = true,
        config = function()
            local opts = {
            }
            require("better_escape").setup(opts)
        end
    }
}
