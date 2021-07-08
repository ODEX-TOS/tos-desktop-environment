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
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local icons = require("theme.icons")
local signals = require("lib-tde.signals")
local slider = require("lib-widget.slider")
local checkbox = require("lib-widget.checkbox")
local card = require("lib-widget.card")
local volume = require("lib-tde.volume")
local button = require("lib-widget.button")
local mat_icon_button = require("widget.material.icon-button")
local mat_icon = require("widget.material.icon")
local sound = require("lib-tde.sound").play_sound
local scrollbox = require("lib-widget.scrollbox")


local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

local scrollbox_body = {}
local active_sr
local bIsSink = false

local NORMAL_MODE = 1
local PORT_MODE = 2

local DISPLAY_MODE = NORMAL_MODE

local active_pallet = beautiful.primary

signals.connect_primary_theme_changed(
  function(pallete)
    active_pallet = pallete
  end
)

local refresh = function()
end

local mic_test_start_message="Test microphone"
local mic_test_stop_message="Stop"
local mic_test_pid=-1

local function kill_mic_pid()
  local cmd = "pkill -P " .. tostring(mic_test_pid)
  print(cmd)
  awful.spawn(cmd)
  mic_test_pid=-1
  refresh()
end

signals.connect_exit(function ()
  if not (mic_test_pid == -1) then
    kill_mic_pid()
  end
end)

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Media"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local vol_heading = wibox.widget.textbox(i18n.translate("Volume"))
  vol_heading.font = beautiful.title_font

  local vol_footer = wibox.widget.textbox(i18n.translate("test"))
  vol_footer.font = beautiful.font
  vol_footer.align = "right"

  local mic_footer = wibox.widget.textbox(i18n.translate("test"))
  mic_footer.font = beautiful.font
  mic_footer.align = "right"

  local vol_slider =
    slider(
    0,
    100,
    1,
    _G.save_state.volume,
    function(value)
      signals.emit_volume(value)
    end
  )

  local mic_slider =
  slider(
  0,
  100,
  1,
  _G.save_state.mic_volume,
  function(value)
    signals.emit_mic_volume(value)
  end
)

  local hardware_only_volume_checbox = checkbox(_G.save_state.hardware_only_volume, function (checked)
    signals.emit_volume_is_controlled_in_software(not checked)
  end)

  signals.connect_volume(
    function(value)
      local number = tonumber(value)
      if not (number == vol_slider.value) then
        vol_slider.update(tonumber(value) or 0)
      end
    end
  )

  signals.connect_mic_volume(
    function(value)
      local number = tonumber(value)
      if not (number == mic_slider.value) then
        mic_slider.update(tonumber(value) or 0)
      end
    end
  )

  local function create_volume_widget(button_icon, text, obj, set_function)
    local button_wgt = mat_icon_button(mat_icon(button_icon, dpi(25)))
    button_wgt:buttons(
      gears.table.join(
        awful.button(
          {},
          1,
          nil,
          function()
            print("Setting default sink to: " .. obj.sink)
            set_function(obj.sink)
            refresh()
          end
        )
      )
    )

    return wibox.widget {
      wibox.container.margin(
        wibox.widget {
          widget = wibox.widget.textbox,
          text = text,
          font = beautiful.font,
          forced_width = (((settings_width - settings_nw) / 2) - (m * 8) - dpi(25))
        },
        dpi(10),
        dpi(10),
        dpi(10),
        dpi(10)
      ),
      nil,
      button_wgt,
      forced_height = settings_index,
      layout = wibox.layout.align.horizontal
    }
  end

  local function create_sink_widget(sink)
    return create_volume_widget(icons.volume, sink.name, sink, function(_id)
      active_sr = sink
      bIsSink = true

      volume.set_default_sink(_id)

      if #sink.available_ports > 1 then
        DISPLAY_MODE = PORT_MODE
        refresh()
      end
    end)
  end

  local function create_source_widget(source)
    return create_volume_widget(icons.microphone, source.name, source, function(_id)
      active_sr = source
      bIsSink = false

      volume.set_default_source(_id)
      if #source.available_ports > 1 then
        DISPLAY_MODE = PORT_MODE
        refresh()
      end
    end)
  end

  local body = wibox.layout.flex.horizontal()

  local function generate_port_options(source, isSink)
    body.children = {}

    local p_card = card(source.name)
    local _body = wibox.layout.fixed.vertical()
    local vertical = wibox.layout.fixed.vertical()


    for _, _port in ipairs(source.available_ports) do
      _body:add(wibox.container.margin(button(
        _port, function ()

          if isSink then
            volume.set_sink_port(source.id, _port)
          else
            volume.set_source_port(source.id, _port)
          end

          DISPLAY_MODE = NORMAL_MODE
          refresh()
        end
      ), m,m,m,m))
    end

    p_card.update_body(_body)

    vertical:add(button('Back', function ()
      DISPLAY_MODE = NORMAL_MODE
      refresh()
    end))
    vertical:add(wibox.container.margin(p_card, 0, 0, m, 0))

    body:add(vertical)
  end

  local function generate_sink_setting_body(sinks, sources, _, _)
    body.children = {}

    local sink_children = wibox.layout.fixed.vertical()
    local source_children = wibox.layout.fixed.vertical()

    for _, sink in ipairs(sinks) do
      sink_children:add(create_sink_widget(sink))
    end

    for _, source in ipairs(sources) do
        source_children:add(create_source_widget(source))
    end

    if #sink_children.children == 0 then
      sink_children:add(
        wibox.widget {
          text = i18n.translate("No extra output found"),
          align = "center",
          valign = "center",
          font = beautiful.font,
          widget = wibox.widget.textbox
        }
      )
    end

    if #source_children.children == 0 then
      source_children:add(
        wibox.widget {
          text = i18n.translate("No extra input found"),
          align = "center",
          valign = "center",
          font = beautiful.font,
          widget = wibox.widget.textbox
        }
      )
    end

    -- add buttons to test the audio
    sink_children:add(wibox.container.margin(button("Test speaker", function()
      sound(true)
    end, active_pallet),m, m, m))

    -- If we are currently listing for microphone input
    if mic_test_pid == -1 then
      source_children:add(wibox.container.margin(button(mic_test_start_message, function()
        -- record audio using arecord and pipe it into aplay
        -- we use a buffer size of 10 ms for recording and playback as that has almost no delay, but still allows recording
        local cmd = "arecord -f cd - -B 10000 | aplay -B 10000"
        -- start the process and get the pid
        mic_test_pid= awful.spawn("sh -c '" .. cmd .. "'")
        refresh()
      end, active_pallet),m, m, m))
    else
      source_children:add(wibox.container.margin(button(mic_test_stop_message, kill_mic_pid),m, m, m))
    end

    local sink_widget = card("Output")
    sink_widget.update_body(wibox.container.margin(sink_children, m, m, m, m))

    local source_widget = card("Input")

    source_widget.update_body(wibox.container.margin(source_children, m, m, m, m))

    body:add(wibox.container.margin(sink_widget, m, m, m, m))
    body:add(wibox.container.margin(source_widget, m, m, m, m))
  end

  local applications_body = wibox.layout.grid.vertical()
  applications_body.forced_num_cols = 2
  applications_body.expand = true
  applications_body.homogeneous = true

  local function create_volume_from_application(app)
    local app_volume_card = card()

    local app_vol_slider = slider(
    0,
    100,
    1,
    0,
    function(value)
      volume.set_application_volume(app.sink, value)
    end
  )

  volume.get_application_volume(app.sink , function (value)
    if not (app_vol_slider.value == value) then
      print("Detected the volume: " .. value)
      app_vol_slider.update(value)
    end
  end)

  local app_vol_header = wibox.widget.textbox(app.name)
  app_vol_header.font = beautiful.font

    app_volume_card.update_body(
      wibox.widget {
        layout = wibox.layout.fixed.vertical,
        {
          layout = wibox.container.margin,
          margins = m,
          {
            layout = wibox.layout.align.horizontal,
            app_vol_header,
            nil,
            nil
          }
        },
        {
          layout = wibox.container.margin,
          left = m,
          right = m,
          bottom = m,
          forced_height = dpi(30) + (m * 2),
          app_vol_slider
        }
      }
    )
    return app_volume_card
  end

  -- returns a widget with all application volume sliders
  local function populate_applications()
    applications_body.children = {}
    local applications = volume.get_applications()
    for _, app in ipairs(applications) do
      applications_body:add(wibox.container.margin(create_volume_from_application(app), m, m, m, m))
    end
  end

  local function normal_mode(sinks, sources, sink, source)
    generate_sink_setting_body(sinks, sources, sink, source)
    populate_applications()
  end

  local function port_mode(_, _, _, _)
    generate_port_options(active_sr, bIsSink)
    populate_applications()
  end

  refresh = function()
    local sink = volume.get_default_sink()
    local source = volume.get_default_source()
    local sinks = volume.get_sinks()
    local sources = volume.get_sources()

    if not (sink.name == nil) then
      vol_footer.markup = 'Output: <span font="' .. beautiful.font .. '">' .. sink.name .. ' - ' .. sink.port .. "</span>"
    end
    if not (source.name == nil) then
      mic_footer.markup = 'Input: <span font="' .. beautiful.font .. '">' .. source.name .. ' - ' .. source.port .. "</span>"
    end

    -- TODO: Find a nicer api for detecting if audio is not working
    -- for example when no audio driver is found
    if sinks == nil or sources == nil or sink == nil or source == nil then
      scrollbox_body.reset()
      return
    end

    if DISPLAY_MODE == NORMAL_MODE then
      normal_mode(sinks, sources, sink, source)
    elseif DISPLAY_MODE == PORT_MODE then
      port_mode(sinks, sources, sink, source)
    else
      DISPLAY_MODE = NORMAL_MODE
      normal_mode(sinks, sources, sink, source)
    end

    scrollbox_body.reset()
  end

  view.refresh = refresh

  local volume_card = card()
  volume_card.update_body(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.margin,
        margins = m,
        {
          layout = wibox.layout.align.horizontal,
          vol_heading,
          nil,
          nil
        }
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        bottom = m,
        forced_height = dpi(30) + (m * 2),
        {
          mat_icon(icons.volume, dpi(25)),
          nil,
          vol_slider,
          layout = wibox.layout.fixed.horizontal
        }
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        bottom = m,
        forced_height = dpi(30) + (m * 2),
        {
          mat_icon(icons.microphone, dpi(25)),
          nil,
          mic_slider,
          layout = wibox.layout.fixed.horizontal
        }
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        bottom = m,
        forced_height = dpi(30) + (m * 2),
        wibox.widget {
          wibox.widget {
            widget = wibox.widget.textbox,
            text = i18n.translate("Hardware controlled volume"),
            font = beautiful.font
          },
          nil,
          hardware_only_volume_checbox,
          layout = wibox.layout.align.horizontal
        }
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        vol_footer
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        bottom = m,
        mic_footer
      }
    }
  )

  local audio_settings =
    wibox.container.margin(
    wibox.widget {
      widget = wibox.widget.textbox,
      text = i18n.translate("Audio list"),
      font = "SF Pro Display Bold 24"
    },
    dpi(20),
    0,
    dpi(20),
    dpi(20)
  )

  local application_settings =
  wibox.container.margin(
  wibox.widget {
    widget = wibox.widget.textbox,
    text = i18n.translate("Application list"),
    font = "SF Pro Display Bold 24"
  },
  dpi(20),
  0,
  dpi(20),
  dpi(20)
)

  scrollbox_body = scrollbox(wibox.widget {
    layout = wibox.layout.fixed.vertical,
    volume_card,
    wibox.container.margin(button("Reset Audio Server", function()
      volume.reset_server()
    end, active_pallet),m, m, m*2),
    audio_settings,
    body,
    application_settings,
    applications_body
  })

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      spacing = m,
      scrollbox_body
    }
  }

  return view
end
