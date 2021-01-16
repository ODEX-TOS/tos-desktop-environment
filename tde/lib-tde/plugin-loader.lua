--[[
--MIT License
--
--Copyright (c) 2019 manilarome
--Copyright (c) 2020 Tom Meyers
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
]]
-- This file load plugins from the .config/tde/*/init.lua files
-- Usage in lua is require("plugin-dir-name")
-- End users should add their plugins in that directory
-- Following that there is a plugins.conf file inside .config/tos/plugins.conf
-- This file describes which plugins should be loaded
local dirExists = require("lib-tde.file").dir_exists
local naughty = require("naughty")
local icons = require("theme.icons")
local ERROR = require("lib-tde.logger").error

local function getItem(item)
    return plugins[item] or nil
end

local function inValidPlugin(name, msg)
    print("Plugin " .. name .. " is not valid!")
    print(name .. " returned: " .. msg)
    -- notify the user that a wrong plugin was entered
    naughty.notification(
        {
            title = i18n.translate("Plugin System"),
            text = 'Plugin <span weight="bold">' .. name .. "</span>\n" .. msg,
            timeout = 5,
            urgency = "critical",
            icon = icons.warning
        }
    )
end

local function prequire(library)
    local status, lib = pcall(require, library)
    if (status) then
        return lib
    end
    print(lib, ERROR)
    return nil
end

local function getPluginSection(section)
    print(section .. " plugin loading started")
    section = section .. "_"
    local iterator = {}
    local i = 0
    while true do
        i = i + 1
        local name = section .. i
        local value = getItem(name)
        if value ~= nil then
            -- system plugins are also accepted and start with widget.
            if value:sub(1, 7) == "widget." then
                if
                    general["minimize_network_usage"] == "1" and
                        (value == "widget.sars-cov-2" or value == "widget.weather")
                 then
                    print("Disabled widget: '" .. value .. "' due to low network requirements")
                else
                    -- only require plugin if it exists
                    -- otherwise the user entered a wrong pluging
                    table.insert(iterator, require(value))
                end
            elseif dirExists(os.getenv("HOME") .. "/.config/tde/" .. value) then
                local plugin = prequire(value)
                if (plugin) then
                    print("Plugin " .. name .. " is loaded in!")
                    table.insert(iterator, plugin)
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
end

return getPluginSection
