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
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local configWriter = require("lib-tde.config-writer")
local configFile = os.getenv("HOME") .. "/.config/tos/general.conf"
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")
local slider = require("lib-widget.slider")
local seperator_widget = require("lib-widget.separator")
local card = require("lib-widget.card")

local m = dpi(5)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

local button_widgets = {}

local function create_multi_option_array(name, tooltip, options, default, configOption)
  local name_widget =
    wibox.widget {
    text = name,
    font = beautiful.title_font,
    widget = wibox.widget.textbox
  }
  awful.tooltip {
    objects = {name_widget},
    timer_function = function()
      return tooltip
    end
  }
  local layout = wibox.layout.flex.horizontal()
  layout.forced_width = settings_width - settings_nw
  layout:add(name_widget)
  button_widgets[name] = {}
  for _, option in ipairs(options) do
    local option_widget = wibox.container.background()
    option_widget.bg = beautiful.bg_modal
    option_widget.shape = rounded()
    option_widget.forced_height = settings_index

    option_widget:setup {
      layout = wibox.container.place,
      halign = "center",
      wibox.widget.textbox(option)
    }

    if option == default then
      option_widget.bg = beautiful.accent.hue_700
      option_widget.active = true
    end

    option_widget:connect_signal(
      "mouse::enter",
      function()
        if button_widgets[name][option].active then
          button_widgets[name][option].bg = beautiful.accent.hue_600
        else
          button_widgets[name][option].bg = beautiful.bg_modal_title
        end
      end
    )
    option_widget:connect_signal(
      "mouse::leave",
      function()
        if button_widgets[name][option].active then
          button_widgets[name][option].bg = beautiful.accent.hue_700
        else
          button_widgets[name][option].bg = beautiful.bg_modal
        end
      end
    )

    option_widget:connect_signal(
      "button::press",
      function()
        print("Pressed button")
        for _, widget in pairs(button_widgets[name]) do
          widget.bg = beautiful.bg_modal
          widget.active = false
        end
        option_widget.bg = beautiful.accent.hue_600
        option_widget.active = true
        configWriter.update_entry(configFile, configOption, option)
      end
    )

    button_widgets[name][option] = option_widget
    layout:add(wibox.container.margin(option_widget, m, m, m, m))
  end
  return layout
end

local function create_checkbox(name, tooltip, checked, configOption, on, off)
  local name_widget =
    wibox.widget {
    text = name,
    font = beautiful.title_font,
    widget = wibox.widget.textbox
  }
  local checkbox =
    wibox.widget {
    checked = checked,
    color = beautiful.accent.hue_700,
    paddings = dpi(2),
    check_border_color = beautiful.accent.hue_600,
    check_color = beautiful.accent.hue_600,
    check_border_width = dpi(2),
    shape = gears.shape.circle,
    forced_height = settings_index,
    widget = wibox.widget.checkbox
  }

  awful.tooltip {
    objects = {name_widget},
    timer_function = function()
      return tooltip
    end
  }

  checkbox:connect_signal(
    "button::press",
    function()
      print("Pressed")
      checkbox.checked = not checkbox.checked
      local value = off or "0"
      if checkbox.checked then
        value = on or "1"
      end
      configWriter.update_entry(configFile, configOption, value)
    end
  )
  checkbox:connect_signal(
    "mouse::enter",
    function()
      if checkbox.checked then
        checkbox.check_color = beautiful.accent.hue_700
      end
    end
  )
  checkbox:connect_signal(
    "mouse::leave",
    function()
      if checkbox.checked then
        checkbox.check_color = beautiful.accent.hue_600
      end
    end
  )

  return wibox.container.margin(
    wibox.widget {
      layout = wibox.layout.align.horizontal,
      wibox.container.margin(name_widget, m),
      nil,
      wibox.container.margin(checkbox, 0, m)
    },
    m,
    m,
    m,
    m
  )
end

local function create_option_slider(title, min, max, inc, option, start_value)
  local option_slider =
    slider(
    min,
    max,
    inc,
    start_value,
    function(value)
      _G.update_anim_speed(value)
      configWriter.update_entry(configFile, option, tostring(value))
    end
  )

  return wibox.widget {
    layout = wibox.layout.align.horizontal,
    wibox.container.margin(wibox.widget.textbox(title), 0, m),
    option_slider,
    forced_height = dpi(40)
  }
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("General"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local close = wibox.widget.imagebox(icons.close)
  close.forced_height = settings_index
  close:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          if root.elements.settings then
            root.elements.settings.close()
          end
        end
      )
    )
  )

  local save = wibox.container.background()
  save.bg = beautiful.accent.hue_500
  save.shape = rounded()
  save:connect_signal(
    "mouse::enter",
    function()
      save.bg = beautiful.accent.hue_600
    end
  )
  save:connect_signal(
    "mouse::leave",
    function()
      save.bg = beautiful.accent.hue_500
    end
  )
  save:setup {
    layout = wibox.container.place,
    halign = "center",
    wibox.container.margin(wibox.widget.textbox(i18n.translate("Update")), m * 2, m * 2, m * 2, m * 2)
  }
  save:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          print("Saving general settings")
          -- reload TDE
          awesome.restart()
        end
      )
    )
  )

  local separator = seperator_widget(settings_index / 1.5)

  local checkbox_widget =
    wibox.widget {
    layout = wibox.layout.flex.vertical,
    create_checkbox(
      i18n.translate("Audio popup"),
      i18n.translate("Enable the 'pop' sound when changing the audio"),
      general["audio_change_sound"] == "1",
      "audio_change_sound"
    ),
    create_checkbox(
      i18n.translate("Error data opt out"),
      i18n.translate("Send error messages to the developers, this is useful for debugging and reducing errors/bugs"),
      general["tde_opt_out"] == "1",
      "tde_opt_out"
    ),
    create_checkbox(
      i18n.translate("Break timer"),
      i18n.translate(
        "A break timer gets triggered every hour, this is intended to give you some time to stretch, take a break etc"
      ),
      general["break"] == "1",
      "break"
    ),
    create_checkbox(
      i18n.translate("Titlebar drawing"),
      i18n.translate("Draw the titlebar above every application"),
      general["draw_mode"] == "fast",
      "draw_mode",
      "fast",
      "none"
    ),
    create_checkbox(
      i18n.translate("Screen timeout"),
      i18n.translate("Put the system in sleep mode after a period of inactivity"),
      general["screen_timeout"] == "1" or general["screen_timeout"] == nil,
      "screen_timeout"
    ),
    create_checkbox(
      i18n.translate("Disable Desktop"),
      i18n.translate("When enabled we don't draw icons or anything on the desktop"),
      general["disable_desktop"] == "1",
      "disable_desktop"
    ),
    create_checkbox(
      i18n.translate("Weak Hardware"),
      i18n.translate("Disable a lot of the 'nice' features in order to reduce hardware consumption"),
      general["weak_hardware"] == "1",
      "weak_hardware"
    ),
    create_checkbox(
      i18n.translate("Autofocus"),
      i18n.translate("Automatically make the focus follow the mouse without clicking"),
      general["autofocus"] == "1",
      "autofocus"
    )
  }

  local multi_option_widget =
    wibox.widget {
    create_multi_option_array(
      i18n.translate("Tagbar anchor location"),
      i18n.translate("The location where you want the tagbar to appear (default bottom)"),
      {"bottom", "right", "left"},
      general["tag_bar_anchor"] or "bottom",
      "tag_bar_anchor"
    ),
    create_multi_option_array(
      i18n.translate("Tagbar bar draw location"),
      i18n.translate("Draw the tagbar either on all screens, the main screen or don't draw it at all"),
      {"all", "main", "none"},
      general["tag_bar_draw"] or "all",
      "tag_bar_draw"
    ),
    create_multi_option_array(
      i18n.translate("Topbar draw location"),
      i18n.translate("Draw the topbar either on all screens, the main screen or don't draw it at all"),
      {"all", "main", "none"},
      general["top_bar_draw"] or "all",
      "top_bar_draw"
    ),
    create_multi_option_array(
      i18n.translate("Window screenshot mode"),
      i18n.translate(
        "when making a screenshot of a window, you can either show the screenshot or make a pretty version with some shadows, and your theme color"
      ),
      {"shadow", "none"},
      general["window_screen_mode"] or "shadow",
      "window_screen_mode"
    ),
    layout = wibox.layout.flex.vertical
  }

  local slider_widget =
    wibox.widget {
    create_option_slider(
      i18n.translate("Animation Speed"),
      0,
      1.5,
      0.05,
      "animation_speed",
      tonumber(general["window_screen_mode"]) or _G.anim_speed
    ),
    layout = wibox.layout.flex.vertical
  }

  local checkbox_card = card()
  checkbox_card.update_body(wibox.container.margin(checkbox_widget, dpi(10), dpi(10), dpi(3), dpi(3)))

  local multi_option_card = card()
  multi_option_card.update_body(wibox.container.margin(multi_option_widget, dpi(10), dpi(10), dpi(3), dpi(3)))

  local slider_card = card()
  slider_card.update_body(wibox.container.margin(slider_widget, dpi(10), dpi(10), dpi(3), dpi(3)))

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        wibox.container.margin(
          {
            layout = wibox.container.place,
            title
          },
          settings_index * 2
        ),
        close
      },
      separator,
      wibox.container.margin(checkbox_card, dpi(10), dpi(10)),
      separator,
      wibox.container.margin(multi_option_card, dpi(10), dpi(10)),
      separator,
      wibox.container.margin(slider_card, dpi(10), dpi(10)),
      separator,
      wibox.container.margin(save, m, m, m, m)
    }
  }

  return view
end
