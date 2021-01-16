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
local beautiful = require("beautiful")
local wibox = require("wibox")
local TaskList = require("widget.task-list")
local gears = require("gears")
local mat_icon_button = require("widget.material.icon-button")
local mat_icon = require("widget.material.icon")
local hardware = require("lib-tde.hardware-check")
local signals = require("lib-tde.signals")

local dpi = require("beautiful").xresources.apply_dpi

local icons = require("theme.icons")

-- load the topbar plugins
local pluginsright = require("lib-tde.plugin-loader")("topbar-right")
local pluginscenter = require("lib-tde.plugin-loader")("topbar-center")
local pluginsleft = require("lib-tde.plugin-loader")("topbar-left")

-- Clock / Calendar 12h format
local textclock = wibox.widget.textclock('<span font="Roboto bold 10">%l:%M %p</span>')

local weak_hardware = general["weak_hardware"] == "0" or general["weak_hardware"] == nil

-- Clock / Calendar 12AM/PM fornat
-- local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 11">%I\n%M</span>\n<span font="Roboto Mono bold 9">%p</span>')
-- textclock.forced_height = 56
local clock_widget = wibox.container.margin(textclock, dpi(0), dpi(0))

local function rounded_shape(size, partial)
  if partial then
    return function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, true, false, true, 5)
    end
  else
    return function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, size)
    end
  end
end

local function show_widget_or_default(widget, show, require_is_function)
  if show and require_is_function then
    return require(widget)()
  elseif show then
    return require(widget)
  end
  return wibox.widget.base.empty_widget()
end

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one

awful.tooltip(
  {
    objects = {clock_widget},
    mode = "outside",
    align = "right",
    timer_function = function()
      return os.date(i18n.translate("The date today is") .. " %B %d, %Y (%A).")
    end,
    preferred_positions = {"right", "left", "top", "bottom"},
    margin_leftright = dpi(8),
    margin_topbottom = dpi(8)
  }
)

local cal_shape = function(cr, width, height)
  gears.shape.infobubble(cr, width, height, 12)
end

-- Calendar Widget
local month_calendar =
  awful.widget.calendar_popup.month(
  {
    start_sunday = false,
    spacing = 10,
    font = "Iosevka Custom 11",
    long_weekdays = false,
    margin = 5,
    style_month = {border_width = 0, shape = cal_shape, padding = 25},
    style_header = {border_width = 0, bg_color = "#00000000"},
    style_weekday = {border_width = 0, bg_color = "#00000000"},
    style_normal = {border_width = 0, bg_color = "#00000000", shape = rounded_shape(5)},
    style_focus = {
      border_width = 0,
      bg_color = beautiful.primary.hue_500,
      shape = rounded_shape(5)
    }
  }
)
month_calendar:attach(clock_widget, "tc", {on_pressed = true, on_hover = false})

month_calendar:connect_signal(
  "mouse::leave",
  function()
    month_calendar:toggle()
  end
)

awful.screen.connect_for_each_screen(
  function(s)
    s.systray = wibox.widget.systray()
    s.systray.visible = false
    s.systray:set_horizontal(true)
    s.systray:set_base_size(28)
    beautiful.systray_icon_spacing = 24
    s.systray.opacity = 0.3
  end
)
--

--[[
-- Systray Widget
local systray = wibox.widget.systray()
	systray:set_horizontal(true)
	systray:set_base_size(28)
	beautiful.systray_icon_spacing = 24
	opacity = 0
]] local add_button =
  mat_icon_button(mat_icon(icons.plus, dpi(16))) -- add button -- 24
add_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.bottom_right
          }
        )
      end
    )
  )
)

local function topbar_right_plugin(s)
  local table_widget =
    wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    -- System tray and widgets
    --wibox.container.margin(systray, dpi(14), dpi(14)),
    wibox.container.margin(s.systray, dpi(14), dpi(0), dpi(4), dpi(4))
  }

  for _, value in ipairs(pluginsright) do
    table_widget:add(
      {
        value,
        layout = wibox.layout.fixed.vertical
      }
    )
  end
  table_widget:add(show_widget_or_default("widget.battery", hardware.hasBattery(), true))
  table_widget:add(show_widget_or_default("widget.bluetooth", hardware.hasBluetooth()))
  table_widget:add(show_widget_or_default("widget.wifi", hardware.hasWifi()))
  table_widget:add(show_widget_or_default("widget.package-updater", general["minimize_network_usage"] ~= "1"))
  table_widget:add(
    show_widget_or_default(
      "widget.music",
      (hardware.hasSound() and hardware.has_package_installed("playerctl")) or weak_hardware
    )
  ) --only add this when the data can be extracted from spotify
  table_widget:add(require("widget.about"))
  table_widget:add(show_widget_or_default("widget.screen-recorder", hardware.hasFFMPEG() or weak_hardware, true))
  table_widget:add(require("widget.search"))
  table_widget:add(show_widget_or_default("widget.notification-center", weak_hardware))
  return table_widget
end

local function topbar_center_plugin(_)
  local table_widget =
    wibox.widget {
    layout = wibox.layout.fixed.horizontal
  }

  for _, value in ipairs(pluginscenter) do
    table_widget:add(value)
  end
  table_widget:add(clock_widget)
  return table_widget
end

local function topbar_left_plugin(s)
  local table_widget =
    wibox.widget {
    layout = wibox.layout.fixed.horizontal
  }

  table_widget:add(show_widget_or_default("widget.control-center", weak_hardware))
  table_widget:add(TaskList(s))
  table_widget:add(add_button)

  for _, value in ipairs(pluginsleft) do
    table_widget:add(value)
  end

  return table_widget
end

local TopPanel = function(s, offset, controlCenterOnly)
  local offsetx = 0
  if offset == true then
    offsetx = dpi(45) -- 48
  end
  local panel =
    wibox(
    {
      ontop = true,
      screen = s,
      height = dpi(26), -- 48
      width = s.geometry.width - offsetx,
      x = s.geometry.x + offsetx,
      y = s.geometry.y,
      stretch = false,
      bg = beautiful.background.hue_800,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(26) -- 48
      }
    }
  )

  signals.connect_background_theme_changed(
    function(theme)
      panel.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )

  -- this is called when we need to update the screen
  signals.connect_refresh_screen(
    function()
      print("Refreshing top-panel")
      local scrn = panel.screen
      panel.x = scrn.geometry.x + offsetx
      panel.y = scrn.geometry.y
      panel.width = scrn.geometry.width - offsetx
      panel.height = dpi(26)
    end
  )

  panel:struts(
    {
      top = dpi(26) -- 48
    }
  )

  panel:setup {
    expand = "none",
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      -- Create a taglist widget
      topbar_left_plugin(s)
    },
    topbar_center_plugin(s),
    topbar_right_plugin(s)
  }
  if controlCenterOnly then
    return require("widget.control-center")
  end

  return panel
end

return TopPanel
