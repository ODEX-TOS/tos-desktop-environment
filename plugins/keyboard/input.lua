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

local keygrabber = require("awful.keygrabber")

local grabber
local prev_grabber

local function start_grabbing(callback)
    if keygrabber.is_running then
        prev_grabber = keygrabber.current_instance
        prev_grabber:stop()
    end

    grabber = awful.keygrabber {
        autostart = true,
        keypressed_callback = function(_, mod, key, _)
            if key == "Escape" or key == "Control_L" or key == "Control_R" then return end

            local str = ""

            for _, value in ipairs(mod) do
                if value ~= "Mod2" then
                    str = str .. value .. "+"
                end
            end

            str = str .. key

            callback(str)
        end,

        -- Note that it is using the key name and not the modifier name.
        stop_key           = 'Escape',
        stop_event         = 'release',
        export_keybindings = false,
    }

    grabber:connect_signal("stopped", function()
        if _G.root.elements.settings.visible then
            print("Starting root settings grabber")
            root.elements.settings_grabber:start()
        elseif prev_grabber ~= nil then
            print("Starting previous grabber")
            prev_grabber:start()
        end
    end)
end

local function stop_grabbing()
    if grabber ~= nil then
        grabber:stop()
        grabber = nil
    end

    if keygrabber.is_running then
        keygrabber.current_instance:stop()
    end

    root.elements.settings_grabber:stop()
end

return {
    start_grabbing = start_grabbing,
    stop_grabbing = stop_grabbing
}