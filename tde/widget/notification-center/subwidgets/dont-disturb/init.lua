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
local clickable_container = require("widget.action-center.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local mat_list_item = require("widget.material.list-item")
local beautiful = require("beautiful")

local PATH_TO_ICONS = "/etc/xdg/awesome/widget/notification-center/icons/"
local PATH_TO_WIDGET = "/etc/xdg/awesome/widget/notification-center/subwidgets/dont-disturb/"
local theme = require("theme.icons.dark-light")

dont_disturb = false

local dont_disturb_text =
  wibox.widget {
  text = i18n.translate("Do Not Disturb"),
  font = "SFNS Display 12",
  align = "left",
  widget = wibox.widget.textbox
}

local widget =
  wibox.widget {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local dont_disturb_icon =
  wibox.widget {
  {
    image = theme(PATH_TO_ICONS .. "dont-disturb" .. ".svg"),
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local function update_icon()
  local widgetIconName
  if (dont_disturb == true) then
    widgetIconName = "toggled-on"
    widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. ".svg"))
  else
    widgetIconName = "toggled-off"
    widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. ".svg"))
  end
end

-- Function to check status after awesome.restart()
local function check_disturb_status()
  local cmd = "cat " .. PATH_TO_WIDGET .. "disturb_status"
  awful.spawn.easy_async_with_shell(
    cmd,
    function(stdout)
      local status = stdout
      if status:match("true") then
        dont_disturb = true
        update_icon()
      elseif status:match("false") then
        dont_disturb = false
        update_icon()
      else
        dont_disturb = false
        awful.spawn.easy_async_with_shell(
          "echo " .. "false" .. " > " .. PATH_TO_WIDGET .. "disturb_status",
          function(stdout)
          end,
          false
        )
        update_icon()
      end
    end,
    false
  )
end

-- Check Status after restart()
check_disturb_status()

-- Maintain Status even after awesome.restart() by writing on the PATH_TO_WIDGET/ .. disturb_status
local function toggle_disturb()
  if (dont_disturb == true) then
    -- Switch Off
    dont_disturb = false
    awful.spawn.easy_async_with_shell(
      "echo " .. tostring(dont_disturb) .. " > " .. PATH_TO_WIDGET .. "disturb_status",
      function(stdout)
      end,
      false
    )
    update_icon()
  else
    -- Switch On
    dont_disturb = true
    awful.spawn.easy_async_with_shell(
      "echo " .. tostring(dont_disturb) .. " > " .. PATH_TO_WIDGET .. "disturb_status",
      function(stdout)
      end,
      false
    )
    update_icon()
  end
end

local disturb_button = clickable_container(widget)
disturb_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        toggle_disturb()
      end
    )
  )
)

local content =
  wibox.widget {
  {
    wibox.container.margin(dont_disturb_icon, dpi(12), dpi(12), dpi(5), dpi(5)),
    dont_disturb_text,
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  {
    disturb_button,
    layout = wibox.layout.fixed.horizontal
  },
  layout = wibox.layout.align.horizontal
}

local dont_disturb_wrap =
  wibox.widget {
  wibox.widget {
    {
      content,
      margins = dpi(10),
      widget = wibox.container.margin
    },
    bg = beautiful.bg_modal_title,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 6)
    end,
    widget = wibox.container.background
  },
  widget = mat_list_item
}

return dont_disturb_wrap
