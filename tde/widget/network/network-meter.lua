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
local mat_slider = require("widget.material.progress_bar")
local mat_icon = require("widget.material.icon")
local icons = require("theme.icons")
local dpi = require("beautiful").xresources.apply_dpi
local filehandle = require("lib-tde.file")
local gears = require("gears")
local common = require("lib-tde.function.common")
local delayed_timer = require("lib-tde.function.delayed-timer")

local config = require("config")

local biggest_upload = 1
local biggest_download = 1

local last_rx = 0
local last_tx = 0

-- only run the networking poll every x seconds
local counter = 0
local interface = nil

if filehandle.exists("/tmp/interface.txt") then
  interface = filehandle.string("/tmp/interface.txt"):gsub("\n", "")
end
local value_up =
  wibox.widget {
  markup = "...",
  align = "center",
  valign = "center",
  font = "SFNS Display 14",
  widget = wibox.widget.textbox
}

local value_down =
  wibox.widget {
  markup = "...",
  align = "center",
  valign = "center",
  font = "SFNS Display 14",
  widget = wibox.widget.textbox
}

local function _draw_results(download, upload)
  if download > biggest_download then
    biggest_download = download
  end

  if upload > biggest_upload then
    biggest_upload = upload
  end

  local download_text = common.bytes_to_grandness(download)
  local upload_text = common.bytes_to_grandness(upload)

  value_up:set_markup_silently(gears.string.xml_escape(upload_text))
  value_down:set_markup_silently(gears.string.xml_escape(download_text))

  if network_slider_up then
    network_slider_up:set_value((upload / biggest_upload) * 100)
  end
  if network_slider_down then
    network_slider_down:set_value((download / biggest_download) * 100)
  end

  print("Network download: " .. download_text)
  print("Network upload: " .. upload_text)
end

delayed_timer(
  config.network_poll,
  function()
    -- sanitizing the interface
    if interface == nil then
      interface = filehandle.string("/tmp/interface.txt"):gsub("\n", "")
      return
    end

    counter = counter + 1

    local valueRX = filehandle.string("/sys/class/net/" .. interface .. "/statistics/rx_bytes"):gsub("\n", "")
    local valueTX = filehandle.string("/sys/class/net/" .. interface .. "/statistics/tx_bytes"):gsub("\n", "")

    valueRX = tonumber(valueRX) or 0
    valueTX = tonumber(valueTX) or 0

    local download = math.ceil((valueRX - last_rx) / config.network_poll)
    local upload = math.ceil((valueTX - last_tx) / config.network_poll)

    if not (last_rx == 0) and not (last_tx == 0) then
      _draw_results(download, upload)
    end
    last_rx = valueRX
    last_tx = valueTX
  end,
  config.netwok_startup_delay
)

function up(screen)
  network_slider_up =
    wibox.widget {
    read_only = true,
    forced_width = screen.geometry.width * 0.13,
    widget = mat_slider
  }
  network_meter_up =
    wibox.widget {
    wibox.widget {
      icon = icons.upload,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      network_slider_up,
      wibox.container.margin(value_up, dpi(1), dpi(0), dpi(10), dpi(10)),
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal
    },
    widget = mat_list_item
  }
  return network_meter_up
end

function down(screen)
  network_slider_down =
    wibox.widget {
    read_only = true,
    forced_width = screen.geometry.width * 0.13,
    widget = mat_slider
  }
  network_meter_down =
    wibox.widget {
    wibox.widget {
      icon = icons.download,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      network_slider_down,
      wibox.container.margin(value_down, dpi(1), dpi(0), dpi(10), dpi(10)),
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal
    },
    widget = mat_list_item
  }
  return network_meter_down
end

return function(bIsUpload, screen)
  if bIsUpload then
    return up(screen)
  end
  return down(screen)
end
