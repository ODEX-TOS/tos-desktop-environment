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
local scrollbar = require("widget.scrollbar")

local apps = require("configuration.apps")
local dpi = require("beautiful").xresources.apply_dpi
local mat_list_item = require("widget.material.list-item")
local mat_icon = require("widget.material.icon")

-- body gets populated with a scrollbar widget once generated
local body = {}

local plugins = require("lib-tde.plugin-loader")("settings")

local left_panel_func = function(screen)
  -- set the panel width equal to the rofi settings
  -- the rofi width is defined in configuration/rofi/sidebar/rofi.rasi
  -- under the section window-> width
  local left_panel_width = dpi(450)

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

  local left_panel =
    wibox {
    ontop = true,
    screen = screen,
    width = left_panel_width,
    height = screen.geometry.height,
    x = 0,
    bg = beautiful.background.hue_800,
    fg = beautiful.fg_normal
  }

  left_panel.opened = false
  local grabber

  local openleft_panel = function()
    backdrop.visible = true
    left_panel.visible = true
    if grabber then
      grabber:start()
    end
    left_panel:emit_signal("opened")
  end

  local closeleft_panel = function()
    left_panel.visible = false
    backdrop.visible = false

    -- Change to notif mode on close
    if grabber then
      grabber:stop()
    end
    left_panel:emit_signal("closed")

    -- reset the scrollbar
    body:reset()
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
    forced_height = dpi(12),
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
    forced_height = dpi(12),
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
    forced_height = dpi(12),
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

  local exit_button =
    wibox.widget {
    wibox.widget {
      icon = icons.logout,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      text = i18n.translate("End work session"),
      font = "Iosevka Regular 12",
      widget = wibox.widget.textbox
    },
    clickable = true,
    divider = false,
    widget = mat_list_item
  }

  exit_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          left_panel:toggle()
          _G.exit_screen_show()
        end
      )
    )
  )

  local separator =
    wibox.widget {
    orientation = "vertical",
    forced_height = 10,
    opacity = 0.00,
    widget = wibox.widget.separator
  }

  local topSeparator =
    wibox.widget {
    orientation = "horizontal",
    forced_height = 20,
    opacity = 0,
    widget = wibox.widget.separator
  }

  local bottomSeparator =
    wibox.widget {
    orientation = "horizontal",
    forced_height = 5,
    opacity = 0,
    widget = wibox.widget.separator
  }

  local function settings_plugin()
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
      require("widget.control-center.dashboard.hardware-monitor")(screen),
      require("widget.control-center.dashboard.action-center"),
      separator,
      {
        wibox.widget {
          text = i18n.translate("Network Settings"),
          font = "Iosevka Regular 10",
          align = "left",
          widget = wibox.widget.textbox
        },
        widget = mat_list_item
      },
      {
        wibox.widget {
          wifi_button,
          bg = beautiful.bg_modal, --beautiful.background.hue_800,
          shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 28)
          end,
          widget = wibox.container.background
        },
        widget = mat_list_item
      },
      separator,
      {
        wibox.widget {
          text = i18n.translate("Screen Settings"),
          font = "Iosevka Regular 10",
          align = "left",
          widget = wibox.widget.textbox
        },
        widget = mat_list_item
      },
      layout = wibox.layout.fixed.vertical,
      {
        wibox.widget {
          dpi_button,
          bg = beautiful.bg_modal, --beautiful.background.hue_800,
          shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 28)
          end,
          widget = wibox.container.background
        },
        widget = mat_list_item
      },
      separator,
      {
        wibox.widget {
          text = i18n.translate("Settings application"),
          font = "Iosevka Regular 10",
          align = "left",
          widget = wibox.widget.textbox
        },
        widget = mat_list_item
      },
      {
        wibox.widget {
          settings_app_button,
          bg = beautiful.bg_modal, --beautiful.background.hue_800,
          shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 28)
          end,
          widget = wibox.container.background
        },
        widget = mat_list_item
      }
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
    scrollbar(
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
