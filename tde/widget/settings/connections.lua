local os = require("os")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local hardware = require("lib-tde.hardware-check")
local file = require("lib-tde.file")
local icons = require("theme.icons")
local split = require("lib-tde.function.common").split
local mat_icon_button = require("widget.material.icon-button")
local mat_icon = require("widget.material.icon")
local clickable_container = require("widget.material.clickable-container")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

local active_box = nil
local active_text = ""

local static_connections = {}

local password_to_star = function(pass)
  local str = ""
  for _ = 1, #pass do
    str = str .. "*"
  end
  return str
end

local write_to_textbox = function(char)
  if active_box then
    active_text = active_text .. char
    active_box:set_text(password_to_star(active_text))
  end
end

local delete_key = function()
  if active_box then
    active_text = active_text:sub(1, #active_text - 1)
    active_box:set_text(password_to_star(active_text))
  end
end

local reset_textbox = function()
  if active_box then
    active_text = ""
    active_box:set_text(password_to_star(active_text))
  end
end

local input_grabber =
  awful.keygrabber {
  auto_start = true,
  stop_event = "release",
  keypressed_callback = function(self, mod, key, command)
    if key == "BackSpace" then
      delete_key()
    end
    if #key == 1 then
      write_to_textbox(key)
    end
  end,
  keyreleased_callback = function(self, mod, key, command)
    if key == "Return" then
      self:stop()
    end

    if key == "Escape" then
      self:stop()
      -- restart the settings_grabber listner
      root.elements.settings_grabber:start()
      reset_textbox()
    end
  end
}

local function make_network_widget(ssid, active)
  local box = wibox.container.background()
  box.bg = beautiful.bg_modal
  box.shape = rounded()

  local button = mat_icon_button(mat_icon(icons.plus, dpi(25)))
  button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          -- try to connect without a password
          if active_text == "" then
            awful.spawn.easy_async(
              "tos network connect " .. ssid,
              function(out)
                root.elements.settings_views[2].view.refresh()
              end
            )
          else
            awful.spawn.easy_async(
              "tos network connect " .. ssid .. " password " .. active_text,
              function(out)
                root.elements.settings_views[2].view.refresh()
              end
            )
          end
        end
      )
    )
  )

  local password =
    wibox.widget {
    {
      {
        {
          id = "password_" .. ssid,
          markup = "",
          font = "SF Pro Display Bold 16",
          align = "left",
          valign = "center",
          widget = wibox.widget.textbox
        },
        margins = dpi(5),
        widget = wibox.container.margin
      },
      widget = clickable_container
    },
    bg = beautiful.groups_bg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
    end,
    widget = wibox.container.background
  }

  password:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          -- clear the old password
          if active_box then
            active_text = ""
            active_box:set_text(active_text)
          end
          -- get the new one
          active_box = password:get_children_by_id("password_" .. ssid)[1]
          -- stop grabbing input of a potential other field
          input_grabber:stop()
          print("Start grabbing input")
          input_grabber:start()
        end
      )
    )
  )

  if active then
    -- override button to be a checkmark to indicate connection
    button = wibox.container.margin(wibox.widget.imagebox(icons.network), dpi(10), dpi(10), dpi(10), dpi(10))
    password = wibox.widget.textbox("")
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
    wibox.container.margin(password, dpi(10), dpi(10), dpi(7), dpi(7)),
    button,
    layout = wibox.layout.align.horizontal
  }

  box.widget = widget

  local container = wibox.container.margin()
  container.bottom = m
  container.forced_width = settings_width - settings_nw - (m * 2)
  container.forced_height = dpi(50)
  container.widget = box
  return container
end

function make_connection(t, n)
  local container = wibox.container.margin()
  container.bottom = m
  container.forced_width = settings_width - settings_nw - (m * 2)

  local conx = wibox.container.background()
  conx.bg = beautiful.bg_modal
  conx.shape = rounded()

  local i = ""
  if t == "wireless" then
    i = icons.wifi
  elseif t == "bluetooth" then
    i = icons.bluetooth
  elseif t == "wired" then
    i = icons.lan
  else
    i = ""
  end
  if n == "disconnected" and t == "wireless" then
    i = icons.wifi
  end
  if n == "disconnected" and t == "wired" then
    i = icons.lan
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
    text = t,
    font = beautiful.title_font
  }

  conx:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.container.margin,
      margins = m,
      wibox.container.margin(icon, dpi(10), dpi(10), dpi(10), dpi(10))
    },
    name,
    {layout = wibox.container.margin, right = m, type}
  }

  container.widget = conx

  return {widget = container, icon = icon, name = name}
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox("Connections")
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local close = wibox.widget.imagebox(icons.close)
  close.forced_height = settings_index
  close:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          -- stop grabbing password input
          input_grabber:stop()
          if root.elements.settings then
            root.elements.settings.close()
          end
        end
      )
    )
  )

  local connections = wibox.layout.fixed.vertical()

  local wireless = make_connection("wireless")
  local wired = make_connection("wired")
  local network_settings =
    wibox.container.margin(
    wibox.widget {
      widget = wibox.widget.textbox,
      text = "Network list",
      font = "SF Pro Display Bold 24"
    },
    dpi(20),
    0,
    dpi(20),
    dpi(20)
  )

  table.insert(static_connections, wireless.widget)
  table.insert(static_connections, wired.widget)
  table.insert(static_connections, network_settings)

  connections:add(wireless.widget)
  connections:add(wired.widget)
  connections:add(network_settings)

  view:setup {
    layout = wibox.container.background,
    bg = beautiful.background.hue_800 .. "00",
    --fg = config.colors.xf,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        {
          layout = wibox.container.place,
          title
        },
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

  view.refresh = function()
    if hardware.hasWifi() then
      interface = file.string("/tmp/interface.txt")
      wireless.icon:set_image(icons.wifi)
      wireless.name.text = interface
      awful.spawn.easy_async_with_shell(
        "nmcli dev wifi list | awk 'NR != 1 {print $1, $2, $3}' | sort -k 2,2 | uniq -f1",
        function(out)
          -- remove all wifi connections
          connections.children = static_connections

          for _, value in ipairs(split(out, "\n")) do
            local line = split(value, " ")
            if line[1] == "*" then
              connections:add(make_network_widget(line[3], true))
            else
              connections:add(make_network_widget(line[2], false))
            end
          end
        end
      )
    else
      -- TODO: set disconnected wifi icon
      wireless.icon:set_image(icons.wifi)
      wireless.name.text = "Disconnected"
    end

    awful.spawn.easy_async_with_shell(
      'sh -c \'ip link | grep ": en" | grep " UP "\'',
      function(o, e, r, c)
        if (c == 0) then
          wired.icon.text = icons.lan
          wired.name.text = "connected"
        else
          -- TODO: set disconnected lan icon
          wired.icon.text = icons.lanx
          wired.name.text = "Disconnected"
        end
      end
    )
  end

  return view
end
