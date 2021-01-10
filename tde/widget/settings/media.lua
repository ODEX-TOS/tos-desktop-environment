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
local signals = require("lib-tde.signals")
local slider = require("lib-widget.slider")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Media"))
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

  local vol_heading = wibox.widget.textbox(i18n.translate("Volume"))
  vol_heading.font = beautiful.font

  local vol_footer = wibox.widget.textbox(i18n.translate("test"))
  vol_footer.font = beautiful.font
  vol_footer.align = "right"

  local mic_footer = wibox.widget.textbox(i18n.translate("test"))
  mic_footer.font = beautiful.font
  mic_footer.align = "right"

  local vol_slider =
    slider(
    0,
    100,
    1,
    0,
    function(value)
      signals.emit_volume(value)
    end
  )

  signals.connect_volume(
    function(value)
      local number = tonumber(value)
      if not (number == vol_slider.value) then
        vol_slider.update(tonumber(value) or 0)
      end
    end
  )

  view.refresh = function()
    awful.spawn.easy_async_with_shell(
      'pactl list sinks | grep "Active Port:" | awk \'{print $3}\'',
      function(o)
        if o then
          vol_footer.markup =
            'Output: <span font="' .. beautiful.font .. '">' .. o:gsub("^%s*(.-)%s*$", "%1") .. "</span>"
        end
      end
    )

    awful.spawn.easy_async_with_shell(
      'pactl list sources | grep "Active Port:" | awk \'{print $3}\'',
      function(o, _)
        if o then
          mic_footer.markup =
            'Input: <span font="' .. beautiful.font .. '">' .. o:gsub("^%s*(.-)%s*$", "%1") .. "</span>"
        end
      end
    )
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
      {
        layout = wibox.container.background,
        bg = beautiful.bg_modal,
        shape = rounded(),
        {
          layout = wibox.layout.fixed.vertical,
          {
            layout = wibox.container.margin,
            margins = m,
            {
              layout = wibox.layout.align.horizontal,
              vol_heading,
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
            vol_slider
          },
          {
            layout = wibox.container.margin,
            left = m,
            right = m,
            vol_footer
          },
          {
            layout = wibox.container.margin,
            left = m,
            right = m,
            bottom = m,
            mic_footer
          }
        }
      }
    }
  }

  return view
end
