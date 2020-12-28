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

  local function make_mouse(id, name, default_value)
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

    -- TODO: set the correct value
    mouse_slider:set_value((default_value * 100) or 1)

    mouse_slider:connect_signal(
      "property::value",
      function()
        mouse.setMouseSpeed(id, mouse_slider.value / 100)
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
          layout = wibox.container.margin,
          left = m,
          right = m,
          bottom = m,
          forced_height = dpi(30) + (m * 2),
          mouse_slider
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
      if _G.save_state.mouse ~= nil and _G.save_state.mouse[device.name] ~= nil then
        speed = _G.save_state.mouse[device.name].speed or 1
      end
      print("Setting the default value of the mouse to: " .. speed)
      layout:add(make_mouse(device.id, device.name, speed))
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
