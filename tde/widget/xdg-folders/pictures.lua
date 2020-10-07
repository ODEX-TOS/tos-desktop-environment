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
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local PATH_TO_ICONS = "/etc/xdg/awesome/widget/xdg-folders/icons/"
local menubar = require("menubar")

function icon(item)
  return menubar.utils.lookup_icon(item)
end
local picWidget =
  wibox.widget {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local pic_button = clickable_container(wibox.container.margin(picWidget, dpi(8), dpi(8), dpi(8), dpi(8)))
pic_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn.easy_async_with_shell(
          "xdg-open $HOME/Pictures",
          function(stderr)
          end,
          1
        )
      end
    )
  )
)

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
awful.tooltip(
  {
    objects = {pic_button},
    mode = "outside",
    align = "right",
    timer_function = function()
      return "Pictures"
    end,
    preferred_positions = {"right", "left", "top", "bottom"}
  }
)

picWidget.icon:set_image(icon("folder-pictures") or (PATH_TO_ICONS .. "folder-pictures" .. ".svg"))

return pic_button
