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
local slider = require("lib-widget.slider")

local size = require("widget.settings.size")

local m = size.m / 2
local settings_index = size.settings_index
local settings_width = size.settings_width
local settings_nw = size.settings_nw

-- We need to expose these variables in a more "global" scope
-- This way we can update the colors on the fly
-- The active color pallet
local activePrimary = beautiful.primary
local activePrimaryName = color_config["primary"] or "cyan"
local activeBackground = beautiful.background
local activeBackgroundName = color_config["background"] or "grey"

-- the 2 big buttons that decide where the color pallet will be applied
local primaryButton = nil
local backgroundButton = nil
-- the save button that updates the color pallet
local save = nil

local colorModeIsPrimary = true

-- information of the gradient selection instead of full color mode
local gradient_angle = 45
local gradient_lenght = 500
local bGradientSelection = false
local bSelectLeftGradient = false
local left_gradient = mat_colors["cyan"]
local right_gradient = mat_colors["purple"]


local widgets = {}
local sliders = {}
local weak = {}
weak.__mode = "k"
setmetatable(widgets, weak)
setmetatable(sliders, weak)

-- refreshing all widgets to contain the new colors
local function refresh()
  for _, _slider in ipairs(sliders) do
    _slider.bar_color = activeBackground.hue_700 .. beautiful.background_transparency
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
    button({
      body = "Primary",
    callback = function()
      print("Changing Primary mode")
      colorModeIsPrimary = true
      primaryButton.bg = activePrimary.hue_800
      backgroundButton.bg = activeBackground.hue_700
      if not bGradientSelection then
        signals.emit_primary_theme_changed(activePrimary)
      end
    end,
    pallet = activePrimary,
    no_update = true
  })

  return btn
end

local function create_background_button()
  local btn =
    button({
      body = "Background",
      callback = function()
        print("Changing background mode")
        colorModeIsPrimary = false
        primaryButton.bg = activePrimary.hue_600
        backgroundButton.bg = activeBackground.hue_800
        print(activeBackground)
        if not bGradientSelection then
          signals.emit_background_theme_changed(activeBackground)
        end
      end,
      pallet = activeBackground,
      no_update = true
  })

  return btn
end

-- the font_black option is always optional and tells use if the font color must be black (because the background color is otherwise unreadable)
local function make_color_entry(name, slide, font_black)
  local pallet = mat_colors[name] or mat_colors["cyan"]

  local color = beautiful.fg_white
  if font_black then
    color = beautiful.fg_black
  end

  local text =
    wibox.widget {
    markup = '<span foreground="' .. color .. '">' .. gears.string.xml_escape(i18n.translate(name)) .. "</span>",
    widget = wibox.widget.textbox
  }

  local btn =
    button({
    body = text,
    callback = function()
      print("Updating theme to: " .. name)

      if bGradientSelection then
        if bSelectLeftGradient then
          left_gradient = pallet
        else
          right_gradient = pallet
        end
        tde.emit_signal('theme::redraw_gradient')
        return
      end

      if colorModeIsPrimary then
        activePrimary = pallet
        activePrimaryName = name
        signals.emit_primary_theme_changed(activePrimary)
        signals.emit_save_theming_settings(false)
      else
        activeBackground = pallet
        activeBackgroundName = name
        print(activeBackground)
        signals.emit_background_theme_changed(activeBackground)
        signals.emit_save_theming_settings(nil, false)
      end
      refresh()
    end,
    pallet = pallet,
    no_update = true
  })

  btn.forced_height = settings_index - dpi(10)

  btn.forced_width = dpi(110)

  table.insert(widgets, btn)

  local _slider =
    wibox.widget {
    bar_shape = gears.shape.rounded_rect,
    bar_height = settings_index - dpi(10),
    bar_color = activeBackground.hue_700 .. beautiful.background_transparency,
    handle_color = pallet.hue_500,
    bar_active_color = pallet.hue_500,
    handle_shape = gears.shape.circle,
    handle_border_color = "#00000012",
    handle_border_width = 1,
    handle_width = settings_index - dpi(5),
    value = slide,
    widget = wibox.widget.slider
  }
  table.insert(sliders, _slider)
  return wibox.container.margin(
    wibox.widget {
      {
        layout = wibox.container.margin,
        right = m,
        btn
      },
      _slider,
      forced_width = (settings_width - settings_nw) / 2,
      forced_height = settings_index - dpi(5),
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
    button({
      body = "Save",
      callback = function()
        print("Saving colors")
        local location = os.getenv("HOME") .. "/.config/tos/colors.conf"
        configWriter.update_entry(location, "primary", activePrimaryName)
        configWriter.update_entry(location, "accent", activePrimaryName)
        configWriter.update_entry(location, "background", activeBackgroundName)
        -- restart TDE
        tde.restart()
      end
  })

  local theme_card = card()
  local gradient_card = card({title="Gradients"})

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
        make_color_entry("hue_green", 60),
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
    ),
  }

  local function new_gradient_pallet_fnc()
    return mat_colors.gen_gradient(left_gradient, right_gradient, gradient_angle, gradient_lenght)
  end

  local left_gradient_btn = button({
    body = "Select Left color gradient",
    callback = function()
      bGradientSelection = true
      bSelectLeftGradient = true
      root.elements.settings.bg = new_gradient_pallet_fnc().hue_600
    end,
    pallet = left_gradient,
    center = true,
    -- enter callback
    enter_callback = function(btn)
      btn.bg = left_gradient.hue_800
    end,
    -- leave callback
    leave_callback = function(btn)
      btn.bg = left_gradient.hue_600
    end,
    no_update = true
  })

  local right_gradient_btn = button({
    body = "Select Right color gradient",
    callback = function()
      bGradientSelection = true
      bSelectLeftGradient = false
      root.elements.settings.bg = new_gradient_pallet_fnc().hue_600
    end,
    pallet = right_gradient,
    center = true,
    -- enter callback
    enter_callback = function(btn)
      btn.bg = right_gradient.hue_800
    end,
    -- leave callback
    leave_callback = function(btn)
      btn.bg = right_gradient.hue_600
    end,
    no_update = true
  })


  local length_slider = slider({
    max = 1000,
    default = 100,
    callback = function(value)
      gradient_lenght = value
      root.elements.settings.bg = new_gradient_pallet_fnc().hue_600
    end
  })

  local angle_slider = slider({
    max = 360,
    default = 45,
    callback = function(value)
      gradient_angle = value
      root.elements.settings.bg = new_gradient_pallet_fnc().hue_600
    end
  })


  local function ratio(text, _slider)
    local ratio_box = wibox.widget{
      layout = wibox.layout.ratio.horizontal,
      wibox.widget.textbox(i18n.translate(text)),
      wibox.widget.base.empty_widget(),
      _slider
    }

    ratio_box:adjust_ratio(2, 0.10, 0.05, 0.85)

    return ratio_box
  end


  local theme_gradient_settings_body =
  wibox.widget {
  layout = wibox.layout.flex.vertical,
  -- length
  wibox.container.margin(ratio("Length", length_slider), m, m, m, m),
  -- angle
  wibox.container.margin(ratio("Angle", angle_slider), m, m, m, m),
  wibox.container.margin(left_gradient_btn, m, m, m, m),
  wibox.container.margin(right_gradient_btn, m, m, m, m),
  wibox.container.margin(button({body = "Update", callback = function()
    bGradientSelection = false

    local new_gradient = new_gradient_pallet_fnc()
    root.elements.settings.bg = new_gradient.hue_600

    -- TODO persist these changes somehow
    if colorModeIsPrimary then
      activePrimary = new_gradient
      signals.emit_primary_theme_changed(activePrimary)
      signals.emit_save_theming_settings(true)
    else
      activeBackground = new_gradient
      signals.emit_background_theme_changed(activeBackground)
      signals.emit_save_theming_settings(nil, true)
    end

    refresh()
  end}), m, m, m, m)
}

  tde.connect_signal('theme::redraw_gradient', function()
    local new_gradient = new_gradient_pallet_fnc()
    root.elements.settings.bg = new_gradient.hue_600
    right_gradient_btn.bg = right_gradient.hue_800
    left_gradient_btn.bg = left_gradient.hue_800
  end)

  theme_card.update_body(wibox.widget{
    layout = wibox.layout.fixed.vertical,
    theme_settings_body,
    wibox.container.margin(save, dpi(5), dpi(5), dpi(5), dpi(5))
  })
  gradient_card.update_body(theme_gradient_settings_body)

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
      wibox.container.margin(gradient_card, 0, 0, dpi(10), dpi(10)),
    }
  }

  return view
end
