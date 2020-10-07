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
local beautiful = require("beautiful")

local dpi = require("beautiful").xresources.apply_dpi
local clickable_container = require("widget.material.clickable-container")

local scrollbar = require("widget.scrollbar")

-- load the notification plugins
local plugins = require("lib-tde.plugin-loader")("notification")

-- body gets populated with a scrollbar widget once generated
local body = {}

local function notification_plugin()
  local table_widget =
    wibox.widget {
    separator,
    layout = wibox.layout.fixed.vertical
  }

  local table =
    wibox.widget {
    visible = false,
    layout = wibox.layout.fixed.vertical,
    table_widget
  }

  for index, value in ipairs(plugins) do
    table_widget:add(
      {
        wibox.container.margin(value, dpi(15), dpi(15), dpi(0), dpi(10)),
        layout = wibox.layout.fixed.vertical
      }
    )
  end
  return table
end

panel_visible = false

local right_panel = function(screen)
  local panel_width = dpi(350)
  local panel =
    wibox {
    ontop = true,
    screen = screen,
    width = panel_width,
    height = screen.geometry.height,
    x = screen.geometry.width - panel_width,
    bg = beautiful.background.hue_800,
    fg = beautiful.fg_normal
  }

  panel.opened = false

  local grabber =
    awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          panel.opened = false
          closePanel()
        end
      }
    },
    -- Note that it is using the key name and not the modifier name.
    stop_key = "Escape",
    stop_event = "release"
  }

  local backdrop =
    wibox {
    ontop = true,
    screen = screen,
    bg = "#00000000",
    type = "dock",
    x = screen.geometry.x,
    y = screen.geometry.y,
    width = screen.geometry.width,
    height = screen.geometry.height
  }

  panel:struts(
    {
      right = 0
    }
  )

  local notification_widget =
    wibox.widget {
    visible = true,
    separator,
    require("widget.notification-center.subwidgets.dont-disturb"),
    {
      expand = "none",
      layout = wibox.layout.align.horizontal,
      {
        nil,
        layout = wibox.layout.fixed.horizontal
      },
      nil,
      {
        wibox.container.margin(clear_all_button, dpi(15), dpi(15), dpi(10), dpi(0)),
        layout = wibox.layout.fixed.horizontal
      }
    },
    {
      require("widget.notification-center.subwidgets.notif-generate"),
      wibox.widget({}),
      margins = dpi(15),
      widget = wibox.container.margin
    },
    layout = wibox.layout.fixed.vertical
  }

  openPanel = function()
    panel_visible = true
    backdrop.visible = true
    panel.visible = true
    grabber:start()
    panel:emit_signal("opened")
  end

  closePanel = function()
    panel_visible = false
    panel.visible = false
    backdrop.visible = false
    grabber:stop()
    panel:emit_signal("closed")
    -- reset the scrollbar
    body:reset()
  end

  -- Hide this panel when app dashboard is called.
  function panel:HideDashboard()
    closePanel()
  end

  function panel:toggle()
    self.opened = not self.opened
    if self.opened then
      openPanel()
    else
      closePanel()
    end
  end

  widgets = notification_plugin()

  function panel:switch_mode(mode)
    if mode == "notif_mode" then
      -- Update Content
      notification_widget.visible = true
      widgets.visible = false
    elseif mode == "widgets_mode" then
      -- Update Content
      notification_widget.visible = false
      widgets.visible = true
    end
  end

  backdrop:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          panel:toggle()
        end
      )
    )
  )

  local clear_all_text =
    wibox.widget {
    text = "Clear All Notifications",
    font = "SFNS Display Regular 10",
    align = "center",
    valign = "bottom",
    widget = wibox.widget.textbox
  }
  local wrap_clear_text =
    wibox.widget {
    clear_all_text,
    margins = dpi(5),
    widget = wibox.container.margin
  }
  local clear_all_button = clickable_container(wibox.container.margin(wrap_clear_text, dpi(0), dpi(0), dpi(3), dpi(3)))
  clear_all_button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          _G.clear_all()
          _G.firstime = true
        end
      )
    )
  )

  local separator =
    wibox.widget {
    orientation = "horizontal",
    opacity = 0.0,
    forced_height = 15,
    widget = wibox.widget.separator
  }

  local headerSeparator =
    wibox.widget {
    orientation = "horizontal",
    forced_height = 15,
    span_ratio = 1.0,
    opacity = 0.90,
    color = beautiful.bg_modal,
    widget = wibox.widget.separator
  }

  body =
    scrollbar(
    wibox.widget {
      separator,
      {
        expand = "none",
        layout = wibox.layout.align.horizontal,
        {
          nil,
          layout = wibox.layout.fixed.horizontal
        },
        require("widget.notification-center.subwidgets.panel-mode-switcher"),
        {
          nil,
          layout = wibox.layout.fixed.horizontal
        }
      },
      separator,
      headerSeparator,
      {
        layout = wibox.layout.stack,
        -- Notification Center
        notification_widget,
        -- Widget Center
        widgets
      },
      layout = wibox.layout.fixed.vertical
    }
  )

  panel:setup {
    expand = "none",
    layout = wibox.layout.fixed.vertical,
    body
  }

  return panel
end

return right_panel
