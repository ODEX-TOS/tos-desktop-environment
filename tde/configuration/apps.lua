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
local filesystem = require("gears.filesystem")
local config = require("config")

local function addHash(input)
  if input == nil then
    return nil
  end
  return "#" .. input
end

-- lib-tde to retrieve current theme
local themefile = require("theme.config")
local beautiful = require("beautiful")
local color = beautiful.primary.hue_500
local colorBG = beautiful.primary.hue_700
color = addHash(themefile["primary_hue_500"]) or color
colorBG = addHash(themefile["primary_hue_700"]) or colorBG

local picom = "picom -b --dbus --experimental-backends --config " .. config.getComptonFile()
if general["weak_hardware"] == "1" then
  picom = ""
end

return {
  -- List of apps to start by default on some actions
  default = {
    terminal = os.getenv("TERMINAL") or "st",
    editor = "code-insiders",
    web_browser = "firefox-developer-edition",
    file_manager = "thunar",
    rofi = "rofi -dpi " ..
      screen.primary.dpi ..
        ' -show "Global Search" -modi "Global Search":' ..
          filesystem.get_configuration_dir() ..
            "/configuration/rofi/sidebar/rofi-spotlight.sh -theme " ..
              filesystem.get_configuration_dir() .. "/configuration/rofi/sidebar/rofi.rasi",
    web = "rofi -dpi " ..
      screen.primary.dpi ..
        " -show Search -modi Search:" ..
          filesystem.get_configuration_dir() ..
            "/configuration/rofi/search.py" ..
              " -theme " .. filesystem.get_configuration_dir() .. "/configuration/rofi/sidebar/rofi.rasi",
    rofiappmenu = "bash /etc/xdg/tde/applauncher.sh " .. screen.primary.dpi .. " " .. filesystem.get_configuration_dir(),
    rofiemojimenu = "bash /etc/xdg/tde/emoji.sh " .. screen.primary.dpi,
    rofiwindowswitch = "bash /etc/xdg/tde/application-switch.sh" .. " " .. screen.primary.dpi,
    roficlipboard = "rofi -dpi " ..
      screen.primary.dpi ..
        ' -modi "clipboard:greenclip print" -show clipboard -theme ' ..
          filesystem.get_configuration_dir() .. "/configuration/rofi/appmenu/drun.rasi",
    rofidpimenu = "bash /etc/xdg/tde/dpi.sh",
    rofiwifimenu = "bash /etc/xdg/tde/wifi.sh" .. " " .. screen.primary.dpi,
    lock = "light-locker-command -l",
    quake = (os.getenv("TERMINAL") or "st") .. " -T QuakeTerminal",
    duplicate_screens = "bash /etc/xdg/tde/xrandr-duplicate.sh"
  },
  -- List of apps to start once on start-up
  run_on_start_up = {
    picom,
    "blueman-applet", -- Bluetooth tray icon
    "xfce4-power-manager", -- Power manager
    'sh -c "/etc/xdg/tde/firefox-color.sh \'' .. color .. "' '" .. colorBG .. '\'"',
    "xrdb $HOME/.Xresources"
  },
  bins = {
    coverUpdate = require("lib-tde.extractcover").extractalbum,
    full_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" full "' .. color .. '"',
    full_blank_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" full_blank',
    area_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" area "' .. color .. '"',
    area_blank_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" area_blank',
    window_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" window "' .. color .. '"',
    window_blank_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" window_blank'
  }
}
