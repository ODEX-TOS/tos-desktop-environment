local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local configWriter = require("lib-tde.config-writer")
local configFile = os.getenv("HOME") .. "/.config/tos/general.conf"
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")

local m = dpi(10)
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
  local tooltip_widget =
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

  local tooltip_widget =
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
      value = off or "0"
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

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox("General")
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
    wibox.container.margin(wibox.widget.textbox("Update"), m, m, m / 2, m / 2)
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

  local separator =
    wibox.widget {
    widget = wibox.widget.separator,
    forced_height = settings_index / 1.5
  }

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
      {
        layout = wibox.layout.flex.vertical,
        create_checkbox(
          "Audio popup",
          "Enable the 'pop' sound when changing the audio",
          general["audio_change_sound"] == "1",
          "audio_change_sound"
        ),
        create_checkbox(
          "Error data opt out",
          "Send error messages to the developers, this is useful for debugging and reducing errors/bugs",
          general["tde_opt_out"] == "1",
          "tde_opt_out"
        ),
        create_checkbox(
          "Break timer",
          "A break timer gets triggered every hour, this is intended to give you some time to stretch, take a break etc",
          general["break"] == "1",
          "break"
        ),
        create_checkbox(
          "Titlebar drawing",
          "Draw the titlebar above every application",
          general["draw_mode"] == "fast",
          "draw_mode",
          "fast",
          "none"
        ),
        create_checkbox(
          "Screen timeout",
          "Put the system in sleep mode after a period of inactivity",
          general["screen_timeout"] == "1" or general["screen_timeout"] == nil,
          "screen_timeout"
        ),
        create_checkbox(
          "Disable Desktop",
          "When enabled we don't draw icons or anything on the desktop",
          general["disable_desktop"] == "1",
          "disable_desktop"
        )
      },
      separator,
      create_multi_option_array(
        "Tagbar anchor location",
        "The location where you want the tagbar to appear (default bottom)",
        {"bottom", "right", "left"},
        general["tag_bar_anchor"] or "bottom",
        "tag_bar_anchor"
      ),
      create_multi_option_array(
        "Tagbar bar draw location",
        "Draw the tagbar either on all screens, the main screen or don't draw it at all",
        {"all", "main", "none"},
        general["tag_bar_draw"] or "all",
        "tag_bar_draw"
      ),
      create_multi_option_array(
        "Topbar draw location",
        "Draw the topbar either on all screens, the main screen or don't draw it at all",
        {"all", "main", "none"},
        general["top_bar_draw"] or "all",
        "top_bar_draw"
      ),
      create_multi_option_array(
        "Window screenshot mode",
        "when making a screenshot of a window, you can either show the screenshot or make a pretty version with some shadows, and your theme color",
        {"shadow", "none"},
        general["window_screen_mode"] or "shadow",
        "window_screen_mode"
      ),
      separator,
      wibox.container.margin(save, m, m, m, m)
    }
  }

  return view
end
