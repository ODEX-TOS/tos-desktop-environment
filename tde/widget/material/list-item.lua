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
local clickable_container = require("widget.material.clickable-container")
local seperator_widget = require("lib-widget.separator")
-- Local declarations

local mat_list_item = {mt = {}}

function mat_list_item:build_separator()
  self._private.separator = seperator_widget(1, "horizontal", 0.08)
  self:emit_signal("widget::layout_changed")
end

function mat_list_item:build_clickable_container()
  self._private.clickable_container =
    wibox.widget {
    wibox.widget {
      widget = wibox.widget.textbox
    },
    widget = clickable_container
  }
  self:emit_signal("widget::layout_changed")
end

function mat_list_item:layout(_, width, height)
  local content_width = width - dpi(32)
  local content_x = dpi(dpi(16))
  local layout = {}

  -- Add divider if present
  if self._private.divider then
    table.insert(layout, base.place_widget_at(self._private.separator, 0, 0, width, 1))
  end

  -- Add clickable_container if clickable
  if self._private.clickable then
    table.insert(layout, base.place_widget_at(self._private.clickable_container, 0, 0, width, height))
  end

  if self._private.prefix then
    content_x = content_x + dpi(54)
    content_width = content_width - dpi(54)
    table.insert(layout, base.place_widget_at(self._private.prefix, dpi(16), 0, dpi(48), height))
  end

  if self._private.suffix then
    content_width = content_width - dpi(54)
    table.insert(layout, base.place_widget_at(self._private.suffix, width - dpi(40), dpi(12), width, height))
  end
  table.insert(layout, base.place_widget_at(self._private.content, content_x, 0, content_width, height))
  return layout
end

function mat_list_item:fit(_, width)
  return width, dpi(48)
end

---- Properties ----

-- Property clickable
function mat_list_item:set_clickable(value)
  if self._private.clickable ~= value then
    self._private.clickable = value
    self:emit_signal("property::clickable")
    self:emit_signal("widget::layout_changed")

    if self._private.clickable and not self._private.clickable_container then
      self:build_clickable_container()
    end
  end
end

function mat_list_item:get_clickable()
  return self._private.clickable
end

-- Property divider

function mat_list_item:set_divider(value)
  if self._private.divider ~= value then
    self._private.divider = value
    self:emit_signal("property::divider")
    self:emit_signal("widget::layout_changed")

    if self._private.divider and not self._private.separator then
      self:build_separator()
    end
  end
end

function mat_list_item:get_divider()
  return self._private.divider
end

function mat_list_item:set_prefix(widget)
  if widget then
    base.check_widget(widget)
  end
  self._private.prefix = widget
  self:emit_signal("widget::layout_changed")
end

function mat_list_item:get_prefix()
  return self._private.prefix
end

function mat_list_item:set_suffix(widget)
  if widget then
    base.check_widget(widget)
  end
  self._private.suffix = widget
  self:emit_signal("widget::layout_changed")
end

function mat_list_item:get_suffix()
  return self._private.suffix
end

function mat_list_item:set_content(widget)
  if widget then
    base.check_widget(widget)
  end
  self._private.content = widget
  self:emit_signal("widget::layout_changed")
end

function mat_list_item:get_content()
  return self._private.content
end

function mat_list_item:get_children()
  return {self._private.widget}
end

function mat_list_item:set_children(children)
  if not children[2] then
    self:set_content(children[1])
  else
    self:set_prefix(children[1])
    self:set_content(children[2])
  end
  if children[3] then
    self:set_suffix(children[3])
  end
end

local function new(widget)
  local ret =
    base.make_widget(
    nil,
    nil,
    {
      enable_properties = true
    }
  )

  gtable.crush(ret, mat_list_item, true)

  ret._private.content = widget
  return ret
end

function mat_list_item.mt:__call(...)
  return new(...)
end

return setmetatable(mat_list_item, mat_list_item.mt)
