local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local icons = require("theme.icons")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_height = dpi(800)

local settings_nw = dpi(260)

local screens = {}
local mon_size = {
  w = nil,
  h = nil
}

function make_mon(wall, id)
  local monitor =
    wibox.widget {
    widget = wibox.widget.imagebox,
    shape = rounded(),
    clip_shape = rounded(),
    resize = true,
    forced_width = mon_size.w,
    forced_height = mon_size.h
  }
  monitor:set_image(gears.surface.load_uncached(wall))
  return wibox.container.place(
    wibox.widget {
      layout = wibox.layout.stack,
      forced_width = mon_size.w,
      forced_height = mon_size.h,
      wibox.container.place(monitor),
      {
        layout = wibox.container.place,
        valign = "center",
        halign = "center",
        {
          layout = wibox.container.background,
          fg = beautiful.fg_normal,
          bg = beautiful.bg_settings_display_number,
          shape = rounded(dpi(100)),
          forced_width = dpi(100),
          forced_height = dpi(100),
          wibox.container.place(
            {
              widget = wibox.widget.textbox,
              font = beautiful.monitor_font,
              text = id
            }
          )
        }
      }
    }
  )
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m
  view.bottom = m

  local title = wibox.widget.textbox("Display")
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

  local monitors = wibox.container.background()
  monitors.bg = beautiful.bg_modal_title
  monitors.shape = rounded()

  local layout = wibox.layout.flex.horizontal()
  layout.spacing = m

  local changewall = wibox.container.background()
  changewall.top = m
  changewall.bottom = m
  changewall.shape = rounded()
  changewall.bg = beautiful.accent.hue_600

  local brightness = wibox.widget.slider()
  brightness.bar_shape = function(c, w, h)
    gears.shape.rounded_rect(c, w, h, dpi(30) / 2)
  end
  brightness.bar_height = dpi(30)
  brightness.bar_color = beautiful.bg_modal
  brightness.bar_active_color = beautiful.accent.hue_500
  brightness.handle_shape = gears.shape.circle
  brightness.handle_width = dpi(35)
  brightness.handle_color = beautiful.accent.hue_500
  brightness.handle_border_width = 1
  brightness.handle_border_color = "#00000012"
  brightness.minimum = 0
  brightness.maximum = 100
  brightness:connect_signal(
    "property::value",
    function()
      awful.spawn.with_shell("brightness -s " .. tostring(brightness.value))
    end
  )

  awesome.connect_signal(
    "brightness:update",
    function(value)
      brightness:set_value(tonumber(value))
    end
  )

  changewall:connect_signal(
    "mouse::enter",
    function()
      changewall.bg = beautiful.accent.hue_700
    end
  )
  changewall:connect_signal(
    "mouse::leave",
    function()
      changewall.bg = beautiful.accent.hue_600
    end
  )

  changewall:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          if root.elements.settings then
            root.elements.settings.close()
          end
          -- TODO: change wallpaper
        end
      )
    )
  )

  changewall:setup {
    layout = wibox.container.background,
    shape = rounded(),
    {
      layout = wibox.container.place,
      valign = "center",
      forced_height = settings_index,
      {
        widget = wibox.widget.textbox,
        text = "Change wallpaper",
        font = beautiful.title_font
      }
    }
  }

  monitors:setup {
    layout = wibox.container.margin,
    margins = m,
    layout
  }

  view:setup {
    layout = wibox.container.background,
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
        layout = wibox.layout.fixed.vertical,
        {
          layout = wibox.container.background,
          bg = beautiful.bg_modal,
          shape = rounded(),
          forced_height = (m * 6) + dpi(30),
          {
            layout = wibox.layout.fixed.vertical,
            {
              layout = wibox.container.margin,
              margins = m,
              {
                font = beautiful.font,
                text = "Brightness",
                widget = wibox.widget.textbox
              }
            },
            {
              layout = wibox.container.margin,
              left = m,
              right = m,
              bottom = m,
              brightness
            }
          }
        },
        {layout = wibox.container.margin, top = m, monitors},
        {layout = wibox.container.margin, top = m, changewall}
      },
      nil
    }
  }

  view.refresh = function()
    screens = {}
    layout:reset()

    awful.spawn.easy_async_with_shell(
      "brightness -g",
      function(o)
        local n = (1000 * tonumber(o) - 300) / 7
        brightness:set_value(math.floor(tonumber(n)))
      end
    )

    awful.spawn.with_line_callback(
      "tos theme active",
      {
        stdout = function(o)
          table.insert(screens, o)
        end,
        output_done = function()
          --mon_size.w = (((settings_width - settings_nw) - (m * 4)) / #screens) - ((m / 2) * (#screens - 1))
          --mon_size.h = mon_size.w * (screen.primary.geometry.height / screen.primary.geometry.width)
          monitors.forced_height = settings_height / 3
          for k, v in pairs(screens) do
            layout:insert(k, wibox.widget.base.empty_widget())
            layout:set(k, make_mon(v, k))
          end
        end
      }
    )
  end

  return view
end
