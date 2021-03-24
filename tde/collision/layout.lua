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
-- This lib-tde module help retro-generate the clients layout from awful
-- this is a giant hack and doesn't even always work and require upstream
-- patches

local setmetatable = setmetatable
local awful = require("awful")
local beautiful = require("beautiful")
local util = require("collision.util")
local shape = require("gears.shape")
local capi = {screen = screen, client = client}

local module = {}
local margin = 2
local radius = 4

-- Emulate a client using meta table magic
local function gen_cls(c, results)
  local ret =
    setmetatable(
    {},
    {
      __index = function(_, i)
        local ret2 = c[i]
        if type(ret2) == "function" then
          if i == "geometry" then
            return function(_, ...)
              if #{...} > 0 then
                local geom = ({...})[1]
                -- Make a copy as the original will be changed
                results[c] = awful.util.table.join(({...})[1], {})
                return geom
              end
              return c:geometry()
            end
          else
            return function(_, ...)
              return ret2(c, ...)
            end
          end
        end
        return ret2
      end
    }
  )
  return ret
end

function module.get_geometry(tag)
  local cls, results, flt = {}, setmetatable({}, {__mode = "k"}), {}
  local s = tag.screen
  local l = awful.tag.getproperty(tag, "layout")
  local focus, focus_wrap = capi.client.focus, nil
  for _, c in ipairs(tag:clients()) do
    -- Handle floating client separately
    if not c.minimized then
      local floating = c.floating
      if (not floating) and (not l == awful.layout.suit.floating) then
        cls[#cls + 1] = gen_cls(c, results)
        if c == focus then
          focus_wrap = cls[#cls]
        end
      else
        flt[#flt + 1] = c:geometry()
      end
    end
  end

  -- The magnifier layout require a focused client
  -- there wont be any as that layout is not selected
  -- take one at random or (TODO) use stack data
  if not focus_wrap then
    focus_wrap = cls[1]
  end

  local param = {
    tag = tag,
    screen = 1,
    clients = cls,
    focus = focus_wrap,
    workarea = capi.screen[s or 1].workarea
  }

  l.arrange(param)

  return results, flt
end

function module.draw(tag, cr, width, height)
  local worked = false
  local l, l2 = module.get_geometry(tag)
  local s = tag.screen
  local scr_geo = capi.screen[s or 1].workarea
  local ratio = height / scr_geo.height
  local w_stretch = width / (scr_geo.width * ratio)
  local r, g, b = util.get_rgb(beautiful.primary.hue_600 or beautiful.fg_normal)

  local lshape = beautiful.collision_layout_shape or shape.rounded_rect

  cr:set_line_width(3)
  for _, ll in ipairs({l, l2}) do
    for _, geom in pairs(ll) do
      shape.transform(lshape):translate(geom.x * ratio * w_stretch + margin, geom.y * ratio + margin)(
        cr,
        geom.width * ratio * w_stretch - margin * 2,
        geom.height * ratio - margin * 2,
        radius
      )
      cr:close_path()
      cr:set_source_rgba(r, g, b, 0.7)
      cr:stroke_preserve()
      cr:set_source_rgba(r, g, b, 0.2)
      cr:fill()

      -- Draw an icon in the region
      --TODO

      worked = true
    end
  end
  --TODO floating clients
  return worked
end

return module
-- kate: space-indent on; indent-width 2; replace-tabs on;
