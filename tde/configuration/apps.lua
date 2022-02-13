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
local filehandle = require("lib-tde.file")
local config = require("config")
local hardware = require("lib-tde.hardware-check")
local signals = require('lib-tde.signals')
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local lxsession_data = require("configuration.lxsession")

local term = ""
local term_add_dpi = false

local function get_terminal()
  -- cache as is_in_path is costly
  if term ~= nil and term ~= "" then
    if term_add_dpi then
      return term .. ' -z ' .. tostring(dpi(16))
    end

    return term
  end

  local terminals = {
    "st",
    "kitty",
    "alacritty",
    "konsole",
    "gnome-terminal",
    "xterm"
  }

  -- let's find a terminal for the user
  for _, terminal in ipairs(terminals) do
    if hardware.is_in_path(terminal) then
      term = terminal
      if term == "st" then
        -- In case the terminal is ST, we want to see if it contains the patch for -z, if that is the case we can set the dpi
        local output, _ = hardware.execute("st -h", true)
        if output:find("-z") ~= nil then
          term_add_dpi = true
          return term .. ' -z ' .. tostring(dpi(16))
        else
          term_add_dpi = false
        end
      else
        term_add_dpi = false
      end

      return term
    end
  end

  return "xterm"
end

local function addHash(input)
  if input == nil then
    return nil
  end
  return "#" .. input
end

-- lib-tde to retrieve current theme
local themefile = require("theme.config")

local function update_color()
  local color = beautiful.primary.hue_500
  local colorBG = beautiful.primary.hue_700
  color = addHash(themefile["primary_hue_500"]) or color
  colorBG = addHash(themefile["primary_hue_700"]) or colorBG

  return color, colorBG
end

local color, colorBG = update_color()

signals.connect_primary_theme_changed(function (pallet)
  beautiful.primary = pallet
  beautiful.accent = pallet
  color, colorBG = update_color()
end)

signals.connect_background_theme_changed(function (pallet)
  beautiful.background = pallet
  color, colorBG = update_color()
end)

local picom = "picom -b --dbus --experimental-backends --config " .. config.getComptonFile()
-- if the user has weak hardware then don't use picom with it's blur effects
if general["weak_hardware"] == "1" or hardware.isWeakHardware() then
  picom = ""
end

return {
  -- List of apps to start by default on some actions
  default = {
    terminal = os.getenv("TERMINAL") or get_terminal(),
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
    --lock = "dm-tool lock",
    quake = (os.getenv("TERMINAL") or "st") .. " -T QuakeTerminal",
    duplicate_screens = "bash /etc/xdg/tde/xrandr-duplicate.sh"
  },
  -- List of apps to start once on start-up
  run_on_start_up = {
    picom,
    'sh -c "/etc/xdg/tde/firefox-color.sh \'' .. color .. "' '" .. colorBG .. '\'"',
    "xrdb $HOME/.Xresources"
  },
  -- simular to the `run_on_start_up` table, but instead this holds all applications that continue to run on startup
  daemons = {
    {cmd={"light-locker", "--no-lock-on-suspend"}, tbl= {restart = true, kill_previous = true}},
    {cmd={"lxsession", "-s", "TDE", "-e", "TDE"}, tbl= {restart = true, kill_previous = true, start_cb = function()
      -- Ensure that the ~/.config/lxsession/TDE/desktop.conf file exists
      local dir = os.getenv("HOME") .. "/.config/lxsession/TDE"
      local file = dir .. "/desktop.conf"

      filehandle.dir_create(dir)
      filehandle.overwrite(file, lxsession_data)

    end}},
    {cmd={"greenclip", "daemon"}, tbl= {restart = true, kill_previous = true}},
--
    ---- These are auxilary commands that might be usefull
    {cmd={"kdeconnectd"}, tbl= {restart = true, kill_previous = true}},
    {cmd={"udiskie"}, tbl= {restart = true, kill_previous = true, max_restarts=10}},
    {cmd={"psi-notify"}, tbl= {restart = true, kill_previous = true}},
    {cmd={"numlockx"}, tbl = {restart = false, kill_previous=false}},

    -- touchegg is special as it requires 2 processes, one as root and one as the user
    -- we want to specifically only kill the user process
    -- for that we need a custom kill command and we need to know the UID
    {cmd={"touchegg"}, tbl= {restart = true, kill_previous = true, kill_cmd="pkill -U '" .. tostring(hardware.getUID()) .. "' %s"}}
  },
  bins = function ()
    -- we wrap this in a function since the 'color variable changes in real time'
    return {
      coverUpdate = require("lib-tde.extractcover").extractalbum,
      full_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" full "' .. color .. '"',
      full_blank_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" full_blank',
      area_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" area "' .. color .. '"',
      area_blank_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" area_blank',
      window_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" window "' .. color .. '"',
      window_blank_screenshot = 'sh "/etc/xdg/tde/snapshot.sh" window_blank'
    }
  end
}
