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
local signals = require('lib-tde.signals')

local theme = {}
theme.icons = theme_dir .. "/icons/"
theme.smallfont = "Roboto medium 7"
theme.font = "Roboto medium 10"
theme.monitor_font = "Roboto medium 16"
theme.font_type = "Roboto medium"
theme.gtk = gtk.get_theme_variables()
theme.background_transparency = config["background_transparent"] or "66"

local function color(value)
  if value == nil then
    return nil
  end

  if tonumber(value, 16) ~= nil then
    return "#" .. value
  end

  if type(value) == "string" then
    -- probably a HEX that already starts with #
    if value:sub(1,1) == "#" then
      return value
    end

    -- Lets assume it is a formated gradient
    -- <type>:<sx>,<sy>:<ex>,<ey>:<begin>:<hex>:<end>:<hex>
    local _type, sx, sy, ex, ey, _begin, _begin_hex, _end, end_hex =
    string.match(value, "([a-z]+):(%d+),(%d+):(%d+),(%d+):(%d+),([a-fA-F0-9]+):(%d+),([a-fA-F0-9]+)")

    if _type == nil or sx == nil or sy == nil or ex == nil or ey == nil or _begin == nil
    or _begin_hex == nil or _end == nil or end_hex == nil then
      return nil
    end

    return string.format("%s:%d,%d:%d,%d:%d,#%s:%d,#%s", _type, sx, sy, ex, ey, _begin, _begin_hex, _end, end_hex)
  end
end

local function loadtheme(standard, override, prefix, bFromSettingState, settings_state_pallet)
  if bFromSettingState then
    return settings_state_pallet
  end
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

local function add_taglist(tde_theme)
  taglist_occupied = color(config["taglist_occupied"]) or "#ffffff"
  tde_theme.taglist_bg_empty = "#00000000"
  tde_theme.taglist_bg_occupied =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        taglist_occupied ..
          ":0.11," ..
            taglist_occupied .. ":0.11,#00000000:1,#00000000"
  tde_theme.taglist_bg_urgent =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        tde_theme.accent.hue_500 ..
          ":0.11," ..
            tde_theme.accent.hue_500 ..
              ":0.11,#00000000:1,#00000000"
  tde_theme.taglist_bg_focus =
    "linear:0," ..
    dpi(48) ..
      ":0,0:0," ..
        tde_theme.primary.hue_500 ..
          ":0.11," ..
            tde_theme.primary.hue_500 ..
            ":0.11,#00000000:1,#00000000"

  return tde_theme
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

theme.primary = loadtheme(theme.primary, config, "primary_", _G.save_state.theming.custom_primary_theme, _G.save_state.theming.primary_theme)
theme.accent = loadtheme(theme.accent, config, "accent_", _G.save_state.theming.custom_primary_theme, _G.save_state.theming.primary_theme)
theme.background = loadtheme(theme.background, config, "background_", _G.save_state.theming.custom_background_theme, _G.save_state.theming.background_theme)
theme.text = color(config["text"]) or "#FFFFFF"

theme.groups_radius = dpi(10)

-- system stat charts in settings app
theme.cpu_bar = color(config["cpu_bar"]) or "#f90273"
theme.ram_bar = color(config["ram_bar"]) or "#017AFC"
theme.disk_bar = color(config["disk_bar"]) or "#fdc400"

local tde_overrides = function(tde_theme)
  tde_theme.dir = "/etc/xdg/tde/theme"
  --theme.dir             = os.getenv("HOME") .. "/code/tde-pro/themes/pro-dark"

  tde_theme.icons = tde_theme.dir .. "/icons/"

  tde_theme.wallpaper = "/usr/share/backgrounds/tos/default.jpg"
  tde_theme.font = "Roboto medium 10"
  tde_theme.title_font = "Roboto medium 14"

  tde_theme.fg_white = "#ffffffde"
  tde_theme.fg_black = "#292929"
  tde_theme.fg_normal =
    color(config["foreground_normal"]) or darkLightSwitcher(tde_theme.fg_white, tde_theme.fg_black)

  tde_theme.fg_focus = color(config["foreground_focus"]) or darkLightSwitcher("#e4e4e4", "#343434")
  tde_theme.fg_urgent = color(config["foreground_urgent"]) or darkLightSwitcher("#CC9393", "#994545")
  tde_theme.bat_fg_critical = color(config["foreground_critical"]) or darkLightSwitcher("#232323", "#BEBEBE3")

  tde_theme.bg_normal = tde_theme.background.hue_800 .. tde_theme.background_transparency
  tde_theme.bg_focus = color(config["background_focus"]) or "#5a5a5a"
  tde_theme.bg_urgent = color(config["background_urgent"]) or "#3F3F3F"
  tde_theme.bg_systray = tde_theme.background.hue_800 .. tde_theme.background_transparency

  tde_theme.bg_modal = color(config["background_modal"]) or darkLightSwitcher("#ffffff35", "#ffffffA0")
  tde_theme.bg_modal_title = color(config["background_modal_title"]) or darkLightSwitcher("#ffffff55", "#ffffffD0")
  tde_theme.bg_settings_display_number = "#00000070"
  -- Borders

  tde_theme.border_width = dpi(2)
  tde_theme.border_normal = tde_theme.background.hue_800 .. tde_theme.background_transparency
  tde_theme.border_focus = tde_theme.primary.hue_300
  tde_theme.border_marked = color(config["border_marked"]) or "#CC9393"

  -- Notification
  tde_theme.transparent = "#00000000"
  tde_theme.notification_position = "top_right"
  tde_theme.notification_bg = tde_theme.transparent
  tde_theme.notification_margin = dpi(5)
  tde_theme.notification_border_width = dpi(0)
  tde_theme.notification_border_color = tde_theme.transparent
  tde_theme.notification_spacing = dpi(10)
  tde_theme.notification_icon_resize_strategy = "center"
  tde_theme.notification_icon_size = dpi(32)

  -- UI Groups

  tde_theme.groups_title_bg = tde_theme.bg_modal_title
  tde_theme.groups_bg = tde_theme.bg_modal
  tde_theme.groups_radius = dpi(10)

  -- Menu

  tde_theme.menu_height = dpi(16)
  tde_theme.menu_width = dpi(160)

  -- Tooltips
  tde_theme.tooltip_bg = (color(config["tooltip_bg"]) or tde_theme.bg_normal)
  --tde_theme.tooltip_border_color = '#232323'
  tde_theme.tooltip_border_width = 0
  tde_theme.tooltip_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(6))
  end

  -- Layout

  tde_theme.layout_max = darklight(tde_theme.icons .. "layouts/arrow-expand-all.png")
  tde_theme.layout_tile = darklight(tde_theme.icons .. "layouts/view-quilt.png")
  tde_theme.layout_dwindle = darklight(tde_theme.icons .. "layouts/dwindle.png")
  tde_theme.layout_floating = darklight(tde_theme.icons .. "layouts/floating.png")
  tde_theme.layout_fairv = darklight(tde_theme.icons .. "layouts/fair.png")
  tde_theme.layout_fairh = darklight(tde_theme.icons .. "layouts/fairh.png")
  tde_theme.layout_magnifier = darklight(tde_theme.icons .. "layouts/magnifier.png")

  -- Taglist
  signals.connect_background_theme_changed(function (pallet)
    beautiful.background = pallet
    tde_theme.background = pallet
    tde_theme.bg_normal = tde_theme.background.hue_800 .. tde_theme.background_transparency
    tde_theme.tooltip_bg = (color(config["tooltip_bg"]) or tde_theme.bg_normal)
    tde_theme = add_taglist(tde_theme)
  end)

  signals.connect_primary_theme_changed(function (pallet)
    beautiful.primary = pallet
    beautiful.accent = pallet
    tde_theme.primary = pallet
    tde_theme.accent = pallet
    tde_theme = add_taglist(tde_theme)
  end)

  tde_theme = add_taglist(tde_theme)

  -- Tasklist

  tde_theme.tasklist_font = "Roboto Regular 10"
  tde_theme.tasklist_bg_normal = tde_theme.bg_modal .. "99"
  tde_theme.tasklist_bg_focus =
    "linear:0,0:0," ..
    dpi(48) ..
      ":0," ..
      tde_theme.bg_modal ..
          ":0.95," ..
          tde_theme.bg_modal.. ":0.95," .. tde_theme.fg_normal .. ":1," .. tde_theme.fg_normal
  tde_theme.tasklist_bg_urgent = tde_theme.primary.hue_800
  tde_theme.tasklist_fg_focus = tde_theme.fg_focus
  tde_theme.tasklist_fg_urgent = tde_theme.fg_urgent
  tde_theme.tasklist_fg_normal = tde_theme.fg_normal

  tde_theme.icon_theme = "Papirus-Dark"

  -- TODO: use native functions instead of a shell script
  local out_f =
    io.popen(
    "if [ -f ~/.config/gtk-3.0/settings.ini ]; " ..
      [[then grep "gtk-icon-theme-name" ~/.config/gtk-3.0/settings.ini | awk -F= '{printf $2}'; fi]]
  )
  local out = out_f:read("*all")
  out_f:close()

  if out ~= nil then
    tde_theme.icon_theme = out
  end
  --Client
  tde_theme.border_width = dpi(0)
  tde_theme.border_focus = tde_theme.primary.hue_500
  tde_theme.border_normal = tde_theme.primary.hue_800
  tde_theme.border_color = tde_theme.primary.hue_500
  tde_theme.snap_bg = tde_theme.primary.hue_700
end
return {
  theme = theme,
  tde_overrides = tde_overrides
}
