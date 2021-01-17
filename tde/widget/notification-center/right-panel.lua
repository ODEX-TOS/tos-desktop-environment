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
local signals = require("lib-tde.signals")
local animate = require("lib-tde.animations").createAnimObject
local seperator_widget = require("lib-widget.separator")

local keyconfig = require("configuration.keys.mod")
local modKey = keyconfig.modKey

local scrollbox = require("lib-widget.scrollbox")

-- load the notification plugins
local plugins = require("lib-tde.plugin-loader")("notification")

-- body gets populated with a scrollbox widget once generated
local body = {}

local function notification_plugin()
  local separator = seperator_widget(16, "vertical", 0)

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

  for _, value in ipairs(plugins) do
    table_widget:add(
      {
        wibox.container.margin(value, dpi(15), dpi(15), dpi(0), dpi(10)),
        layout = wibox.layout.fixed.vertical
      }
    )
  end
  return table
end

local right_panel = function(s)
  local panel_width = dpi(350)

  local backdrop =
    wibox {
    ontop = true,
    screen = s,
    bg = "#00000000",
    type = "dock",
    x = s.geometry.x,
    y = s.geometry.y,
    width = s.geometry.width,
    height = s.geometry.height
  }
  local panel =
    wibox {
    ontop = true,
    screen = s,
    width = panel_width,
    height = s.geometry.height,
    x = s.geometry.width - panel_width,
    bg = beautiful.background.hue_800,
    fg = beautiful.fg_normal
  }

  signals.connect_background_theme_changed(
    function(theme)
      panel.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )

  screen.connect_signal(
    "removed",
    function(removed)
      if s == removed then
        panel.visible = false
        panel = nil

        backdrop.visible = false
        backdrop = nil
      end
    end
  )

  -- this is called when we need to update the screen
  signals.connect_refresh_screen(
    function()
      print("Refreshing action center")

      if panel == nil then
        return
      end

      -- the action center itself
      panel.x = s.geometry.width - panel_width
      panel.width = panel_width
      panel.height = s.geometry.height

      -- the backdrop
      backdrop.x = s.geometry.x
      backdrop.y = s.geometry.y
      backdrop.width = s.geometry.width
      backdrop.height = s.geometry.height
    end
  )

  panel.opened = false

  panel:struts(
    {
      right = 0
    }
  )

  local separator = seperator_widget(15, "horizontal", 0)

  local clear_all_text =
    wibox.widget {
    text = i18n.translate("Clear All Notifications"),
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
          _G.notification_clear_all()
          _G.notification_firstime = true
        end
      )
    )
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

  local grabber

  local openPanel = function()
    backdrop.visible = true
    panel.visible = true
    if grabber then
      grabber:start()
    end
    panel:emit_signal("opened")

    -- start the animations
    panel.x = s.geometry.width
    panel.opacity = 0
    animate(_G.anim_speed, panel, {opacity = 1, x = s.geometry.width - panel_width}, "outCubic")
  end

  local closePanel = function()
    -- start the animations
    panel.x = s.geometry.width - panel_width
    panel.opacity = 1
    backdrop.visible = false

    animate(
      _G.anim_speed,
      panel,
      {opacity = 0, x = s.geometry.width},
      "outCubic",
      function()
        panel.visible = false
        if grabber then
          grabber:stop()
        end
        panel:emit_signal("closed")
        -- reset the scrollbox
        body:reset()
      end
    )
  end

  grabber =
    awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          panel.opened = false
          closePanel()
        end
      },
      awful.key {
        modifiers = {modKey},
        key = keyconfig.notificationPanel,
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

  local widgets = notification_plugin()
  -- returns the state of the widgets
  -- first tuple element returns the notification section (type wibox.widget)
  -- the second tuple element returns the widget section (type wibox.widget)
  -- if no element is supplied it should return the current unmodified state
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
    return notification_widget, widgets
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
    scrollbox(
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
