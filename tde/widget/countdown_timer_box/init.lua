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

local mat_list_item = require("widget.material.list-item")
local clickable_container = require("widget.material.clickable-container")
local mat_icon = require("widget.material.icon")
local icons = require("theme.icons")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local beautiful = require("beautiful")
local signals = require("lib-tde.signals")

local filehandle = require('lib-tde.file')

local sound = require("lib-tde.sound").timer_sound

local pid = -1

local delay =
  clickable_container(
  wibox.container.margin(
    wibox.widget {
      markup = i18n.translate("Stop") .. " " .. i18n.translate("Alarm"),
      align = "center",
      valign = "center",
      read_only = true,
      font = beautiful.font_type .. ' 30',
      widget = wibox.widget.textbox
    },
    dpi(14),
    dpi(14),
    dpi(14),
    dpi(14)
  )
)

local message =  wibox.widget {
  text = "",
  align = "center",
  valign = "center",
  read_only = true,
  font = beautiful.font_type .. ' 30',
  widget = wibox.widget.textbox
}

local function update_message(text)
  message.text = text
end

local buttons =
  wibox.widget {
  {
    delay,
    layout = wibox.layout.fixed.horizontal
  },
  halign = "center",
  bg = beautiful.bg_modal,
  widget = wibox.container.place()
}

local countdownMeter =
  wibox.widget {
  wibox.widget {
    wibox.widget {
      icon = icons.clock,
      size = dpi(200),
      widget = mat_icon
    },
    widget = mat_list_item
  },
  wibox.container.margin(message, 0, 0, dpi(100), 0),
  buttons,
  spacing = dpi(100),
  layout = wibox.layout.fixed.vertical
}

awful.screen.connect_for_each_screen(
  function(s)
        local countdownOverlay =
        wibox(
        {
            visible = false,
            ontop = true,
            type = "normal",
            height = s.geometry.height,
            width = s.geometry.width,
            bg = beautiful.bg_modal,
            x = s.geometry.x,
            y = s.geometry.y
        }
        )

        screen.connect_signal(
        "removed",
        function(removed)
            if s == removed then
            countdownOverlay.visible = false
            countdownOverlay = nil
            end
        end
        )

        signals.connect_refresh_screen(
        function()
            print("Refreshing countdown timer screen")
            if not s.valid or countdownOverlay == nil then
            return
            end
            -- the action center itself
            countdownOverlay.x = s.geometry.x
            countdownOverlay.y = s.geometry.y
            countdownOverlay.width = s.geometry.width
            countdownOverlay.height = s.geometry.height
        end
        )

        -- Put its items in a shaped container
        countdownOverlay:setup {
            -- Container
            {
                countdownMeter,
                layout = wibox.layout.fixed.vertical
            },
            -- The real background color
            bg = beautiful.background.hue_800 .. beautiful.background_transparency,
            valign = "center",
            halign = "center",
            widget = wibox.container.place()
        }

        local countdownbackdrop =
            wibox {
                ontop = true,
                visible = false,
                screen = s,
                bg = "#000000aa",
                type = "dock",
                x = s.geometry.x,
                y = s.geometry.y,
                width = s.geometry.width,
                height = s.geometry.height - dpi(40)
            }

        countdownOverlay.show = function(msg)
            msg = msg or ""
            countdownbackdrop.visible = true
            countdownOverlay.visible = true

            update_message(msg)

            pid = sound(true)
        end

        countdownOverlay.kill_sound = function()
          if pid ~= -1 and type(pid) == "number" and filehandle.dir_exists('/proc/' .. tostring(pid)) then
            awful.spawn('kill ' .. tostring(pid), false)
          end
          pid = -1
        end

        countdownOverlay.play = function(timeout)
          timeout = timeout or 5
          pid = sound(true)

          gears.timer {
            single_shot = true,
            autostart = true,
            timeout = timeout,
            callback = function()
              countdownOverlay.kill_sound()
            end
          }
        end

        countdownOverlay.hide = function()
            countdownbackdrop.visible = false
            countdownOverlay.visible = false

            countdownOverlay.kill_sound()
        end

        s.countdownOverlay = countdownOverlay
end
)

delay:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        print("Stopping Alarm")
        if awful.screen.focused().countdownOverlay then
            awful.screen.focused().countdownOverlay.hide()
        end
      end
    )
  )
)