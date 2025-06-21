local callbacks = {}

local all_uis = {
    ext_messages = true,
    ext_cmdline = true,
    ext_popupmenu = true,
}
for option, _ in pairs(all_uis) do
    callbacks[option] = {}
end


ui_attach = vim.ui_attach
ui_detach = vim.ui_detach

function vim.ui_attach(ns, options, cb)
    for option, _ in pairs(options) do
        if callbacks[option] == nil then
            return
        end
        callbacks[option][ns] = cb
    end
end

function vim.ui_detach(ns)
    for name, _ in pairs(callbacks) do
        callbacks[name][ns] = nil
    end
end

function ui_cb(name, ...)
    local event = "foo"
    if vim.startswith(name, "msg") then
        event = ""
    end
    if vim.startswith(name, "cmdline") then
        event = "ext_cmdline"
    end
    if vim.startswith(name, "popup") then
        event = "ext_popupmenu"
    end
    for _, cb in pairs(callbacks[event] or {}) do
        cb(name, ...)
    end
end

local ns = vim.api.nvim_create_namespace("ui_handler")
ui_attach(ns, all_uis, ui_cb)
vim.keymap.set("n", ":",
    function()
        vim.schedule(function()
            all_uis["ext_messages"] = nil
            ui_attach(ns, all_uis, ui_cb)
        end)
    end
)
vim.keymap.set('n', ';', function()
    vim.api.nvim_feedkeys(":", 'tin', false)
end)
