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
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

require("configuration.client.rules")


local function draw_client_border(c)
    if _G.save_state.developer.draw_debug then
        c.border_width = dpi(2)
    else
        c.border_width = 0
    end
end

client.connect_signal("request::manage", draw_client_border)

client.connect_signal("unfocus", function (c)
    if c.fullscreen then
        c:lower()
    end
end)

client.connect_signal("focus", function (c)
    if c.fullscreen then
        c:raise()
    end
end)

client.connect_signal("draw_debug", function()
    for _, c in ipairs(client.get()) do
        draw_client_border(c)
    end
end)