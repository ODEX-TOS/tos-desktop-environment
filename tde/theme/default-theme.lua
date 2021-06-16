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
local mat_colors = require("theme.mat-colors")
local theme_dir = filesystem.get_configuration_dir() .. "/theme"
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local gtk = beautiful.gtk
local config = require("theme.config")
local darklight = require("theme.icons.dark-light")
local filehandle = require("lib-tde.file")
local file_exists = filehandle.exists
local signals = require('lib-tde.signals')

local theme = {}
theme.icons = theme_dir .. "/icons/"
theme.smallfont = "Roboto medium 7"
theme.font = "Roboto medium 10"
theme.monitor_font = "Roboto medium 16"
theme.font_type = "Roboto medium"
theme.gtk = gtk.get_theme_variables()
theme.background_transparency = config["background_transparent"] or "66"

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local function lines_from(file)
  if not file_exists(file) then
    return "/usr/share/backgrounds/tos/default.jpg"
  end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

local function color(value)
  if value == nil then
    return nil
  end
  return "#" .. value
end

local function loadtheme(standard, override, prefix)
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

local function add_taglist(awesome_theme)
  taglist_occupied = color(config["taglist_occupied"]) or "#ffffff"
  awesome_theme.taglist_bg_empty = awesome_theme.background.hue_800 .. "99"
  awesome_theme.taglist_bg_occupied =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        taglist_occupied ..
          ":0.11," ..
            taglist_occupied .. ":0.11," .. awesome_theme.background.hue_800 .. "99" .. awesome_theme.background.hue_800
  awesome_theme.taglist_bg_urgent =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        awesome_theme.accent.hue_500 ..
          ":0.11," ..
            awesome_theme.accent.hue_500 ..
              ":0.11," .. awesome_theme.background.hue_800 .. ":1," .. awesome_theme.background.hue_800
  awesome_theme.taglist_bg_focus =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        awesome_theme.primary.hue_500 ..
          ":0.11," ..
            awesome_theme.primary.hue_500 ..
              ":0.11," .. awesome_theme.background.hue_800 .. ":1," --[[':1,']] .. awesome_theme.background.hue_800

  return awesome_theme
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

local awesome_overrides = function(awesome_theme)
  awesome_theme.dir = "/etc/xdg/tde/theme"
  --theme.dir             = os.getenv("HOME") .. "/code/awesome-pro/themes/pro-dark"

  awesome_theme.icons = awesome_theme.dir .. "/icons/"

  local resultset = lines_from(os.getenv("HOME") .. "/.config/tos/theme")
  awesome_theme.wallpaper = resultset[#resultset] or "/usr/share/backgrounds/tos/default.jpg"
  awesome_theme.font = "Roboto medium 10"
  awesome_theme.title_font = "Roboto medium 14"

  awesome_theme.fg_white = "#ffffffde"
  awesome_theme.fg_black = "#292929"
  awesome_theme.fg_normal =
    color(config["foreground_normal"]) or darkLightSwitcher(awesome_theme.fg_white, awesome_theme.fg_black)

  awesome_theme.fg_focus = color(config["foreground_focus"]) or darkLightSwitcher("#e4e4e4", "#343434")
  awesome_theme.fg_urgent = color(config["foreground_urgent"]) or darkLightSwitcher("#CC9393", "#994545")
  awesome_theme.bat_fg_critical = color(config["foreground_critical"]) or darkLightSwitcher("#232323", "#BEBEBE3")

  awesome_theme.bg_normal = awesome_theme.background.hue_800
  awesome_theme.bg_focus = color(config["background_focus"]) or "#5a5a5a"
  awesome_theme.bg_urgent = color(config["background_urgent"]) or "#3F3F3F"
  awesome_theme.bg_systray = awesome_theme.background.hue_800

  awesome_theme.bg_modal = color(config["background_modal"]) or darkLightSwitcher("#ffffff35", "#ffffffA0")
  awesome_theme.bg_modal_title = color(config["background_modal_title"]) or darkLightSwitcher("#ffffff55", "#ffffffD0")
  awesome_theme.bg_settings_display_number = "#00000070"
  -- Borders

  awesome_theme.border_width = dpi(2)
  awesome_theme.border_normal = awesome_theme.background.hue_800
  awesome_theme.border_focus = awesome_theme.primary.hue_300
  awesome_theme.border_marked = color(config["border_marked"]) or "#CC9393"

  -- Notification
  awesome_theme.transparent = "#00000000"
  awesome_theme.notification_position = "top_right"
  awesome_theme.notification_bg = awesome_theme.transparent
  awesome_theme.notification_margin = dpi(5)
  awesome_theme.notification_border_width = dpi(0)
  awesome_theme.notification_border_color = awesome_theme.transparent
  awesome_theme.notification_spacing = dpi(0)
  awesome_theme.notification_icon_resize_strategy = "center"
  awesome_theme.notification_icon_size = dpi(32)

  -- UI Groups

  awesome_theme.groups_title_bg = awesome_theme.bg_modal_title
  awesome_theme.groups_bg = awesome_theme.bg_modal
  awesome_theme.groups_radius = dpi(9)

  -- Menu

  awesome_theme.menu_height = dpi(16)
  awesome_theme.menu_width = dpi(160)

  -- Tooltips
  awesome_theme.tooltip_bg = (color(config["tooltip_bg"]) or awesome_theme.bg_normal)
  --awesome_theme.tooltip_border_color = '#232323'
  awesome_theme.tooltip_border_width = 0
  awesome_theme.tooltip_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(6))
  end

  -- Layout

  awesome_theme.layout_max = darklight(awesome_theme.icons .. "layouts/arrow-expand-all.png")
  awesome_theme.layout_tile = darklight(awesome_theme.icons .. "layouts/view-quilt.png")
  awesome_theme.layout_dwindle = darklight(awesome_theme.icons .. "layouts/dwindle.png")
  awesome_theme.layout_floating = darklight(awesome_theme.icons .. "layouts/floating.png")
  awesome_theme.layout_fairv = darklight(awesome_theme.icons .. "layouts/fair.png")
  awesome_theme.layout_fairh = darklight(awesome_theme.icons .. "layouts/fairh.png")
  awesome_theme.layout_magnifier = darklight(awesome_theme.icons .. "layouts/magnifier.png")

  -- Taglist
  signals.connect_background_theme_changed(function (pallet)
    beautiful.background = pallet
    awesome_theme.background = pallet
    awesome_theme = add_taglist(awesome_theme)
  end)

  signals.connect_primary_theme_changed(function (pallet)
    beautiful.primary = pallet
    beautiful.accent = pallet
    awesome_theme.primary = pallet
    awesome_theme.accent = pallet
    awesome_theme = add_taglist(awesome_theme)
  end)

  awesome_theme = add_taglist(awesome_theme)

  -- Tasklist

  awesome_theme.tasklist_font = "Roboto Regular 10"
  awesome_theme.tasklist_bg_normal = awesome_theme.background.hue_800 .. "99"
  awesome_theme.tasklist_bg_focus =
    "linear:0,0:0," ..
    dpi(48) ..
      ":0," ..
        awesome_theme.background.hue_800 ..
          ":0.95," ..
            awesome_theme.background.hue_800 .. ":0.95," .. awesome_theme.fg_normal .. ":1," .. awesome_theme.fg_normal
  awesome_theme.tasklist_bg_urgent = awesome_theme.primary.hue_800
  awesome_theme.tasklist_fg_focus = awesome_theme.fg_focus
  awesome_theme.tasklist_fg_urgent = awesome_theme.fg_urgent
  awesome_theme.tasklist_fg_normal = awesome_theme.fg_normal

  awesome_theme.icon_theme = "Papirus-Dark"

  -- TODO: use native functions instead of a shell script
  local out =
    io.popen(
    "if [ -f ~/.config/gtk-3.0/settings.ini ]; " ..
      [[then grep "gtk-icon-theme-name" ~/.config/gtk-3.0/settings.ini | awk -F= '{printf $2}'; fi]]
  ):read("*all")
  if out ~= nil then
    awesome_theme.icon_theme = out
  end
  --Client
  awesome_theme.border_width = dpi(0)
  awesome_theme.border_focus = awesome_theme.primary.hue_500
  awesome_theme.border_normal = awesome_theme.primary.hue_800
  awesome_theme.border_color = awesome_theme.primary.hue_500
  awesome_theme.snap_bg = awesome_theme.primary.hue_700
end
return {
  theme = theme,
  awesome_overrides = awesome_overrides
}
