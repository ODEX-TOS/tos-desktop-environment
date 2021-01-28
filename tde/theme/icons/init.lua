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
local leftpanel_icon_theme = "tos" -- Available Themes: 'lines', 'original', 'macos'
local lit_dir = "/etc/xdg/tde/theme/icons/themes/" .. leftpanel_icon_theme

local dir = "/etc/xdg/tde/theme/icons"
local config = require("theme.icons.config")
local theme = require("theme.icons.dark-light")

return {
  --tags
  chrome = theme(config["browser"] or lit_dir .. "/firefox.svg"),
  code = theme(config["code"] or lit_dir .. "/code.svg"),
  social = theme(config["social"] or dir .. "/forum.svg"),
  folder = theme(config["folder"] or lit_dir .. "/folder.svg"),
  music = theme(config["music"] or lit_dir .. "/music.svg"),
  game = theme(config["game"] or lit_dir .. "/google-controller.svg"),
  lab = theme(config["lab"] or lit_dir .. "/flask.svg"),
  terminal = theme(config["terminal"] or lit_dir .. "/terminal.svg"),
  art = theme(config["art"] or lit_dir .. "/art.svg"),
  --others
  menu = theme(config["menu"] or lit_dir .. "/menu.svg"),
  logo = config["logo"] or lit_dir .. "/logo.svg",
  settings = theme(config["settings"] or dir .. "/settings.svg"),
  close = theme(config["close"] or dir .. "/close.svg"),
  logout = theme(config["logout"] or dir .. "/logout.svg"),
  sleep = theme(config["sleep"] or dir .. "/power-sleep.svg"),
  power = theme(config["power"] or dir .. "/power.svg"),
  lock = theme(config["lock"] or dir .. "/lock.svg"),
  restart = theme(config["restart"] or dir .. "/restart.svg"),
  search = theme(config["search"] or dir .. "/magnify.svg"),
  monitor = theme(config["monitor"] or dir .. "/laptop.svg"),
  wifi = theme(config["wifi"] or dir .. "/wifi.svg"),
  wifi_off = theme(config["wifi_off"] or dir .. "/wifi_off.svg"),
  volume = theme(config["volume"] or dir .. "/volume-high.svg"),
  muted = theme(config["muted"] or dir .. "/volume-mute.svg"),
  brightness = theme(config["brightness"] or dir .. "/brightness-7.svg"),
  chart = theme(config["chart"] or dir .. "/chart-areaspline.svg"),
  memory = theme(config["memory"] or dir .. "/memory.svg"),
  harddisk = theme(config["harddisk"] or dir .. "/harddisk.svg"),
  thermometer = theme(config["thermometer"] or dir .. "/thermometer.svg"),
  plus = theme(config["plus"] or dir .. "/plus.svg"),
  minus = theme(config["minus"] or dir .. "/minus.svg"),
  network = theme(config["network"] or dir .. "/network.svg"),
  upload = theme(config["upload"] or dir .. "/upload.svg"),
  download = theme(config["download"] or dir .. "/download.svg"),
  warning = theme(config["warning"] or dir .. "/warning.svg"),
  lan = theme(config["lan"] or dir .. "/lan.svg"),
  lan_off = theme(config["lan_off"] or dir .. "/lan_off.svg"),
  calendar = theme(config["calendar"] or dir .. "/calendar.svg"),
  brush = theme(config["brush"] or dir .. "/brush.svg"),
  bluetooth = theme(config["bluetooth"] or dir .. "/bluetooth.svg"),
  bluetooth_off = theme(config["bluetooth_off"] or dir .. "/bluetooth-off.svg"),
  package = theme("/etc/xdg/tde/widget/package-updater/icons/package.svg"),
  about = theme(dir .. "/info.svg"),
  mouse = theme(dir .. "/mouse.svg"),
  user = theme(dir .. "/user.svg"),
  qr_code = theme(dir .. "/qr_code.svg"),
  --pngs
  unknown = theme(dir .. "/noicon.png")
}
