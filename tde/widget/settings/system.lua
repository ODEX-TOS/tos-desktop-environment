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
local file = require("lib-tde.file")
local signals = require("lib-tde.signals")
local card = require("lib-widget.card")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(800)
local settings_nw = dpi(260)

local function todecimal(value, precision)
  return string.format(
    "%." .. tostring(precision) .. "f",
    value)
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("System"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local graph = card()
  graph.forced_height = 200
  graph.forced_width = settings_width - settings_nw - (m * 2)

  local scale = wibox.layout.align.vertical()
  local scale_max = wibox.widget.textbox("100%")
  local scale_min = wibox.widget.textbox("0%")
  scale_max.font = beautiful.font
  scale_min.font = beautiful.font
  scale.first = scale_max
  scale.third = scale_min
  scale.second = wibox.widget.base.empty_widget()
  scale.forced_width = 30

  local ram_progress = wibox.widget.progressbar()
  ram_progress.max_value = 100
  ram_progress.background_color = beautiful.bg_modal .. "00"
  ram_progress.color = beautiful.ram_bar
  ram_progress.value = 0
  ram_progress.bar_shape = function(c, w, h)
    gears.shape.partially_rounded_rect(c, w, h, false, true, true, false, dpi(10))
  end

  local cpu_progress = wibox.widget.progressbar()
  cpu_progress.max_value = 100
  cpu_progress.background_color = beautiful.bg_modal .. "00"
  cpu_progress.color = beautiful.cpu_bar
  cpu_progress.value = 0
  cpu_progress.bar_shape = function(c, w, h)
    gears.shape.partially_rounded_rect(c, w, h, false, true, true, false, dpi(10))
  end

  local disk_progress = wibox.widget.progressbar()
  disk_progress.max_value = 100
  disk_progress.background_color = beautiful.bg_modal .. "00"
  disk_progress.color = beautiful.disk_bar
  disk_progress.value = 0
  disk_progress.bar_shape = function(c, w, h)
    gears.shape.partially_rounded_rect(c, w, h, false, true, true, false, dpi(10))
  end

  local ram = wibox.container.rotate(ram_progress, "east")
  local cpu = wibox.container.rotate(cpu_progress, "east")
  local disk = wibox.container.rotate(disk_progress, "east")

  local ram_value = wibox.widget.textbox()
  ram_value.font = beautiful.font
  ram_value.visible = false

  local cpu_value = wibox.widget.textbox()
  cpu_value.font = beautiful.font
  cpu_value.visible = false

  local disk_value = wibox.widget.textbox()
  disk_value.font = beautiful.font
  disk_value.visible = false

  local ram_key = wibox.widget.textbox(i18n.translate("RAM"))
  ram_key.font = beautiful.font

  local cpu_key = wibox.widget.textbox(i18n.translate("CPU"))
  cpu_key.font = beautiful.font

  local disk_key = wibox.widget.textbox(i18n.translate("Disk"))
  disk_key.font = beautiful.font

  ram:connect_signal(
    "mouse::enter",
    function()
      ram_value.visible = true
    end
  )
  ram:connect_signal(
    "mouse::leave",
    function()
      ram_value.visible = false
    end
  )

  cpu:connect_signal(
    "mouse::enter",
    function()
      cpu_value.visible = true
    end
  )
  cpu:connect_signal(
    "mouse::leave",
    function()
      cpu_value.visible = false
    end
  )

  disk:connect_signal(
    "mouse::enter",
    function()
      disk_value.visible = true
    end
  )
  disk:connect_signal(
    "mouse::leave",
    function()
      disk_value.visible = false
    end
  )

  graph.update_body(
    wibox.widget {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.container.margin,
        top = m,
        wibox.widget.base.empty_widget()
      },
      {
        layout = wibox.layout.align.horizontal,
        {
          layout = wibox.container.margin,
          margins = m,
          scale
        },
        {
          layout = wibox.container.margin,
          right = m * 5,
          {
            layout = wibox.container.background,
            {
              layout = wibox.layout.flex.horizontal,
              spacing = m * 2,
              {
                layout = wibox.layout.stack,
                ram,
                {layout = wibox.container.place, valign = "bottom", ram_value}
              },
              {
                layout = wibox.layout.stack,
                cpu,
                {layout = wibox.container.place, valign = "bottom", cpu_value}
              },
              {
                layout = wibox.layout.stack,
                disk,
                {layout = wibox.container.place, valign = "bottom", disk_value}
              }
            }
          }
        }
      },
      {
        layout = wibox.container.margin,
        left = m * 5,
        right = m * 5,
        {
          layout = wibox.layout.flex.horizontal,
          forced_height = settings_index,
          spacing = m * 2,
          {layout = wibox.container.place, ram_key},
          {layout = wibox.container.place, cpu_key},
          {layout = wibox.container.place, disk_key}
        }
      }
    }
  )

  local pac = card()
  pac:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          local term = os.getenv("TERMINAL") or "st"
          awful.spawn(term .. ' -e "system-updater"')
        end
      )
    )
  )

  local pac_icon = wibox.container.margin(wibox.widget.imagebox(icons.package), dpi(12), dpi(12), dpi(12), dpi(12))
  pac_icon.forced_height = settings_index + m + m

  local pac_title = wibox.widget.textbox(i18n.translate("System Updates"))
  pac_title.font = beautiful.title_font

  local pac_value = wibox.widget.textbox(i18n.translate("None available"))
  pac_value.font = beautiful.title_font

  pac.update_body(
    wibox.widget {
      layout = wibox.layout.align.horizontal,
      {layout = wibox.container.margin, left = m, pac_icon},
      {layout = wibox.container.margin, left = m, pac_title},
      {layout = wibox.container.margin, right = m, pac_value}
    }
  )

  local general_info = card()

  local osName =
    wibox.widget {
    font = beautiful.title_font,
    text = "OS: unknown",
    widget = wibox.widget.textbox
  }
  local kernelVersion =
    wibox.widget {
    font = beautiful.title_font,
    text = "Kernel: unknown",
    widget = wibox.widget.textbox
  }
  local hostName =
    wibox.widget {
    font = beautiful.title_font,
    text = i18n.translate("Hostname: ") .. file.string("/etc/hostname"):gsub("%\n", ""),
    widget = wibox.widget.textbox
  }
  local uptime =
    wibox.widget {
    font = beautiful.title_font,
    text = i18n.translate("Uptime: unknown"),
    widget = wibox.widget.textbox
  }
  signals.connect_distro(
    function(value)
      osName.text = i18n.translate("OS: ") .. value
    end
  )

  signals.connect_uptime(
    function(value)
      uptime.text = i18n.translate("Uptime: ") .. value
    end
  )

  signals.connect_kernel(
    function(value)
      kernelVersion.text = i18n.translate("Kernel: ") .. value
    end
  )

  general_info.update_body(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      wibox.container.margin(osName, dpi(20), 0, dpi(20), 0),
      wibox.container.margin(kernelVersion, dpi(20)),
      wibox.container.margin(hostName, dpi(20)),
      wibox.container.margin(uptime, dpi(20), 0, 0, dpi(20))
    }
  )

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      graph,
      {layout = wibox.container.margin, top = m, pac},
      {layout = wibox.container.margin, top = m, bottom = m, general_info}
    }
  }

  -- TODO: decrease precision of the values
  signals.connect_ram_usage(
    function(value)
      ram_progress:set_value(value)
      ram_value.text = todecimal(value, 2) .. "%"
    end
  )

  signals.connect_packages_to_update(
    function(value)
      pac_value.text = i18n.translate("Packages to update: ") .. value
    end
  )

  signals.connect_cpu_usage(
    function(value)
      cpu_progress:set_value(value)
      cpu_value.text = todecimal(value, 2) .. "%"
    end
  )

  signals.connect_disk_usage(
    function(value)
      disk_progress:set_value(value)
      disk_value.text = todecimal(value, 2) .. "%"
    end
  )

  view.refresh = function()
  end

  view.refresh()

  return view
end
