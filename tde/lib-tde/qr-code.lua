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
---------------------------------------------------------------------------
-- Generate qr codes.
--
-- This module allows generating qr codes and exposes it in different was (Allow showing cairo surfaces, images or an internal list)
--
--
--    -- Get back an image displaying a QR code
--    lib-tde.qr-code.image("This is a qr code")
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.qr-code
---------------------------------------------------------------------------
local qrencode = require("qrencode")

local cairo = require("lgi").cairo
local gears = require("gears")

local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi


local white = gears.color("#FFFFFF")
local black = gears.color("#000000")

local function draw_cell(cr, x, y, width, height, color)
    if color < 0 then
        cr:set_source(white)
    else
        cr:set_source(black)
    end

    cr:rectangle(x, y, width, height)
    cr:fill()
end

local function qr_to_cairo(qr, size)
    size =  size or 100

    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, size, size)

    local cr  = cairo.Context(img)

    local cell_size = size / #qr

    for x, column in ipairs(qr) do
        for y, color in ipairs(column) do
            draw_cell(cr, (x-1) * cell_size, (y-1) * cell_size, cell_size+1, cell_size+1, color )
        end
    end

    return img
end


--- Returns a 2 dimensional lua list containing each qr code cell
--- Each cell is is a number, positive is black, negative is white
-- @tparam string text The text to convert to a qr code
-- @staticfct list
-- @usage
--    lib-tde.qr-code.list("This is some text")
local function list(text)
    local _, qr = qrencode.qrcode(text)
    return qr
end

--- Returns a cairo surface that can be drawn to any context
-- @tparam string text The text to convert to a qr code
-- @tparam[opt=300] size the size of the resulting surface
-- @staticfct surface
-- @usage
--    lib-tde.qr-code.surface("This is some text", dpi(300)) -- returns a cairo surface
local function surface(text, size)
    size = size or dpi(300)
    local qr = list(text)
    return qr_to_cairo(qr, size)
end

--- Returns a wibox.widget.imagebox containing the qr code
-- @tparam string text The text to convert to a qr code
-- @tparam[opt=300] size the size of the resulting surface
-- @staticfct image
-- @usage
--    lib-tde.qr-code.image("This is some text", dpi(300)) -- returns a wibox.widget.imagebox
local function image(text, size)
    return wibox.widget.imagebox(surface(text,size), false)
end



return {
    image = image,
    list = list,
    surface = surface
}
