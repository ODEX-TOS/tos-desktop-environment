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
local mat_slider = require("widget.material.slider")
local mat_icon = require("widget.material.icon")
local icons = require("theme.icons")
local watch = require("awful.widget.watch")
local dpi = require("beautiful").xresources.apply_dpi
local config = require("config")

local biggest_upload = 1
local biggest_download = 1

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

watch(
  "sh /etc/xdg/awesome/net-speed.sh",
  config.network_poll,
  function(_, stdout)
    local download_text, upload_text = stdout:match("(.*);(.*)")
    value_up:set_markup_silently(upload_text)
    value_down:set_markup_silently(download_text)
    print("Network download: " .. download_text)
    print("Network upload: " .. upload_text)

    if upload_text:match("M") then
      upload_num = tonumber(upload_text:match("%S+"))
      if upload_num > biggest_upload then
        biggest_upload = upload_num
      end
      network_slider_up:set_value((upload_num / biggest_upload) * 100)
    else
      upload_num = tonumber(upload_text:match("%S+")) / 1000
      network_slider_up:set_value((upload_num / biggest_upload) * 100)
    end

    if download_text:match("M") then
      download_num = tonumber(download_text:match("%S+"))
      if download_num > biggest_download then
        biggest_download = download_num
      end
      network_slider_down:set_value((download_num / biggest_download) * 100)
    else
      download_num = tonumber(download_text:match("%S+")) / 1000
      network_slider_down:set_value((download_num / biggest_download) * 100)
    end

    collectgarbage("collect")
  end
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
