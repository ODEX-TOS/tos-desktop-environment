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
local gears = require("gears")
local docs = require("module.docs")
local naughty = require("naughty")
local icons = require('theme.icons')

local function create_timer(done_cb)
    local bOpenedURL = false

    local timer

    timer = gears.timer {
        autostart = true,
        timeout = 5,
        callback = function ()
            print("Running plugin portal")
            -- Check the network connection, if no network is found the Location header is set
            awful.spawn.easy_async("curl -I http://detectportal.firefox.com", function (stdout)
                local path = stdout:match("Location: (.+)")

                if path and not bOpenedURL then
                    print("Portal url found:\n" .. path)
                    bOpenedURL = true

                    naughty.notification({
                        title = i18n.translate("Network"),
                        text = i18n.translate('Wi-Fi portal detected, please login'),
                        timeout = 5,
                        urgency = 'normal',
                        icon = icons.wifi
                      })

                    awful.spawn.easy_async({"xdg-open", tostring(path)}, function ()
                        docs.find_browser()
                        -- disable the timer
                        timer:stop()

                        done_cb()
                    end)
                end
            end)
        end
    }
end

local timer_done_cb = function()
end

timer_done_cb = function ()
    gears.timer {
        timeout = 180,
        autostart = true,
        single_shot = true,
        callback = function ()
            create_timer(timer_done_cb)
        end
    }
end

create_timer(timer_done_cb)