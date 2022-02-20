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
local signals = require("lib-tde.signals")
local hardware = require("lib-tde.hardware-check")
local gettime = require("socket").gettime

local screen_geometry = {}
local weak = {}
setmetatable(screen_geometry, weak)
weak.__mode = "k"


local function update_screens()
    print("Screen layout changed")

    -- cleanup
    screen_geometry = {}

    -- repopulate screen geometry
    for s in screen do
        table.insert(screen_geometry, s.geometry)
    end

    -- notify tde of screen changes
    signals.emit_refresh_screen()

end

local function get_all_output_names()
    local output_names = {}
    for s in screen do
        for _, output in pairs(s.outputs) do
            table.insert(output_names, output.name)
        end
    end
    return output_names
end

local function remove_virtual_displays_if_found()
    local output_names = get_all_output_names()

    -- Check if we can find a VIRTUAL[0-9]+ output, if this is the case, we disable it
    for _, output in ipairs(output_names) do
        if string.find(output, "VIRTUAL[0-9]+") then
            print("Virtual output found, disabling it")
            -- NOTE: This will trigger a screen::change event which will restart tde
            hardware.execute("xrandr --output " .. output .. " --off")
        end
    end
end

local function handle_screen_methods()
    remove_virtual_displays_if_found()

    -- No more virtual outputs, we can refresh TDE
    tde.restart()
end

-- When starting TDE make sure no virtual displays are found
remove_virtual_displays_if_found()

-- listen for screen changes
tde.connect_signal(
    "screen::change",
    handle_screen_methods
)

screen.connect_signal(
    "removed",
    handle_screen_methods
)

local prev_time = gettime()
-- specify how often to poll
local refresh_timeout_in_seconds = 0.5

local function are_screens_equal(s1, s2)
    return s1.x == s2.x and s1.y == s2.y and s1.width == s2.width and s1.height == s2.height
end

local function perform_refresh()
    if not (#screen_geometry == screen.count()) then
        update_screens()
    end
    -- check if our output changed
    local i = 1
    for s in screen do
        if not are_screens_equal(s.geometry, screen_geometry[i]) then
            update_screens()
        end
        i = i + 1
    end
end

tde.connect_signal(
    "refresh",
    function()
        local time = gettime()
        if prev_time < (time - refresh_timeout_in_seconds) then
            prev_time = time
            perform_refresh()
        end
    end
)
