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
local dpi = beautiful.xresources.apply_dpi
local card = require("lib-widget.card")

local function build(screen)
  local hardware_card = card("Hardware monitor")

  local cpu = require("widget.cpu.cpu-meter")
  local ram = require("widget.ram.ram-meter")
  local temp = require("widget.temperature.temperature-meter")
  local drive = require("widget.harddrive.harddrive-meter")
  local network_up = require("widget.network.network-meter")(true, screen)
  local network_down = require("widget.network.network-meter")(false, screen)

  local body =
    wibox.widget {
    cpu,
    ram,
    temp,
    drive,
    network_up,
    network_down,
    layout = wibox.layout.fixed.vertical
  }
  hardware_card.update_body(body)
  return wibox.container.margin(hardware_card, dpi(20), dpi(20), dpi(20), dpi(20))
end

return build
