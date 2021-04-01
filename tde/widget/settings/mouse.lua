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
local icons = require("theme.icons")
local mouse = require("lib-tde.mouse")
local slider = require("lib-widget.slider")
local card = require("lib-widget.card")
local checkbox = require("lib-widget.checkbox")
local scrollbox = require("lib-widget.scrollbox")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local scrollbox_body

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
    local mouse_card = card()

    local mouse_heading = wibox.widget.textbox(name)
    mouse_heading.font = beautiful.font

    local mouse_slider =
      slider(
      0.05,
      10,
      0.05,
      default_value,
      function(value)
        mouse.setMouseSpeed(id, value)
      end
    )

    local mouse_accel_slider =
      slider(
      0.01,
      1,
      0.01,
      default_accel_value,
      function(value)
        mouse.setAcceleration(id, value)
      end
    )

    local natural_scrolling_checkbox =
      checkbox(
      natural_scrolling or false,
      function(checked)
        mouse.setNaturalScrolling(id, checked == true)
      end,
      settings_index
    )

    mouse_card.update_body(
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
    )
    return mouse_card
  end

  local layout = wibox.layout.flex.vertical()
  layout.spacing = m
  scrollbox_body = scrollbox(layout)

  view.refresh = function()
    -- reset the layout of all mice
    layout:reset()
    scrollbox_body.reset()
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
      scrollbox_body
    }
  }

  return view
end
