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
local icons = require("theme.icons")
local mouse = require("lib-tde.mouse")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Mouse Settings"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local close = wibox.widget.imagebox(icons.close)
  close.forced_height = dpi(30)
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

  local function make_mouse(id, name, default_value, default_accel_value, natural_scrolling)
    local mouse_heading = wibox.widget.textbox(name)
    mouse_heading.font = beautiful.font

    local mouse_slider = wibox.widget.slider()
    mouse_slider.bar_shape = function(c, w, h)
      gears.shape.rounded_rect(c, w, h, dpi(30) / 2)
    end
    mouse_slider.bar_height = dpi(30)
    mouse_slider.bar_color = beautiful.bg_modal
    mouse_slider.bar_active_color = beautiful.accent.hue_500
    mouse_slider.handle_shape = gears.shape.circle
    mouse_slider.handle_width = dpi(35)
    mouse_slider.handle_color = beautiful.accent.hue_500
    mouse_slider.handle_border_width = 1
    mouse_slider.handle_border_color = "#00000012"
    mouse_slider.minimum = 5
    mouse_slider.maximum = 1000

    mouse_slider:set_value((default_value * 100) or 1)

    mouse_slider:connect_signal(
      "property::value",
      function()
        mouse.setMouseSpeed(id, mouse_slider.value / 100)
      end
    )

    local mouse_accel_slider = wibox.widget.slider()
    mouse_accel_slider.bar_shape = function(c, w, h)
      gears.shape.rounded_rect(c, w, h, dpi(30) / 2)
    end
    mouse_accel_slider.bar_height = dpi(30)
    mouse_accel_slider.bar_color = beautiful.bg_modal
    mouse_accel_slider.bar_active_color = beautiful.accent.hue_500
    mouse_accel_slider.handle_shape = gears.shape.circle
    mouse_accel_slider.handle_width = dpi(35)
    mouse_accel_slider.handle_color = beautiful.accent.hue_500
    mouse_accel_slider.handle_border_width = 1
    mouse_accel_slider.handle_border_color = "#00000012"
    mouse_accel_slider.minimum = 1
    mouse_accel_slider.maximum = 100

    mouse_accel_slider:set_value((default_accel_value * 100) or 1)

    mouse_accel_slider:connect_signal(
      "property::value",
      function()
        mouse.setAccellaration(id, mouse_accel_slider.value / 100)
      end
    )

    local natural_scrolling_checkbox =
      wibox.widget {
      checked = natural_scrolling or false,
      color = beautiful.accent.hue_700,
      paddings = dpi(2),
      check_border_color = beautiful.accent.hue_600,
      check_color = beautiful.accent.hue_600,
      check_border_width = dpi(2),
      shape = gears.shape.circle,
      forced_height = settings_index,
      widget = wibox.widget.checkbox
    }

    natural_scrolling_checkbox:connect_signal(
      "button::press",
      function()
        print("Pressed")
        natural_scrolling_checkbox.checked = not natural_scrolling_checkbox.checked
        -- the checked property can also contain a nil value
        mouse.setNaturalScrolling(id, natural_scrolling_checkbox.checked == true)
      end
    )
    natural_scrolling_checkbox:connect_signal(
      "mouse::enter",
      function()
        if natural_scrolling_checkbox.checked then
          natural_scrolling_checkbox.check_color = beautiful.accent.hue_700
        end
      end
    )
    natural_scrolling_checkbox:connect_signal(
      "mouse::leave",
      function()
        if natural_scrolling_checkbox.checked then
          natural_scrolling_checkbox.check_color = beautiful.accent.hue_600
        end
      end
    )

    return wibox.widget {
      layout = wibox.container.background,
      bg = beautiful.bg_modal,
      shape = rounded(),
      wibox.widget {
        layout = wibox.layout.fixed.vertical,
        {
          layout = wibox.container.margin,
          margins = m,
          {
            layout = wibox.layout.align.horizontal,
            mouse_heading,
            nil,
            nil
          }
        },
        {
          layout = wibox.layout.fixed.vertical,
          {
            layout = wibox.container.margin,
            left = m,
            right = m,
            bottom = m,
            forced_height = dpi(30) + (m * 2),
            {
              layout = wibox.layout.align.horizontal,
              wibox.container.margin(wibox.widget.textbox(i18n.translate("Mouse Speed")), 0, m),
              mouse_slider
            }
          },
          {
            layout = wibox.container.margin,
            left = m,
            right = m,
            bottom = m,
            forced_height = dpi(30) + (m * 2),
            {
              layout = wibox.layout.align.horizontal,
              wibox.container.margin(wibox.widget.textbox(i18n.translate("Mouse Acceleration")), 0, m),
              mouse_accel_slider
            }
          },
          {
            layout = wibox.container.margin,
            left = m,
            right = m,
            bottom = m,
            forced_height = dpi(30) + (m * 2),
            {
              layout = wibox.layout.align.horizontal,
              wibox.container.margin(wibox.widget.textbox(i18n.translate("Natural Scrolling")), 0, m),
              nil,
              natural_scrolling_checkbox
            }
          }
        }
      }
    }
  end

  local layout = wibox.layout.flex.vertical()
  layout.spacing = m

  view.refresh = function()
    -- reset the layout of all mice
    layout:reset()
    local devices = mouse.getInputDevices()
    for _, device in ipairs(devices) do
      -- find the speed of the mouse
      local speed = 1
      local accel_speed = 0
      local natural_scrolling = false

      if _G.save_state.mouse ~= nil and _G.save_state.mouse[device.name] ~= nil then
        speed = _G.save_state.mouse[device.name].speed or 1
        accel_speed = _G.save_state.mouse[device.name].accel or 0
        natural_scrolling = _G.save_state.mouse[device.name].natural_scroll or false
      end
      print("Setting the default value of the mouse to: " .. speed)
      layout:add(make_mouse(device.id, device.name, speed, accel_speed, natural_scrolling))
    end
  end

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      spacing = m,
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
      layout
    }
  }

  return view
end
