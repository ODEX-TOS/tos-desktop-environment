local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")
local mat_colors = require("theme.mat-colors")
local configWriter = require("lib-tde.config-writer")

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

-- We need to expose these variables in a more "global" scope
-- This way we can update the colors on the fly
-- The active color pallete
local activePrimary = beautiful.accent
local activePrimaryName = "purple"
local activeBackground = beautiful.background
local activeBackgroundName = "blue_grey"

-- the 2 big buttons that decide where the color pallete will be applied
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
end

local function create_primary_button()
  local button = wibox.container.background()
  button.bg = activePrimary.hue_500
  button.shape = rounded()
  button:connect_signal(
    "mouse::enter",
    function()
      button.bg = activePrimary.hue_600
    end
  )
  button:connect_signal(
    "mouse::leave",
    function()
      button.bg = activePrimary.hue_500
    end
  )
  button:setup {
    layout = wibox.container.place,
    halign = "center",
    wibox.container.margin(wibox.widget.textbox("Primary"), m, m, m / 2, m / 2)
  }
  button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          print("Changing Primary mode")
          colorModeIsPrimary = true
          primaryButton.bg = activePrimary.hue_800
          backgroundButton.bg = activeBackground.hue_700
        end
      )
    )
  )
  return button
end

local function create_background_button()
  local button = wibox.container.background()
  button.bg = activeBackground.hue_800
  button.shape = rounded()
  button:connect_signal(
    "mouse::enter",
    function()
      button.bg = activeBackground.hue_700
    end
  )
  button:connect_signal(
    "mouse::leave",
    function()
      button.bg = activeBackground.hue_800
    end
  )
  button:setup {
    layout = wibox.container.place,
    halign = "center",
    wibox.container.margin(wibox.widget.textbox("Background"), m, m, m / 2, m / 2)
  }
  button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          print("Changing background mode")
          colorModeIsPrimary = false
          primaryButton.bg = activePrimary.hue_600
          backgroundButton.bg = activeBackground.hue_800
        end
      )
    )
  )
  return button
end

local function make_color_entry(name, slide)
  local pallete = mat_colors[name] or mat_colors["purple"]
  local button = wibox.container.background()
  button.bg = pallete.hue_600
  button.shape = rounded()
  button:connect_signal(
    "mouse::enter",
    function()
      button.bg = pallete.hue_800
    end
  )
  button:connect_signal(
    "mouse::leave",
    function()
      button.bg = pallete.hue_600
    end
  )
  button:setup {
    layout = wibox.container.place,
    halign = "center",
    wibox.container.margin(wibox.widget.textbox(name), m, m, m / 2, m / 2)
  }

  button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          print("Updating theme to: " .. name)
          if colorModeIsPrimary then
            activePrimary = pallete
            activePrimaryName = name
          else
            activeBackground = pallete
            activeBackgroundName = name
          end
          refresh()
        end
      )
    )
  )
  table.insert(widgets, button)

  local slider =
    wibox.widget {
    bar_shape = gears.shape.rounded_rect,
    bar_height = dpi(25),
    bar_color = beautiful.background.hue_700 .. beautiful.background_transparency,
    handle_color = pallete.hue_500,
    bar_active_color = pallete.hue_500,
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
        button
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

  local title = wibox.widget.textbox("Theme")
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local close = wibox.widget.imagebox(icons.close)
  close.forced_height = settings_index
  close:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          if root.elements.settings then
            root.elements.settings.close()
          end
        end
      )
    )
  )

  save = wibox.container.background()
  save.bg = activePrimary.hue_500
  save.shape = rounded()
  save:connect_signal(
    "mouse::enter",
    function()
      save.bg = activePrimary.hue_600
    end
  )
  save:connect_signal(
    "mouse::leave",
    function()
      save.bg = activePrimary.hue_500
    end
  )
  save:setup {
    layout = wibox.container.place,
    halign = "center",
    wibox.container.margin(wibox.widget.textbox("Save"), m, m, m / 2, m / 2)
  }
  save:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
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
    )
  )

  primaryButton = create_primary_button()
  backgroundButton = create_background_button()
  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        wibox.container.margin(
          {
            layout = wibox.container.place,
            title
          },
          settings_index * 2
        ),
        close
      },
      {
        layout = wibox.layout.flex.horizontal,
        wibox.container.margin(primaryButton, 0, settings_index, 0, 0),
        nil,
        backgroundButton
      },
      {
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
            make_color_entry("light", 60)
          },
          m,
          m,
          m,
          m
        )
      },
      save
    }
  }

  return view
end
