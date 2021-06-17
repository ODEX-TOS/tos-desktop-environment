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
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local mat_colors = require("theme.mat-colors")
local configWriter = require("lib-tde.config-writer")
local card = require("lib-widget.card")
local signals = require("lib-tde.signals")
local button = require("lib-widget.button")

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

-- We need to expose these variables in a more "global" scope
-- This way we can update the colors on the fly
-- The active color pallet
local activePrimary = beautiful.accent
local activePrimaryName = "purple"
local activeBackground = beautiful.background
local activeBackgroundName = "blue_grey"

-- the 2 big buttons that decide where the color pallet will be applied
local primaryButton = nil
local backgroundButton = nil
-- the save button that updates the color pallet
local save = nil

local colorModeIsPrimary = true

local widgets = {}
local sliders = {}

-- refreshing all widgets to contain the new colors
local function refresh()
  for _, slider in ipairs(sliders) do
    slider.bar_color = activeBackground.hue_700 .. beautiful.background_transparency
  end
  if colorModeIsPrimary then
    primaryButton.bg = activePrimary.hue_800
    backgroundButton.bg = activeBackground.hue_700
  else
    primaryButton.bg = activePrimary.hue_600
    backgroundButton.bg = activeBackground.hue_800
  end
  save.bg = activePrimary.hue_600
  primaryButton.update_pallet(activePrimary)
  backgroundButton.update_pallet(activeBackground)
end

local function create_primary_button()
  local btn =
    button(
    "Primary",
    function()
      print("Changing Primary mode")
      colorModeIsPrimary = true
      primaryButton.bg = activePrimary.hue_800
      backgroundButton.bg = activeBackground.hue_700
      signals.emit_primary_theme_changed(activePrimary)
    end,
    activePrimary,
    nil,
    nil,
    nil,
    true
  )

  return btn
end

local function create_background_button()
  local btn =
    button(
    "Background",
    function()
      print("Changing background mode")
      colorModeIsPrimary = false
      primaryButton.bg = activePrimary.hue_600
      backgroundButton.bg = activeBackground.hue_800
      signals.emit_background_theme_changed(activeBackground)
    end,
    activeBackground,
    nil,
    nil,
    nil,
    true
  )

  return btn
end

-- the font_black option is always optional and tells use if the font color must be black (because the background color is otherwise unreadable)
local function make_color_entry(name, slide, font_black)
  local pallet = mat_colors[name] or mat_colors["purple"]

  local color = beautiful.fg_white
  if font_black then
    color = beautiful.fg_black
  end

  local text =
    wibox.widget {
    markup = '<span foreground="' .. color .. '">' .. gears.string.xml_escape(name) .. "</span>",
    widget = wibox.widget.textbox
  }

  local btn =
    button(
    text,
    function()
      print("Updating theme to: " .. name)
      if colorModeIsPrimary then
        activePrimary = pallet
        activePrimaryName = name
        signals.emit_primary_theme_changed(activePrimary)
      else
        activeBackground = pallet
        activeBackgroundName = name
        signals.emit_background_theme_changed(activeBackground)
      end
      refresh()
    end,
    pallet,
    nil,
    nil,
    nil,
    true
  )

  btn.forced_width = dpi(110)

  table.insert(widgets, btn)

  local slider =
    wibox.widget {
    bar_shape = gears.shape.rounded_rect,
    bar_height = dpi(25),
    bar_color = beautiful.background.hue_700 .. beautiful.background_transparency,
    handle_color = pallet.hue_500,
    bar_active_color = pallet.hue_500,
    handle_shape = gears.shape.circle,
    handle_border_color = "#00000012",
    handle_border_width = 1,
    handle_width = dpi(30),
    value = slide,
    widget = wibox.widget.slider
  }
  table.insert(sliders, slider)
  return wibox.container.margin(
    wibox.widget {
      {
        layout = wibox.container.margin,
        right = m,
        btn
      },
      slider,
      forced_width = (settings_width - settings_nw) / 2,
      forced_height = settings_index,
      layout = wibox.layout.fixed.horizontal
    },
    m,
    m,
    m,
    m
  )
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Theme"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  save =
    button(
    "Save",
    function()
      print("Saving colors")
      local location = os.getenv("HOME") .. "/.config/tos/colors.conf"
      configWriter.update_entry(location, "primary", activePrimaryName)
      configWriter.update_entry(location, "accent", activePrimaryName)
      configWriter.update_entry(location, "background", activeBackgroundName)
      -- restart TDE
      awesome.restart()
    end
  )

  local theme_card = card()

  local theme_settings_body =
    wibox.widget {
    layout = wibox.layout.flex.horizontal,
    wibox.container.margin(
      {
        layout = wibox.layout.flex.vertical,
        make_color_entry("red", 20),
        make_color_entry("pink", 40),
        make_color_entry("purple", 60),
        make_color_entry("hue_purple", 80),
        make_color_entry("indigo", 60),
        make_color_entry("blue", 40),
        make_color_entry("hue_blue", 20),
        make_color_entry("cyan", 40),
        make_color_entry("teal", 60),
        make_color_entry("green", 80),
        make_color_entry("hue_green", 60)
      },
      m,
      m,
      m,
      m
    ),
    wibox.container.margin(
      {
        layout = wibox.layout.flex.vertical,
        make_color_entry("lime", 40),
        make_color_entry("yellow", 20),
        make_color_entry("amber", 40),
        make_color_entry("orange", 60),
        make_color_entry("deep_orange", 80),
        make_color_entry("brown", 60),
        make_color_entry("grey", 40),
        make_color_entry("blue_grey", 20),
        make_color_entry("black", 40),
        make_color_entry("light", 60, true)
      },
      m,
      m,
      m,
      m
    )
  }

  theme_card.update_body(theme_settings_body)

  primaryButton = create_primary_button()
  backgroundButton = create_background_button()
  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      wibox.widget {
        layout = wibox.layout.flex.horizontal,
        wibox.container.margin(primaryButton, 0, settings_index, 0, 0),
        nil,
        backgroundButton
      },
      wibox.container.margin(theme_card, 0, 0, dpi(10), dpi(10)),
      save
    }
  }

  return view
end
