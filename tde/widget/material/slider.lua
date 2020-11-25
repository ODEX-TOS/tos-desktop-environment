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
-- Default widget requirements
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local setmetatable = setmetatable
local dpi = require("beautiful").xresources.apply_dpi

-- Commons requirements
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
-- Local declarations

local mat_slider = {mt = {}}

function mat_slider:set_value(value)
  if self._private.value ~= value then
    self._private.value = value
    self._private.progress_bar:set_value(self._private.value)
    self:emit_signal("property::value")
  end
end

function mat_slider:get_value()
  return self._private.value
end

function mat_slider:set_read_only(value)
  if self._private.read_only ~= value then
    self._private.read_only = value
    self:emit_signal("property::read_only")
    self:emit_signal("widget::layout_changed")
  end
end

function mat_slider:get_read_only()
  return self._private.read_only
end

function mat_slider:layout(_, width, height)
  local layout = {}
  table.insert(layout, base.place_widget_at(self._private.progress_bar, 0, 0, width, height))
  return layout
end

function mat_slider:fit(_, width, height)
  return width, height
end

local function new(args)
  local ret =
    base.make_widget(
    nil,
    nil,
    {
      enable_properties = true
    }
  )

  gtable.crush(ret._private, args or {})

  gtable.crush(ret, mat_slider, true)

  ret._private.progress_bar =
    wibox.widget {
    bar_height = dpi(18),
    bar_color = beautiful.bg_modal,
    bar_active_color = beautiful.accent.hue_500,
    handle_shape = gears.shape.circle,
    handle_width = dpi(26),
    handle_color = beautiful.accent.hue_600,
    handle_border_width = 1,
    handle_border_color = "#00000012",
    minimum = 0,
    maximum = 100,
    value = 25,
    bar_shape = function(c, w, h)
      gears.shape.rounded_rect(c, w, h, dpi(35))
    end,
    widget = wibox.widget.slider
  }

  ret._private.read_only = false

  return ret
end

function mat_slider.mt:__call(...)
  return new(...)
end

return setmetatable(mat_slider, mat_slider.mt)
