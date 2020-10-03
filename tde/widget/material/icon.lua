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

-- Commons requirements
local wibox = require("wibox")

-- Local declarations

local mat_list_item = {mt = {}}

function mat_list_item:layout(_, width, height)
  local layout = {}

  -- Add divider if present
  if self._private.icon then
    table.insert(
      layout,
      base.place_widget_at(
        self._private.imagebox,
        width / 2 - self._private.size / 2,
        height / 2 - self._private.size / 2,
        self._private.size,
        self._private.size
      )
    )
  end
  return layout
end

function mat_list_item:fit(_, width, height)
  local min = math.min(width, height)
  return min, min
end

function mat_list_item:set_icon(icon)
  self._private.icon = icon
  self._private.imagebox.image = icon
end

function mat_list_item:get_icon()
  return self._private.icon
end

function mat_list_item:set_size(size)
  self._private.size = size
  self:emit_signal("widget::layout_changed")
end

function mat_list_item:get_size()
  return self._private.size
end

local function new(icon, size)
  local ret =
    base.make_widget(
    nil,
    nil,
    {
      enable_properties = true
    }
  )

  gtable.crush(ret, mat_list_item, true)
  ret._private.icon = icon
  ret._private.imagebox = wibox.widget.imagebox(icon)
  ret._private.size = size
  return ret
end

function mat_list_item.mt:__call(...)
  return new(...)
end

--@DOC_widget_COMMON@

--@DOC_object_COMMON@

return setmetatable(mat_list_item, mat_list_item.mt)
