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

-- This file is responsible for making sure the settings application still fits in the view (By automatically scaling the dpi settings)

local filesystem = require("lib-tde.file")
local awful = require("awful")
local stdlib = require("posix.stdlib")

stdlib.setenv("QT_AUTO_SCREEN_SCALE_FACTOR", "0")

local function update_dpi(value)
    local xresource_file = os.getenv("HOME") .. '/.Xresources'

    -- make the changes persistant
    filesystem.replace(xresource_file, "Xft.dpi:.*", "Xft.dpi: " .. value)
    awful.spawn({'xrdb', xresource_file}, false)

    -- We also need to take into account the scaling of QT applications: see https://forum.manjaro.org/t/scaling-issues-with-qt-apps-on-gnome/39843/8
    local qt_scale_file = os.getenv("HOME") .. '/.profile'
    if filesystem.string(qt_scale_file):find("export QT_FONT_DPI=") ~= nil then
        filesystem.replace(qt_scale_file, "export QT_FONT_DPI=.*", "export QT_FONT_DPI=" .. value)
    else
        filesystem.write(qt_scale_file, "export QT_FONT_DPI=" .. value)
    end

    -- Now we also expose the environment variable to the active DE instance, so new apps will be scaled without reloading the DE
    stdlib.setenv("QT_FONT_DPI", value)
    stdlib.setenv("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
end

local function get_dpi(dpi, width, height)
   local smallest
   local _smallest_size = math.huge
   -- find the smallest viewport
   for _, port in ipairs(screen._viewports()) do
       local size = port.geometry.width * port.geometry.height
       if size < _smallest_size then
           _smallest_size = size
           smallest = port
       end
   end

   if smallest == nil then
       return dpi
   end

   local smallest_width = smallest.geometry.width
   local smallest_height = smallest.geometry.height

   local function offset(_dpi)
        if _dpi == smallest_height or _dpi == smallest_width then
            return _dpi * 0.95
        end

        return _dpi
   end

   -- lets check that the viewport has more space than the dpi
   if width > smallest_width and height > smallest_height then
       -- we need to scale the dpi
       local scale_x = smallest_width / width
       local scale_y = smallest_height / height
       local scale = math.min(scale_x, scale_y)
       return offset(dpi * scale)
   elseif width > smallest_width then
        local scale_x = smallest_width / width
        return offset(dpi * scale_x)
   elseif height > smallest_height then
        local scale_y = smallest_height / height
        return offset(dpi * scale_y)
   else
       return dpi
   end
end


return {
    update_dpi = update_dpi,
    get_dpi = get_dpi,
}