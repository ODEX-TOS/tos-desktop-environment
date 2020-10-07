-- This file load plugins from the .config/tde/*/init.lua files
-- Usage in lua is require("plugin-dir-name")
-- End users should add their plugins in that directory
-- Following that there is a plugins.conf file inside .config/tos/plugins.conf
-- This file describes which plugins should be loaded
local dirExists = require("lib-tde.file").dir_exists
local naughty = require("naughty")
local ERROR = require("lib-tde.logger").error

local function getItem(item)
    return plugins[item] or nil
end

local function inValidPlugin(name, msg)
    print("Plugin " .. name .. " is not valid!")
    print(name .. " returned: " .. msg)
    -- notify the user that a wrong plugin was entered
    naughty.notify(
        {
            text = 'Plugin <span weight="bold">' .. name .. "</span>" .. msg,
            timeout = 5,
            screen = mouse.screen,
            urgency = "critical"
        }
    )
end

local function prequire(lib)
    local status, lib = pcall(require, lib)
    if (status) then
        return lib
    end
    print(lib, ERROR)
    return nil
end

local function getPluginSection(section)
    print(section .. " plugin loading started")
    local section = section .. "_"
    local iterator = {}
    local i = 0
    while true do
        i = i + 1
        name = section .. i
        if getItem(name) ~= nil then
            -- only require plugin if it exists
            -- otherwise the user entered a wrong pluging
            -- system plugins are also accepted and start with widget.
            if getItem(name):find("^widget.") or dirExists(os.getenv("HOME") .. "/.config/tde/" .. getItem(name)) then
                local plugin = prequire(getItem(name))
                if (plugin) then
                    table.insert(iterator, plugin)
                    print("Plugin " .. name .. " is loaded in!")
                else
                    inValidPlugin(
                        name,
                        "Errored out while loading. Make sure your plugins is the latest version and supports the latest TDE build."
                    )
                end
            else
                inValidPlugin(name, "Not found. Make sure it is present in  ~/.config/tde/" .. name .. "/init.lua")
            end
        else
            print(section .. " plugin loading ended")
            return iterator
        end
    end
    print(section .. " plugin loading ended")
end

return getPluginSection
