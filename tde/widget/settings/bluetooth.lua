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
local loading_widget = require("lib-widget.loading")
local naughty = require("naughty")
local execute = require("lib-tde.hardware-check").execute
local scrollbox = require("lib-widget.scrollbox")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

local scrollbox_body

local refresh = function()
end

local devices = {}
local paired_devices = {}

local connections = wibox.layout.fixed.vertical()

local loader

local function loading()
  connections.children = {}
  loader = loading_widget()
  connections:add(wibox.container.place(loader))
end

local function stop_loading()
  if loader then
    loader.stop()
    connections.children = {}
  end
end

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
  local connected = tbl.connected

  local box = card()

  -- TODO: add tooltip for the buttons to make a difference between pair and connect
  local disconnect_btn = mat_icon_button(mat_icon(icons.minus, dpi(25)))
  disconnect_btn:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          print("Disconnecting from: " .. name)
          local cmd = "bluetoothctl disconnect '" .. mac .. "'"
          print("Executing command: " .. cmd)
          loading()
          awful.spawn.easy_async(
            cmd,
            function(out, _, _, code)
              stop_loading()
              print("Bluetooth connection result: " .. out)
              if not (code == 0) then
                notify("Disconnection failed", out)
              end
              refresh()
            end
          )
        end
      )
    )
  )

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
          loading()
          awful.spawn.easy_async(
            cmd,
            function(out, _, _, code)
              stop_loading()
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
          loading()
          awful.spawn.easy_async(
            cmd,
            function(out, _, _, code)
              stop_loading()
              print("Bluetooth pairing result: " .. out)
              if not (code == 0) then
                notify("Pairing failed", out)
              end
              awful.spawn("bluetoothctl trust '" .. mac .. "'")
              refresh()
            end
          )
        end
      )
    )
  )

  local unpair_btn = mat_icon_button(mat_icon(icons.bluetooth_off, dpi(25)))
  unpair_btn:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          print("unpairing to " .. name)
          local cmd = "bluetoothctl untrust '" .. mac .. "'"
          local cmd2 = "bluetoothctl remove '" .. mac .. "'"
          loading()
          awful.spawn.easy_async(
            cmd,
            function()
              awful.spawn.easy_async(
                cmd2,
                function()
                  stop_loading()
                  refresh()
                end
              )
            end
          )
        end
      )
    )
  )

  local buttons = wibox.layout.fixed.horizontal()
  -- only allow pairing if we aren't paired yet
  if paired then
    buttons:add(unpair_btn)
    awful.tooltip {
      objects = {unpair_btn},
      text = i18n.translate("Forget ") .. name
    }
  else
    buttons:add(pair_btn)
    awful.tooltip {
      objects = {pair_btn},
      text = i18n.translate("Pair with ") .. name
    }
  end
  if connected then
    buttons:add(disconnect_btn)
    awful.tooltip {
      objects = {disconnect_btn},
      text = i18n.translate("Disconnect from ") .. name
    }
  else
    buttons:add(connect_btn)
    awful.tooltip {
      objects = {connect_btn},
      text = i18n.translate("Connect to ") .. name
    }
  end

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

  scrollbox_body = scrollbox(connections)
  view:setup {
    layout = wibox.container.background,
    bg = beautiful.background.hue_800 .. "00",
    --fg = config.colors.xf,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        scrollbox_body
      }
    }
  }

  local timer =
    gears.timer {
    autostart = false,
    timeout = 20,
    callback = function()
      print("Refreshing")
      refresh(true)
    end
  }

  local stop_view = function()
    print("Stopping bluetooth advertisment")
    timer:stop()
    -- disable our discovery
    if IsreleaseMode then
      awful.spawn([[sh -c '
      killall bluetoothctl; 
      bluetoothctl scan off;
      bluetoothctl pairable off;
      bluetoothctl discoverable off;
      ']])
    end

  end

  -- make sure we always gracefully shutdown
  signals.connect_exit(
    function()
      stop_view()
    end
  )

  local function is_connected(mac, stdout)
    if stdout == nil then
      return false
    end
    return (stdout:find(mac) ~= nil)
  end

  local function check_data()
    -- TODO:  don't add a button to an already connected bluetooth device
    -- only generate the list if both commands completed
    if #devices > 0 and #paired_devices > 0 then
      local stdout, _ = execute("bluetoothctl info")
      for _, value in ipairs(devices) do
        connections:add(
          make_bluetooth_widget(
            {
              name = value.name,
              mac = value.mac,
              paired = paired_devices[value.mac] ~= nil,
              connected = is_connected(value.mac, stdout)
            }
          )
        )
      end
    end
  end

  refresh = function(bIsTimer)
    if scrollbox_body then
      scrollbox_body.reset()
    end
    if not IsreleaseMode then
      return
    end
    if bIsTimer == nil then
      print("Starting bluetooth advertisment")
      awful.spawn("sh -c 'bluetoothctl scan on; bluetoothctl pairable on; bluetoothctl discoverable on'")
    elseif timer.started == nil then
      timer:start()
    end

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
          if mac ~= nil then
            table.insert(
              devices,
              {
                mac = mac,
                name = name
              }
            )
          end
        end
        check_data()
      end
    )

    awful.spawn.easy_async_with_shell(
      "bluetoothctl paired-devices",
      function(out)
        for _, value in ipairs(split(out, "\n")) do
          local mac = string.match(value, "^Device ([A-F0-9:]+) .*$") or split(value, " ")[2]
          if mac ~= nil then
            paired_devices[mac] = true
          end
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
