--[[
--MIT License
--
--Copyright (c) 2019 PapyElGringo
--Copyright (c) 2019 Tom Meyers
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

local capi      = { client = client }
local wibox     = require( "wibox"         )
local beautiful = require( "beautiful"     )
local awful     = require( "awful"         )
local surface   = require( "gears.surface" )
local shape     = require( "gears.shape"   )
local mat_color    = require("theme.mat-colors")
local config       = require( "theme.config"   ) 

local arrow_color = mat_color[config["accent"] or "cyan"].hue_500 or mat_color.cyan.hue_800
local bg_color = mat_color[config["background"] or "purple"].hue_800 or mat_color.purple.hue_800

function color(value)
  if value == nil then return nil end
  return "#" .. value
end


if config["accent_hue_500"] ~= nil then
  arrow_color = color(config["accent_hue_500"]) or arrow_color
end
if config["background_hue_800"] ~= nil then
bg_color = color(config["background_hue_800"]) or bg_color
end
bg_color = bg_color .. (config["background_transparent"] or "66")


local module,indicators,cur_c = {},nil,nil

local values = {"top"     , "top_right"  , "right" ,  "bottom_right" ,
                "bottom"  , "bottom_left", "left"  ,  "top_left"     }

local invert = {
  left  = "right",
  right = "left" ,
  up    = "down" ,
  down  = "up"   ,
}

local r_ajust = {
    left  = function(c, d) return { x      = c.x,             width = c.width -d } end,
    right = function(c, d) return { width  = c.width  + d,                       } end,
    up    = function(c, d) return { y      = c.y,          height = c.height - d } end,
    down  = function(c, d) return { height = c.height + d,                       } end,
}

local function create_indicators()
    local ret     = {}
    return ret
end

function module.hide()
end

function module.display(c,toggle)
end

function module.resize(mod,key,event,direction,is_swap,is_max)
    local c = capi.client.focus
    if not c then return true end

    local del = is_swap and -100 or 100
    direction = is_swap and invert[direction] or direction

    c:emit_signal("request::geometry", "mouse.resize", r_ajust[direction](c, del))

    return true
end

-- Always display the arrows when resizing
awful.mouse.resize.add_enter_callback(module.display, "mouse.resize")
awful.mouse.resize.add_leave_callback(module.hide   , "mouse.resize")

return module
-- kate: space-indent on; indent-width 4; replace-tabs on;
