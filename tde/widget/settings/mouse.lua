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
local beautiful = require("beautiful")
local mouse = require("lib-tde.mouse")
local slider = require("lib-widget.slider")
local card = require("lib-widget.card")
local checkbox = require("lib-widget.checkbox")
local scrollbox = require("lib-widget.scrollbox")

local configWriter = require("lib-tde.config-writer")
local generalConfigFile = os.getenv("HOME") .. "/.config/tos/general.conf"

local dpi = beautiful.xresources.apply_dpi

local size = require("widget.settings.size")
local m = size.m


local settings_index = size.settings_index


local scrollbox_body

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Mouse Settings"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local __mouse_cache = {}
  local __general_cache

  local function make_general_settings()
    if __general_cache then
      return __general_cache
    end

    __general_cache= card({
      title = "General"
    })

    local swipe_event_checkbox = checkbox({
      checked = general["swipe_event_type"] == "new" or general["swipe_event_type"] == nil,
      callback = function(checked)
       if checked then
        general["swipe_event_type"] = "new"
       else
        general["swipe_event_type"] = "old"
       end

       configWriter.update_entry(generalConfigFile, "swipe_event_type", general["swipe_event_type"])
      end,
      size = settings_index
    })

    local swipe_event_type = wibox.widget {
      layout = wibox.layout.align.horizontal,
      wibox.widget.textbox(i18n.translate("Swipe Event Type")),
      nil,
      swipe_event_checkbox
    }

    __general_cache.update_body(
      wibox.container.margin(
        wibox.widget {
          layout = wibox.layout.fixed.vertical,
          spacing = m/2,
          swipe_event_type
        },
        m,m,m,m
      )
    )


    return __general_cache
  end

  local function make_mouse(id, name, default_value, default_accel_value, natural_scrolling)

    if __mouse_cache[id] ~= nil then
      __mouse_cache[id].set_speed(default_value)
      __mouse_cache[id].set_accel(default_accel_value)
      __mouse_cache[id].set_natural_scrolling(natural_scrolling)
      return __mouse_cache[id]
    end

    local mouse_card = card()

    local mouse_heading = wibox.widget.textbox(name)
    mouse_heading.font = beautiful.font

    local mouse_slider =
      slider({
        min = 0.05,
        max = 10,
        increment = 0.05,
        default = default_value,
        callback = function(value)
          mouse.setMouseSpeed(id, value)
        end
      })

    local mouse_accel_slider =
      slider({
        min = 0.01,
        max = 1,
        increment = 0.01,
        default = default_accel_value,
        callback = function(value)
          mouse.setAcceleration(id, value)
        end
      })

    local natural_scrolling_checkbox =
      checkbox({
        checked = natural_scrolling or false,
        callback = function(checked)
          mouse.setNaturalScrolling(id, checked == true)
        end,
        size = settings_index
      })

    mouse_card.set_speed = function(val)
      mouse_slider.update(val)
    end

    mouse_card.set_accel = function(val)
      mouse_accel_slider.update(val)
    end

    mouse_card.set_natural_scrolling = function(val)
      natural_scrolling_checkbox.update(val)
    end

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

    __mouse_cache[id] = mouse_card

    return mouse_card
  end

  local layout = wibox.layout.flex.vertical()
  layout.spacing = m
  scrollbox_body = scrollbox(layout)

  view.refresh = function()
    -- reset the layout of all mice
    layout:reset()
    scrollbox_body.reset()

    layout:add(make_general_settings())

    mouse.getInputDevices(function(devices)
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
    end)
  end

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      spacing = m,
      scrollbox_body
    }
  }

  return view
end
