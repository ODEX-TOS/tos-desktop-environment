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
local dpi_handle = require("widget.settings.dpi-handler")

local settings_width = dpi(1100)
local settings_height = dpi(1000)

local m = dpi_handle.get_dpi(dpi(10), settings_width, settings_height)
local settings_index = dpi_handle.get_dpi(dpi(40), settings_width, settings_height)
local settings_nw = dpi_handle.get_dpi(dpi(260), settings_width, settings_height)

return {
     m = m,
     settings_index = settings_index,
     settings_width =  dpi_handle.get_dpi(settings_width, settings_width, settings_height),
     settings_height = dpi_handle.get_dpi(settings_height, settings_width, settings_height),
     settings_nw = settings_nw
}