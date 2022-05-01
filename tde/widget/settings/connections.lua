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
local hardware = require("lib-tde.hardware-check")
local file = require("lib-tde.file")
local icons = require("theme.icons")
local mat_icon_button = require("widget.material.icon-button")
local mat_icon = require("widget.material.icon")
local card = require("lib-widget.card")
local loading = require("lib-widget.loading")
local inputfield = require("lib-widget.inputfield")
local tde_button = require("lib-widget.button")
local signals = require("lib-tde.signals")
local scrollbox = require("lib-widget.scrollbox")
local network = require("lib-tde.network")

local qr_code = require("lib-tde.qr-code")

local dpi = beautiful.xresources.apply_dpi

local size = require("widget.settings.size")

local m = size.m
local settings_index = size.settings_index
local settings_width = size.settings_width
local settings_height = size.settings_height
local settings_nw = size.settings_nw


local active_text = ""

local static_connections = {}
local password_fields = {}

local qr_surface

local weak = {}
weak.__mode = "k"
setmetatable(static_connections, weak)
setmetatable(password_fields, weak)


local scrollbox_body

local refresh = function()
end

local connections = wibox.layout.fixed.vertical()

local loader = loading()
loader.stop()

local function start_loading()
  loader.start()
  connections.children = static_connections
  connections:add(wibox.container.place(loader))
end

local function stop_loading()
  loader.stop()
  connections.children = static_connections
end

local bIsShowingNetworkTab = true

local active_pallet = beautiful.primary

signals.connect_primary_theme_changed(
  function(pallete)
    active_pallet = pallete
  end
)


-- returns the filename of the qr code image
local function generate_qr_code(ssid, password)
  local qr_text = "WIFI:T:WPA;S:" .. ssid .. ";P:" .. password .. ";;"
  qr_surface = qr_code.surface(qr_text, settings_width, beautiful.awesome_icon)
end

local function make_qr_code_field()
  local img =
    wibox.widget {
    image = qr_surface,
    resize = true,
    forced_height = (settings_height / 2),
    clip_shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(20))
    end,
    widget = wibox.widget.imagebox
  }
  local done_btn =
    tde_button({
      body = wibox.widget.imagebox(icons.qr_code),
      callback = function()
        bIsShowingNetworkTab = true
        refresh()
      end,
      pallet = active_pallet
    })

  return wibox.widget {
    wibox.container.place(img),
    wibox.container.margin(done_btn, m, m, m, m),
    layout = wibox.layout.fixed.vertical
  }
end

local __id = 1

local function make_network_widget(ssid, active)
  -- make sure ssid is not nil
  ssid = ssid or ""

  local box = card()

  local password

  password = inputfield({
    typing_callback = function(text)
        active_text = text
    end,
    done_callback = function(_)
        root.elements.settings_grabber:start()
    end,
    start_callback = function()
        print("Not resetting: " .. password["id"] .. " (" .. ssid .. ")")
        for _, v in ipairs(password_fields) do
          if v["id"] ~= password["id"] then
            v.reset()
          end
        end

        password.focus()
    end,
    hidden = true
    })

  __id = __id + 1
  password["id"] = __id

  local button = mat_icon_button(mat_icon(icons.plus, dpi(25)))
  button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          -- try to connect without a password
          start_loading()
          if active_text == "" then
            awful.spawn.easy_async(
              "tos network connect '" .. ssid .. "'",
              function(_)
                stop_loading()
                refresh()
              end
            )
          else
            awful.spawn.easy_async(
              "tos network connect '" .. ssid .. "' password '" .. active_text .. "'",
              function(_)
                stop_loading()
                password.clear_text()
                refresh()
              end
            )
          end
        end
      )
    )
  )

  if active then
    -- override button to be a checkmark to indicate connection
    button = wibox.container.margin(wibox.widget.imagebox(icons.network), dpi(10), dpi(10), dpi(10), dpi(10))
    password =
      tde_button({
      body = wibox.widget.imagebox(icons.qr_code),
      callback = function()
        print("Generating qr code")
        local passwd =
          string.gsub(
          hardware.execute("nmcli --show-secrets -g 802-11-wireless-security.psk connection show id '" .. ssid .. "'"),
          "\n",
          ""
        )
        generate_qr_code(ssid, passwd)
        bIsShowingNetworkTab = false
        refresh()
      end,
      pallet = active_pallet
    })
  else
    table.insert(password_fields, password)
  end

  -- name on the left, password entry in the middle, connect button on the right
  local widget =
    wibox.widget {
    wibox.container.margin(
      wibox.widget {
        widget = wibox.widget.textbox,
        text = ssid,
        font = beautiful.title_font
      },
      dpi(10),
      dpi(10),
      dpi(10),
      dpi(10)
    ),
    wibox.widget {
      widget = wibox.container.margin(password, m,m,dpi(5), dpi(5)),
      fill_horizontal = false,
      valign = 'center',
      halign = 'center',

    },
    button,
    layout = wibox.layout.ratio.horizontal
  }

  widget:adjust_ratio(2, 0.25, 0.70, 0.05)

  box.update_body(widget)

  local container = wibox.container.margin()
  container.bottom = m
  container.forced_width = settings_width - settings_nw - (m * 2)
  container.forced_height = dpi(50)
  container.widget = box
  return container
end

local function make_connection(t, n)
  local container = wibox.container.margin()
  container.bottom = m
  container.forced_width = settings_width - settings_nw - (m * 2)

  local conx = card()

  local i
  local wireless = "wireless"
  local bluetooth = "bluetooth"
  local wired = "wired"

  if t == wireless then
    i = icons.wifi
  elseif t == bluetooth then
    i = icons.bluetooth
  elseif t == wired then
    i = icons.lan
  else
    i = icons.lan_off
  end
  if n == "disconnected" and t == wireless then
    i = icons.wifi_off
  end
  if n == "disconnected" and t == wired then
    i = icons.lan_off
  end
  local icon =
    wibox.widget {
    image = i,
    resize = true,
    forced_width = 50,
    forced_height = 50,
    widget = wibox.widget.imagebox
  }

  local name =
    wibox.widget {
    widget = wibox.widget.textbox,
    text = n,
    font = beautiful.title_font
  }

  local type =
    wibox.widget {
    widget = wibox.widget.textbox,
    -- Holds the string "wireless", "wired" or similar
    text = i18n.translate(t),
    font = beautiful.title_font
  }

  local address =
    wibox.widget {
    widget = wibox.widget.textbox,
    text = "",
    font = beautiful.title_font
  }

  conx.update_body(
    wibox.widget {
      layout = wibox.layout.align.horizontal,
      {
        layout = wibox.container.margin,
        margins = m,
        wibox.container.margin(icon, dpi(10), dpi(10), dpi(10), dpi(10))
      },
      address,
      wibox.container.margin(name, 0, m),
      {layout = wibox.container.margin, right = m, type}
    }
  )

  container.widget = conx

  return {widget = container, icon = icon, name = name, ip = address}
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Connections"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local wireless = make_connection("wireless")
  local wired = make_connection("wired")
  local network_settings =
    wibox.container.margin(
    wibox.widget {
      widget = wibox.widget.textbox,
      text = i18n.translate("Network list"),
      font = "SF Pro Display Bold 24"
    },
    dpi(20),
    0,
    dpi(20),
    dpi(20)
  )

  table.insert(static_connections, wireless.widget)
  table.insert(static_connections, wired.widget)
  table.insert(static_connections, tde_button({
    body = "Restart Network",
    callback = function()
    start_loading()

    -- make sure the input goes to the polkit authenticator
    root.elements.settings.ontop = false
    root.elements.settings_grabber:stop()

    awful.spawn.easy_async("tos network restart", function()
      stop_loading()

      -- Regrab the focus back (unless we closed the settings)
      if root.elements.settings.visible then
        root.elements.settings.ontop = true
        root.elements.settings_grabber:start()
      end

      refresh()
    end)

  end}))
  table.insert(static_connections, network_settings)

  connections:add(wireless.widget)
  connections:add(wired.widget)
  connections:add(network_settings)

  scrollbox_body = scrollbox(connections)

  view:setup {
    layout = wibox.container.background,
    bg = beautiful.transparent,
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

  local function setup_network_connections()
    start_loading()
    network.get_ssid_list(function (list)
      stop_loading()
      for _, value in pairs(list) do
        connections:add(make_network_widget(value["ssid"], value["active"]))
      end
    end)
  end

  refresh = function()
    password_fields = {}
    setmetatable(password_fields, weak)

    local interface = file.string("/tmp/interface.txt")

    if scrollbox_body then
      scrollbox_body.reset()
    end

    if hardware.hasWifi() and interface ~= "" then
      wireless.icon:set_image(icons.wifi)
      wireless.name.text = interface
      wireless.ip.text = hardware.getDefaultIP()
    else
      wireless.icon:set_image(icons.wifi_off)
      wireless.name.text = i18n.translate("Disconnected")
      wireless.ip.text = ""
    end

    -- Always try to populate network list, even when it is not possible
    -- This is to make networks more easily detectable in case your wifi card is not working properly, or when the pc never had a network before
    if bIsShowingNetworkTab and hardware.hasWifiCard() then
      -- remove all wifi connections
      connections.children = static_connections
      setup_network_connections()
    elseif hardware.hasWifi() then
      -- remove all wifi connections
      connections.children = static_connections
      connections:add(make_qr_code_field())
    end

    awful.spawn.easy_async_with_shell(
      'ip link | grep ": en" | grep " UP "',
      function(_, _, _, c)
        if (c == 0) then
          print("Lan on")
          wired.icon:set_image(icons.lan)
          wired.name.text = i18n.translate("connected")
          wired.ip.text = hardware.getDefaultIP()
        else
          wired.icon:set_image(icons.lan_off)
          wired.name.text = i18n.translate("Disconnected")
          wired.ip.text = ""
        end
      end
    )
  end

  view.refresh = refresh

  -- Ensure the inputfields lose focus
  view.stop_view = function ()
    for _, field in ipairs(password_fields) do
      field.reset()
    end
  end

  return view
end
