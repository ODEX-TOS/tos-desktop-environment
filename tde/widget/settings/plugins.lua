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
local plugin_loader = require("lib-tde.plugin-loader")
local signals = require("lib-tde.signals")

local scrollbox = require("lib-widget.scrollbox")

local checkbox = require("lib-widget.checkbox")
local card = require("lib-widget.card")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)

local function refresh() end


return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local layout = wibox.layout.fixed.vertical()

  local scroll = scrollbox(layout)

  view:setup {
    layout = wibox.container.background,
    bg = beautiful.transparent,
    scroll
  }

  local function make_plugin_selection_item(plugin)
    local plugin_card = card()


    local is_active = false

    if _G.save_state.plugins ~= nil and _G.save_state.plugins[plugin.__name] ~= nil then
      is_active = _G.save_state.plugins[plugin.__name].active or false
    end

    local ratio = wibox.widget {
      layout = wibox.layout.ratio.horizontal,
      wibox.widget {
        widget = wibox.widget.textbox,
        text = plugin.name,
        font = beautiful.title_font,
      },
      wibox.widget.base.empty_widget(),
      checkbox(is_active, function(checked)
        if checked then
          plugin_loader.live_add_plugin(plugin.metadata.type, plugin.__name)
          _G.save_state.plugins[plugin.__name] = plugin
          _G.save_state.plugins[plugin.__name].active = true
          signals.emit_save_plugins(_G.save_state.plugins)
        else
          _G.save_state.plugins[plugin.__name].active = false
          signals.emit_save_plugins(_G.save_state.plugins)
          tde.restart()
        end
      end)
    }


    ratio:adjust_ratio(2, 0.8, 0.15, 0.05)

    ratio.forced_height = m * 3


    plugin_card.update_body(wibox.container.margin(ratio, m, m, m, m))

    return wibox.container.margin(plugin_card, m/2, m/2, m/2, m/2)
  end

  refresh = function()
    layout.children = {}

    local plugins = plugin_loader.list_plugins()

    for _, plugin in ipairs(plugins) do
      layout:add(make_plugin_selection_item(plugin))
    end
  end

  view.refresh = refresh

  return view
end
