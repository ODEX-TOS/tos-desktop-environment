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
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local seperator_widget = require("lib-widget.separator")
local card = require("lib-widget.card")
local checkbox = require("lib-widget.checkbox")

local signals = require("lib-tde.signals")

local size = require("widget.settings.size")

local m = size.m
local settings_index = size.settings_index

local function create_checkbox(name, checked, callback, set_checkbox_callback)
  local name_widget =
    wibox.widget {
    text = name,
    font = beautiful.title_font,
    widget = wibox.widget.textbox
  }
  local box =
    checkbox({
    checked = checked,
    callback = function(box_checked)
      callback(box_checked)
    end,
    size = settings_index * 0.7
    })
  if set_checkbox_callback then
    set_checkbox_callback(function(_checked)
      box.update(_checked)
    end)
  end


  return wibox.container.margin(
    wibox.widget {
      layout = wibox.layout.align.horizontal,
      wibox.container.margin(name_widget, m),
      nil,
      wibox.container.margin(box, 0, m)
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

  local title = wibox.widget.textbox(i18n.translate("Developer"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local separator = seperator_widget({height = settings_index / 1.5 })

  local debug_check_callback = function(_) end

  local function ensure_developer_settings()
    -- make sure that the developer settings should have an effect
    _G.save_state.developer.enabled = general["developer"] == "1"
  end

  local function update_client_draw_mode()
    client.emit_signal("draw_debug")
  end

  local debug_check = create_checkbox("Draw debug", _G.save_state.developer.draw_debug, function(checked)
    ensure_developer_settings()

    _G.save_state.developer.draw_debug = checked

    update_client_draw_mode()

    -- force a full redraw of everything to paint the debug lines
    tde.emit_signal("full_redraw")
  end, function(callback)
    debug_check_callback = callback
  end)

  local debug_color_check = create_checkbox("Draw debug colors", _G.save_state.developer.draw_debug_colors, function(checked)
    ensure_developer_settings()

    _G.save_state.developer.draw_debug_colors = checked

    -- when we enable colors debugging, this should always be enabled
    _G.save_state.developer.draw_debug = true
    debug_check_callback(_G.save_state.developer.draw_debug)

    update_client_draw_mode()

    -- force a full redraw of everything to paint the debug lines
    tde.emit_signal("full_redraw")

    signals.emit_save_developer_settings()
  end)

  local debug_paint_refresh = create_checkbox("Paint refresh", _G.save_state.developer.paint_refresh, function (checked)
    ensure_developer_settings()

    _G.save_state.developer.paint_refresh = checked

    -- force a full redraw of everything to paint the debug lines
    tde.emit_signal("full_redraw")
    signals.emit_save_developer_settings()
  end)


  local checkbox_widget =
    wibox.widget {
    layout = wibox.layout.flex.vertical,
    debug_check,
    debug_color_check,
    debug_paint_refresh
  }

  local checkbox_card = card()
  checkbox_card.update_body(wibox.container.margin(checkbox_widget, dpi(10), dpi(10), dpi(3), dpi(3)))

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      separator,
      wibox.container.margin(checkbox_card, dpi(10), dpi(10))
    }
  }

  return view
end
