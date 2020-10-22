local os = require("os")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local hardware = require("lib-tde.hardware-check")
local file = require("lib-tde.file")
local icons = require("theme.icons")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

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

  local name = wibox.widget.textbox(n)

  local type = wibox.widget.textbox(t)

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
  connections:add(wireless.widget)
  connections:add(wired.widget)

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
