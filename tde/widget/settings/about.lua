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
local common = require("lib-tde.function.common")
local trim = common.trim
local bytes_to_grandness = common.bytes_to_grandness
local signals = require("lib-tde.signals")
local hardware = require("lib-tde.hardware-check")
local seperator_widget = require("lib-widget.separator")
local card = require("lib-widget.card")

local uname = require("posix.sys.utsname").uname()

local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

-- returns the total widget and text widget holding the normal name
local function generate_setting_panel(title)
  local typeWidget =
    wibox.widget {
    widget = wibox.widget.textbox,
    text = title,
    font = beautiful.title_font
  }
  local name =
    wibox.widget {
    widget = wibox.widget.textbox,
    text = "Unknown",
    font = beautiful.font,
    fg = beautiful.fg_normal .. "AA"
  }
  local container = card()
  container.forced_width = settings_width - (settings_nw * 2)
  container.forced_height = settings_index

  container.update_body(
    wibox.widget {
      layout = wibox.layout.align.horizontal,
      {layout = wibox.container.margin, left = m, typeWidget},
      {layout = wibox.container.margin, left = m, wibox.widget.base.empty_widget()},
      {layout = wibox.container.margin, right = m, name}
    }
  )
  return wibox.container.margin(container, dpi(5), dpi(5), dpi(5), dpi(5)), name
end

local function get_uptime()
  local diff = os.time() - os.start_time
  local days = math.floor(diff / 86400)
  local hours = math.floor((diff % 86400) / 3600)
  local minutes = math.floor((diff % 3600) / 60)
  local seconds = math.floor(diff % 60)
  return string.format("%d:%02d:%02d:%02d",days,hours,minutes,seconds)
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox("About")
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local logo = wibox.widget.imagebox(icons.logo)
  logo.forced_height = settings_index * 3

  local separator = seperator_widget(settings_index / 1.5)

  local container = wibox.layout.fixed.vertical()
  local device_name, device_text = generate_setting_panel(i18n.translate("Device name"))

  signals.connect_username(
    function(value)
      device_text.text = value
    end
  )

  local memory_name, memory_text = generate_setting_panel(i18n.translate("Memory"))

  signals.connect_ram_total(
    function(value)
      memory_text.text = bytes_to_grandness(value, 1)
    end
  )

  local _, threads, _processor_name = hardware.getCpuInfo()
  local processor_name, processor_text = generate_setting_panel(i18n.translate("Processor"))
  processor_text.text = _processor_name

  local processor_cores, processor_cores_text = generate_setting_panel(i18n.translate("Processor Core Count"))
  processor_cores_text.text = tostring(threads)

  local graphics_name, graphics_text = generate_setting_panel(i18n.translate("Graphics"))
  -- gathered from https://github.com/dylanaraps/neofetch/blob/master/neofetch#L2401
  awful.spawn.easy_async_with_shell('lspci -mm | awk -F \'\\"|\\" \\"|\\\\(\' \'/"Display|"3D|"VGA/ {a[$0] = $1 " " $3 " " $4} END {for(i in a) {if(!seen[a[i]]++) print a[i]}}\' | head -n1',
  function (value)
    graphics_text.text = trim(value)
  end)

  local disk_name, disk_text = generate_setting_panel(i18n.translate("Disk capacity"))

  signals.connect_disk_space(
    function(payload)
      print("Updating disk space")
      disk_text.text = payload
    end
  )

  local display_freq_name, display_freq_text = generate_setting_panel(i18n.translate("Display refresh rate"))

  hardware.getDisplayFrequency(function (freq)
    display_freq_text.text = tostring(freq) .. " Hz"
  end)

  local os_name_name, os_name_text = generate_setting_panel(i18n.translate("OS Name"))
  os_name_text.text = "TOS Linux"

  signals.connect_distro(
    function(payload)
      os_name_text.text = payload
    end
  )

  local os_type_name, os_type_text = generate_setting_panel(i18n.translate("OS Type"))
  os_type_text.text = uname.machine

  local tde_version_name, tde_version_text = generate_setting_panel(i18n.translate("TDE Version"))
  tde_version_text.text = tde.version .. " (" .. tde.release .. ")"

  local tde_uptime_name, tde_uptime_text = generate_setting_panel("TDE " .. i18n.translate("Uptime: "):gsub(':',''))
  tde_uptime_text.text = get_uptime()

  local windowing_system_name, windowing_system_text = generate_setting_panel(i18n.translate("Windowing system"))
  -- TDE currently only supports X11
  windowing_system_text.text = "X11"

  container:add(device_name)

  container:add(separator)

  container:add(memory_name)
  container:add(processor_name)
  container:add(processor_cores)
  container:add(graphics_name)
  container:add(disk_name)
  container:add(display_freq_name)

  container:add(separator)

  container:add(os_name_name)
  container:add(os_type_name)
  container:add(tde_version_name)
  container:add(tde_uptime_name)
  container:add(windowing_system_name)

  signals.emit_request_user()
  signals.emit_request_ram()
  signals.emit_request_distro()

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        logo
      },
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        wibox.container.margin(container, 0, 0, 0, m * 3)
      }
    }
  }

  view.refresh = function ()
    tde_uptime_text.text = get_uptime()

    hardware.getDisplayFrequency(function (freq)
      display_freq_text.text = tostring(freq) .. " Hz"
    end)
  end

  return view
end
