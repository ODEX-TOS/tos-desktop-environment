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
local split = require("lib-tde.function.common").split
local signals = require("lib-tde.signals")
local mat_icon_button = require("widget.material.icon-button")
local mat_icon = require("widget.material.icon")
local card = require("lib-widget.card")
local naughty = require("naughty")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

local refresh = function()
end

local devices = {}
local paired_devices = {}

local function notify(title, msg)
  naughty.notification(
    {
      title = i18n.translate("Bluetooth"),
      text = i18n.translate(title) .. '\n<span weight="bold">' .. msg .. "</span>",
      timeout = 5,
      urgency = "critical",
      icon = icons.warning
    }
  )
end

local function make_bluetooth_widget(tbl)
  -- make sure ssid is not nil
  local name = tbl.name or tbl.mac
  local mac = tbl.mac
  local paired = tbl.paired

  local box = card()

  -- TODO: add tooltip for the buttons to make a difference between pair and connect

  local connect_btn = mat_icon_button(mat_icon(icons.plus, dpi(25)))
  connect_btn:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          print("Connect to bluetooth using the name: " .. name)
          local cmd = "bluetoothctl connect '" .. mac .. "'"
          print("Executing command: " .. cmd)
          awful.spawn.easy_async(
            cmd,
            function(out, _, _, code)
              print("Bluetooth connection result: " .. out)
              if not (code == 0) then
                notify("Connection failed", out)
              end
              refresh()
            end
          )
        end
      )
    )
  )

  -- TODO: use a pair icon
  local pair_btn = mat_icon_button(mat_icon(icons.bluetooth, dpi(25)))
  pair_btn:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          print("Pairing to " .. name)
          local cmd = "bluetoothctl pair '" .. mac .. "'"
          print("Executing command: " .. cmd)
          awful.spawn.easy_async(
            cmd,
            function(out, _, _, code)
              print("Bluetooth pairing result: " .. out)
              if not (code == 0) then
                notify("Pairing failed", out)
              end
              refresh()
            end
          )
        end
      )
    )
  )

  local buttons = wibox.layout.fixed.horizontal()
  -- only allow pairing if we aren't paired yet
  if not paired then
    buttons:add(pair_btn)
    awful.tooltip {
      objects = {pair_btn},
      text = i18n.translate("Pair with ") .. name
    }
  end

  buttons:add(connect_btn)
  awful.tooltip {
    objects = {connect_btn},
    text = i18n.translate("Connect to ") .. name
  }

  -- name on the left, password entry in the middle, connect button on the right
  local widget =
    wibox.widget {
    wibox.container.margin(
      wibox.widget {
        widget = wibox.widget.textbox,
        text = name,
        font = beautiful.title_font
      },
      dpi(10),
      dpi(10),
      dpi(10),
      dpi(10)
    ),
    nil,
    buttons,
    layout = wibox.layout.align.horizontal
  }

  box.update_body(widget)

  local container = wibox.container.margin()
  container.bottom = m
  container.forced_width = settings_width - settings_nw - (m * 2)
  container.forced_height = dpi(50)
  container.widget = box
  return container
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Bluetooth"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local connections = wibox.layout.fixed.vertical()

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
  view:setup {
    layout = wibox.container.background,
    bg = beautiful.background.hue_800 .. "00",
    --fg = config.colors.xf,
    {
      layout = wibox.layout.align.vertical,
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
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        connections
      }
    }
  }

  local stop_view = function()
    print("Stopping bluetooth advertisment")
    -- disable our discovery
    awful.spawn("bluetoothctl scan off")
    awful.spawn("bluetoothctl pairable off")
    awful.spawn("bluetoothctl discoverable off")
  end

  -- make sure we always gracefully shutdown
  signals.connect_exit(
    function()
      stop_view()
    end
  )

  local function check_data()
    -- TODO:  don't add a button to a already connected bluetooth device
    -- only generate the list if both commands completed
    if #devices > 0 and #paired_devices > 0 then
      for _, value in ipairs(devices) do
        connections:add(
          make_bluetooth_widget(
            {
              name = value.name,
              mac = value.mac,
              paired = paired_devices[value.mac] ~= nil
            }
          )
        )
      end
    end
  end

  refresh = function()
    print("Starting bluetooth advertisment")
    awful.spawn("bluetoothctl scan on")
    awful.spawn("bluetoothctl pairable on")
    awful.spawn("bluetoothctl discoverable on")

    -- TODO: add connections when a new scanned device is turned on

    -- remove all connections
    connections.children = {}
    devices = {}
    paired_devices = {}

    awful.spawn.easy_async_with_shell(
      "bluetoothctl devices",
      function(out)
        for _, value in ipairs(split(out, "\n")) do
          local mac, name = string.match(value, "^Device ([A-F0-9:]+) (.*)$")
          if name == nil then
            name = mac
          end
          table.insert(
            devices,
            {
              mac = mac,
              name = name
            }
          )
        end
        check_data()
      end
    )

    awful.spawn.easy_async_with_shell(
      "bluetoothctl paired-devices",
      function(out)
        for _, value in ipairs(split(out, "\n")) do
          local mac = string.match(value, "^Device ([A-F0-9:]+) .*$") or split(value, " ")[2]
          paired_devices[mac] = true
        end
        -- this is to indicate that we are done
        table.insert(paired_devices, true)
        check_data()
      end
    )
  end

  view.refresh = refresh
  view.stop_view = stop_view
  return view
end
