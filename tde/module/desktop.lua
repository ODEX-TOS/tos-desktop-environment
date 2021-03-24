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
local filehandle = require("lib-tde.file")
local desktop_icon = require("widget.desktop_icon")
local installed = require("lib-tde.hardware-check").has_package_installed
local inotify = require("inotify")
local gears = require("gears")
local common = require("lib-tde.function.common")

local desktopLocation = os.getenv("HOME") .. "/Desktop"
local offset = -1
if installed("installer") then
    offset = 1
end

local function name_to_config(name)
    return string.lower(name:gsub(" ", "-"):gsub(".desktop", ""))
end

local function update_entry(file, name)
    -- some desktop icons don't have a name but only a file
    name = name or file
    local config = os.getenv("HOME") .. "/.cache/tde/desktop.conf"
    local data = ""
    local found = false
    local widget_pos = desktop_icon.location_from_name(name)
    local stored_name = name_to_config(file)

    for _, value in ipairs(filehandle.lines(config)) do
        if common.split(value, " ")[1] == stored_name then
            if widget_pos.x ~= nil and widget_pos.y ~= nil then
                found = true
                data = data .. stored_name .. " " .. tostring(widget_pos.x) .. " " .. tostring(widget_pos.y) .. "\n"
            end
        else
            if value and not (value == "") then
                data = data .. value .. "\n"
            end
        end
    end

    if not found then
        data = data .. stored_name .. " " .. tostring(widget_pos.x) .. " " .. tostring(widget_pos.y) .. "\n"
    end

    filehandle.overwrite(config, data)
end

local function delete_entry(name)
    local config = os.getenv("HOME") .. "/.cache/tde/desktop.conf"
    local data = ""
    local stored_name = name_to_config(name)
    for _, value in ipairs(filehandle.lines(config)) do
        if not (common.split(value, " ")[1] == stored_name) and value and not (value == "") then
            data = data .. value .. "\n"
        end
    end
    filehandle.overwrite(config, data)
end

local function find_pos_by_name(name)
    local config = os.getenv("HOME") .. "/.cache/tde/desktop.conf"
    for _, value in ipairs(filehandle.lines(config)) do
        local data = common.split(value, " ")
        local stored_name = name_to_config(name)
        if data[1] == stored_name then
            local x = tonumber(data[2])
            local y = tonumber(data[3])
            return {x = x, y = y}
        end
    end
    return {x = nil, y = nil}
end

-- TODO: run filesystem event listener each time the desktop changes
if filehandle.dir_exists(desktopLocation) then
    for index, file in ipairs(filehandle.list_dir(desktopLocation)) do
        -- initialize x and y to nil, find the stored location otherwise use the default location
        local pos = find_pos_by_name(filehandle.basename(file))
        local x = pos.x
        local y = pos.y
        local position = index + offset
        if x and y then
            position = nil
        end

        desktop_icon.from_file(
            file,
            position,
            x,
            y,
            function(name)
                update_entry(filehandle.basename(file), name)
            end
        )
    end
end

local handle = inotify.init({blocking = false})
handle:addwatch(desktopLocation .. "/", inotify.IN_CREATE, inotify.IN_DELETE)

gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function()
        for ev in handle:events() do
            local file = desktopLocation .. "/" .. ev.name
            if filehandle.exists(file) then
                desktop_icon.from_file(
                    file,
                    desktop_icon.count() + offset + 1,
                    function(name)
                        update_entry(name)
                    end
                )
            else
                print(ev.name .. " deleted")
                desktop_icon.delete(ev.name)
                delete_entry(ev.name)
            end
        end
    end
}
