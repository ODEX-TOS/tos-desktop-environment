--[[
--MIT License
--
--Copyright (c) 2019 PapyElGringo
--Copyright (c) 2019 Tom Meyers
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
local mat_colors = require("theme.mat-colors")
local theme_dir = filesystem.get_configuration_dir() .. "/theme"
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local gtk = require("beautiful.gtk")
local config = require("theme.config")
local darklight = require("theme.icons.dark-light")
local file_exists = require("lib-tde.file").exists

local theme = {}
theme.icons = theme_dir .. "/icons/"
theme.font = "Roboto medium 10"
theme.monitor_font = "Roboto medium 50"
theme.gtk = gtk.get_theme_variables()
theme.background_transparency = config["background_transparent"] or "66"

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then
    return "/usr/share/backgrounds/tos/default.png"
  end
  lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

function color(value)
  if value == nil then
    return nil
  end
  return "#" .. value
end

function loadtheme(standard, override, prefix)
  standard["hue_50"] = color(override[prefix .. "hue_50"]) or standard["hue_50"]
  standard["hue_100"] = color(override[prefix .. "hue_100"]) or standard["hue_100"]
  standard["hue_200"] = color(override[prefix .. "hue_200"]) or standard["hue_200"]
  standard["hue_300"] = color(override[prefix .. "hue_300"]) or standard["hue_300"]
  standard["hue_400"] = color(override[prefix .. "hue_400"]) or standard["hue_400"]
  standard["hue_500"] = color(override[prefix .. "hue_500"]) or standard["hue_500"]
  standard["hue_600"] = color(override[prefix .. "hue_600"]) or standard["hue_600"]
  standard["hue_700"] = color(override[prefix .. "hue_700"]) or standard["hue_700"]
  standard["hue_800"] = color(override[prefix .. "hue_800"]) or standard["hue_800"]
  standard["hue_900"] = color(override[prefix .. "hue_900"]) or standard["hue_900"]
  standard["hue_A100"] = color(override[prefix .. "hue_A100"]) or standard["hue_A100"]
  standard["hue_A200"] = color(override[prefix .. "hue_A200"]) or standard["hue_A200"]
  standard["hue_A400"] = color(override[prefix .. "hue_A400"]) or standard["hue_A400"]
  standard["hue_A700"] = color(override[prefix .. "hue_A700"]) or standard["hue_A700"]
  return standard
end

local function darkLightSwitcher(dark, light)
  if config["background"] == "light" then
    return light
  end
  return dark
end
-- Colors Pallets

-- Custom
theme.custom = "#ffffff"

-- Primary
theme.primary = mat_colors[config["primary"]] or mat_colors.purple

-- Accent
theme.accent = mat_colors[config["accent"]] or mat_colors.hue_purple

-- Background
theme.background = mat_colors[config["background"]] or mat_colors.grey

theme.primary = loadtheme(theme.primary, config, "primary_")
theme.accent = loadtheme(theme.accent, config, "accent_")
theme.background = loadtheme(theme.background, config, "background_")
theme.text = color(config["text"]) or "#FFFFFF"

-- system stat charts in settings app
theme.cpu_bar = color(config["cpu_bar"]) or "#f90273"
theme.ram_bar = color(config["ram_bar"]) or "#017AFC"
theme.disk_bar = color(config["disk_bar"]) or "#fdc400"

local awesome_overrides = function(theme)
  theme.dir = "/etc/xdg/awesome/theme"
  --theme.dir             = os.getenv("HOME") .. "/code/awesome-pro/themes/pro-dark"

  theme.icons = theme.dir .. "/icons/"
  local command = "tos theme list | head -n1 > /tmp/theme.txt"

  awful.spawn.easy_async_with_shell(
    command,
    function()
      awful.spawn.easy_async_with_shell(
        "feh --bg-scale $(cat /tmp/theme.txt)",
        function(out)
        end
      )
    end
  )

  --theme.wallpaper = '~/Pictures/simple.png'
  theme.wallpaper = lines_from("~/.config/tos/theme")[2]
  --theme.wallpaper = '#e0e0e0'
  theme.font = "Roboto medium 10"
  theme.title_font = "Roboto medium 14"

  theme.fg_normal = color(config["foreground_normal"]) or darkLightSwitcher("#ffffffde", "#000000de")

  theme.fg_focus = color(config["foreground_focus"]) or darkLightSwitcher("#e4e4e4", "#343434")
  theme.fg_urgent = color(config["foreground_urgent"]) or darkLightSwitcher("#CC9393", "#994545")
  theme.bat_fg_critical = color(config["foreground_critical"]) or darkLightSwitcher("#232323", "#BEBEBE3")

  theme.bg_normal = theme.background.hue_800
  theme.bg_focus = color(config["background_focus"]) or "#5a5a5a"
  theme.bg_urgent = color(config["background_urgent"]) or "#3F3F3F"
  theme.bg_systray = theme.background.hue_800

  theme.bg_modal = color(config["background_modal"]) or "#ffffff20"
  theme.bg_modal_title = color(config["background_modal_title"]) or "#ffffff30"
  theme.bg_settings_display_number = "#00000070"
  -- Borders

  theme.border_width = dpi(2)
  theme.border_normal = theme.background.hue_800
  theme.border_focus = theme.primary.hue_300
  theme.border_marked = color(config["border_marked"]) or "#CC9393"

  -- Notification
  theme.transparent = "#00000000"
  theme.notification_position = "top_right"
  theme.notification_bg = theme.transparent
  theme.notification_margin = dpi(5)
  theme.notification_border_width = dpi(0)
  theme.notification_border_color = theme.transparent
  theme.notification_spacing = dpi(0)
  theme.notification_icon_resize_strategy = "center"
  theme.notification_icon_size = dpi(32)

  -- UI Groups

  theme.groups_title_bg = theme.bg_modal_title
  theme.groups_bg = theme.bg_modal
  theme.groups_radius = dpi(9)

  -- Menu

  theme.menu_height = dpi(16)
  theme.menu_width = dpi(160)

  -- Tooltips
  theme.tooltip_bg = (color(config["tooltip_bg"]) or "#232323") .. "99"
  --theme.tooltip_border_color = '#232323'
  theme.tooltip_border_width = 0
  theme.tooltip_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(6))
  end

  -- Layout

  theme.layout_max = darklight(theme.icons .. "layouts/arrow-expand-all.png")
  theme.layout_tile = darklight(theme.icons .. "layouts/view-quilt.png")
  theme.layout_dwindle = darklight(theme.icons .. "layouts/dwindle.png")
  theme.layout_floating = darklight(theme.icons .. "layouts/floating.png")
  theme.layout_fairv = darklight(theme.icons .. "layouts/fair.png")
  theme.layout_magnifier = darklight(theme.icons .. "layouts/magnifier.png")

  -- Taglist
  taglist_occupied = color(config["taglist_occupied"]) or "#ffffff"
  theme.taglist_bg_empty = theme.background.hue_800 .. "99"
  theme.taglist_bg_occupied =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        taglist_occupied ..
          ":0.11," .. taglist_occupied .. ":0.11," .. theme.background.hue_800 .. "99" .. theme.background.hue_800
  theme.taglist_bg_urgent =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        theme.accent.hue_500 ..
          ":0.11," .. theme.accent.hue_500 .. ":0.11," .. theme.background.hue_800 .. ":1," .. theme.background.hue_800
  theme.taglist_bg_focus =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        theme.primary.hue_500 ..
          ":0.11," ..
            theme.primary.hue_500 ..
              ":0.11," .. theme.background.hue_800 .. ":1," --[[':1,']] .. theme.background.hue_800

  -- Tasklist

  theme.tasklist_font = "Roboto Regular 10"
  theme.tasklist_bg_normal = theme.background.hue_800 .. "99"
  theme.tasklist_bg_focus =
    "linear:0,0:0," ..
    dpi(48) ..
      ":0," ..
        theme.background.hue_800 ..
          ":0.95," .. theme.background.hue_800 .. ":0.95," .. theme.fg_normal .. ":1," .. theme.fg_normal
  theme.tasklist_bg_urgent = theme.primary.hue_800
  theme.tasklist_fg_focus = "#DDDDDD"
  theme.tasklist_fg_urgent = theme.fg_normal
  theme.tasklist_fg_normal = "#AAAAAA"

  theme.icon_theme = "Papirus-Dark"

  local out =
    io.popen(
    "if [[ -f ~/.config/gtk-3.0/settings.ini ]]; " ..
      [[then grep "gtk-icon-theme-name" ~/.config/gtk-3.0/settings.ini | awk -F= '{printf $2}'; fi]]
  ):read("*all")
  if out ~= nil then
    theme.icon_theme = out
  end
  --Client
  theme.border_width = dpi(0)
  theme.border_focus = theme.primary.hue_500
  theme.border_normal = theme.background.hue_800
end
return {
  theme = theme,
  awesome_overrides = awesome_overrides
}
