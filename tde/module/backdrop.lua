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
local wibox = require("wibox")
local gears = require("gears")

local function update_backdrop(w, c)
  local cairo = require("lgi").cairo
  local geo = c.screen.geometry

  w.x = geo.x
  w.y = geo.y
  w.width = geo.width
  w.height = geo.height

  -- Create an image surface that is as large as the wibox
  local shape = cairo.ImageSurface.create(cairo.Format.A1, geo.width, geo.height)
  local cr = cairo.Context(shape)

  -- Fill with "completely opaque"
  cr.operator = "SOURCE"
  cr:set_source_rgba(1, 1, 1, 1)
  cr:paint()

  -- Remove the shape of the client
  local c_geo = c:geometry()
  local c_shape = gears.surface(c.shape_bounding)
  cr:set_source_rgba(0, 0, 0, 0)
  cr:mask_surface(c_shape, c_geo.x + c.border_width - geo.x, c_geo.y + c.border_width - geo.y)
  c_shape:finish()

  w.shape_bounding = shape._native
  shape:finish()
  w:draw()
end

local function backdrop(c)
  local function update()
    update_backdrop(c.backdrop, c)
  end
  if not c.backdrop then
    c.backdrop = wibox {ontop = true, bg = "#00000054", type = "splash"}
    c.backdrop:buttons(
      awful.util.table.join(
        awful.button(
          {},
          1,
          function()
            c:kill()
          end
        )
      )
    )
    c:connect_signal("property::geometry", update)
    c:connect_signal(
      "property::shape_client_bounding",
      function()
        gears.timer.delayed_call(update)
      end
    )
    c:connect_signal(
      "unmanage",
      function()
        c.backdrop.visible = false
      end
    )
    c:connect_signal(
      "property::shape_bounding",
      function()
        gears.timer.delayed_call(update)
      end
    )
  end
  update()
  c.backdrop.visible = true
end

_G.client.connect_signal(
  "manage",
  function(c)
    if c.drawBackdrop == true then
      backdrop(c)
    end
  end
)
