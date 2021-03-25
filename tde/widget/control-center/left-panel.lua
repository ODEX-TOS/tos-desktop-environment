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
local icons = require("theme.icons")
local scrollbox = require("lib-widget.scrollbox")

local apps = require("configuration.apps")
local dpi = require("beautiful").xresources.apply_dpi
local mat_list_item = require("widget.material.list-item")
local mat_icon = require("widget.material.icon")
local signals = require("lib-tde.signals")
local animate = require("lib-tde.animations").createAnimObject
local seperator_widget = require("lib-widget.separator")
local card = require("lib-widget.card")
local button = require("lib-widget.button")

local keyconfig = require("configuration.keys.mod")
local modKey = keyconfig.modKey

-- body gets populated with a scrollbox widget once generated
local body = {}

local plugins = require("lib-tde.plugin-loader")("settings")

local left_panel_func = function(s)
  -- set the panel width equal to the rofi settings
  -- the rofi width is defined in configuration/rofi/sidebar/rofi.rasi
  -- under the section window-> width
  local left_panel_width = dpi(450)

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

  local left_panel =
    wibox {
    ontop = true,
    screen = s,
    width = left_panel_width,
    height = s.geometry.height,
    x = s.geometry.x,
    y = s.geometry.y,
    bg = beautiful.background.hue_800,
    fg = beautiful.fg_normal
  }

  signals.connect_background_theme_changed(
    function(theme)
      left_panel.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )

  screen.connect_signal(
    "removed",
    function(removed)
      if s == removed then
        left_panel.visible = false
        left_panel = nil
        backdrop.visible = false
        backdrop = nil
      end
    end
  )

  -- this is called when we need to update the screen
  signals.connect_refresh_screen(
    function()
      print("Refreshing action center")

      if left_panel == nil then
        return
      end

      -- the action center itself
      left_panel.x = 0
      left_panel.width = left_panel_width
      left_panel.height = s.geometry.height

      -- the backdrop
      backdrop.x = s.geometry.x
      backdrop.y = s.geometry.y
      backdrop.width = s.geometry.width
      backdrop.height = s.geometry.height
    end
  )

  left_panel.opened = false
  local grabber

  local openleft_panel = function()
    backdrop.visible = true
    left_panel.visible = true
    if grabber then
      grabber:start()
    end
    left_panel:emit_signal("opened")

    -- start the animations
    left_panel.x = s.geometry.x - left_panel_width
    left_panel.opacity = 0
    animate(_G.anim_speed, left_panel, {opacity = 1, x = s.geometry.x}, "outCubic")
  end

  local closeleft_panel = function()
    -- start the animations
    left_panel.x = s.geometry.x
    left_panel.opacity = 1
    backdrop.visible = false
    animate(
      _G.anim_speed,
      left_panel,
      {opacity = 0, x = s.geometry.x - left_panel_width},
      "outCubic",
      function()
        left_panel.visible = false

        -- Change to notify mode on close
        if grabber then
          grabber:stop()
        end
        left_panel:emit_signal("closed")

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
          left_panel.opened = false
          closeleft_panel()
        end
      },
      awful.key {
        modifiers = {modKey},
        key = keyconfig.configPanel,
        on_press = function()
          left_panel.opened = false
          closeleft_panel()
        end
      }
    },
    -- Note that it is using the key name and not the modifier name.
    stop_key = "Escape",
    stop_event = "release"
  }

  left_panel:struts(
    {
      left = 0
    }
  )

  local action_grabber =
    awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          left_panel:close()
        end
      }
    },
    -- Note that it is using the key name and not the modifier name.
    stop_key = "Escape",
    stop_event = "release"
  }

  -- Hide this left_panel when app dashboard is called.
  function left_panel:HideDashboard()
    closeleft_panel()
  end

  function left_panel:toggle()
    self.opened = not self.opened
    if self.opened then
      openleft_panel()
    else
      closeleft_panel()
    end
  end

  function left_panel:run_rofi()
    action_grabber:stop()
    _G.awesome.spawn(
      apps.default.web,
      false,
      false,
      false,
      false,
      function()
        left_panel:toggle()
      end
    )
  end

  function left_panel:run_dpi()
    action_grabber:stop()
    _G.awesome.spawn(
      apps.default.rofidpimenu,
      false,
      false,
      false,
      false,
      function()
        left_panel:toggle()
      end
    )
  end

  function left_panel:run_wifi()
    action_grabber:stop()
    _G.awesome.spawn(
      apps.default.rofiwifimenu,
      false,
      false,
      false,
      false,
      function()
        left_panel:toggle()
      end
    )
  end

  backdrop:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          left_panel:toggle()
        end
      )
    )
  )

  local search_button =
    wibox.widget {
    wibox.widget {
      icon = icons.search,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      text = i18n.translate("Global search"),
      font = "Iosevka Regular 12",
      widget = wibox.widget.textbox,
      align = center
    },
    forced_height = dpi(12),
    clickable = true,
    widget = mat_list_item
  }

  search_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          left_panel:run_rofi()
        end
      )
    )
  )
  local dpi_button =
    wibox.widget {
    wibox.widget {
      icon = icons.monitor,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      text = i18n.translate("Change Application Scaling"),
      font = "Iosevka Regular 12",
      widget = wibox.widget.textbox,
      align = center
    },
    forced_height = dpi(60),
    clickable = true,
    widget = mat_list_item
  }

  dpi_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          left_panel:run_dpi()
        end
      )
    )
  )

  local settings_app_button =
    wibox.widget {
    wibox.widget {
      icon = icons.settings,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      text = i18n.translate("Full settings application"),
      font = "Iosevka Regular 12",
      widget = wibox.widget.textbox,
      align = center
    },
    forced_height = dpi(60),
    clickable = true,
    widget = mat_list_item
  }

  settings_app_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          closeleft_panel()
          root.elements.settings.enable_view_by_index(4, mouse.screen)
        end
      )
    )
  )

  local wifi_button =
    wibox.widget {
    wibox.widget {
      icon = icons.wifi,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      text = i18n.translate("Connect to a wireless network"),
      font = "Iosevka Regular 12",
      widget = wibox.widget.textbox,
      align = center
    },
    forced_height = dpi(60),
    clickable = true,
    widget = mat_list_item
  }

  wifi_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          left_panel:run_wifi()
        end
      )
    )
  )

  local exit_button_widget = wibox.widget.imagebox(icons.power)
  local exit_button =
    button(
    exit_button_widget,
    function()
      left_panel:toggle()
      action_grabber:stop()
      _G.exit_screen_show()
    end
  )

  local separator = seperator_widget(10, "vertical", 0)

  local topSeparator = seperator_widget(20, "horizontal", 0)

  local bottomSeparator = seperator_widget(5, "horizontal", 0)

  local function settings_plugin()
    local network_card = card("Network Settings")
    local screen_card = card("Screen Settings")
    local settings_card = card("Settings application")

    network_card.update_body(wifi_button)
    screen_card.update_body(dpi_button)
    settings_card.update_body(settings_app_button)

    local table_widget =
      wibox.widget {
      topSeparator,
      {
        wibox.widget {
          search_button,
          bg = beautiful.bg_modal, --beautiful.background.hue_800,
          shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 28)
          end,
          widget = wibox.container.background
        },
        widget = mat_list_item
      },
      separator,
      require("widget.control-center.dashboard.quick-settings"),
      require("widget.control-center.dashboard.hardware-monitor")(s),
      require("widget.control-center.dashboard.action-center"),
      separator,
      wibox.container.margin(network_card, dpi(20), dpi(20), dpi(20), dpi(20)),
      separator,
      wibox.container.margin(screen_card, dpi(20), dpi(20), dpi(20), dpi(20)),
      separator,
      wibox.container.margin(settings_card, dpi(20), dpi(20), dpi(20), dpi(20)),
      layout = wibox.layout.fixed.vertical
    }
    for _, value in ipairs(plugins) do
      table_widget:add(
        {
          wibox.container.margin(value, dpi(15), dpi(15), dpi(15), dpi(15)),
          layout = wibox.container.background
        }
      )
    end
    return table_widget
  end

  body =
    scrollbox(
    wibox.widget {
      layout = wibox.layout.align.vertical,
      separator,
      settings_plugin(),
      wibox.container.margin(
        {
          layout = wibox.layout.fixed.vertical,
          wibox.widget {
            wibox.widget {
              exit_button,
              bg = beautiful.bg_modal,
              --beautiful.background.hue_800,
              widget = wibox.container.background,
              shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, 12)
              end
            },
            widget = mat_list_item
          },
          bottomSeparator
        },
        0,
        0,
        dpi(15),
        dpi(15)
      )
    }
  )

  left_panel:setup {
    expand = "none",
    layout = wibox.layout.fixed.vertical,
    body
  }

  return left_panel
end

return left_panel_func
