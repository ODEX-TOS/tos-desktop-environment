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
local icons = require("theme.icons")

local scrollbox = require("lib-widget.scrollbox")

local checkbox = require("lib-widget.checkbox")
local card = require("lib-widget.card")
local button = require("lib-widget.button")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)

local function refresh() end


local function fetch_plugin_icon(plugin)
  local icon = plugin.metadata.icon
  local root_path = plugin.path

  if not type(icon) == "string" then
    return wibox.container.place(wibox.widget.imagebox(icon))
  end

  -- perhaps it is an index of theme icons
  if icons[icon] ~= nil then
    return wibox.container.place(wibox.widget.imagebox(icons[icon]))
  end

  if beautiful[icon] ~= nil then
    return wibox.container.place(wibox.widget.imagebox(beautiful[icon]))
  end

  -- check if the icon is absolute or relative
  if not (string.sub(icon, 1, 1) == "/") then
    return wibox.container.place(wibox.widget.imagebox(root_path .. '/' .. icon))
  end

  -- it is an absolute path
  return wibox.container.place(wibox.widget.imagebox(icon))
end


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
      wibox.widget.textbox(plugin.metadata.version or ""),
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

    if plugin.metadata.icon ~= nil then
      -- Add the image
      ratio:insert(1, fetch_plugin_icon(plugin))
      ratio:adjust_ratio(2, 0.05, 0.75, 0.2)
      ratio:adjust_ratio(3, 0.8, 0.15, 0.05)
    end


    plugin_card.update_body(wibox.container.margin(ratio, m, m, m, m))

    -- show a tooltip in case the plugin has a description
    if plugin.metadata.description then
      local language = i18n.system_language()
      local text = plugin.metadata.description

      if plugin.metadata["description_" .. language] ~= nil then
        text = plugin.metadata["description_" .. language]
      end

      awful.tooltip {
        objects = {plugin_card},
        text = text,
        preferred_positions = "bottom",
        preferred_alignments = "middle",
        margins = m,
      }
    end

    return wibox.container.margin(plugin_card, m/2, m/2, m/2, m/2)
  end

  local b_show_examples = false

  local function handle_examples(plugins)
    if #plugins == 0 or not _G.save_state.developer.enabled then
      return
    end

    local _layout = wibox.layout.fixed.vertical()

    for _, plugin in ipairs(plugins) do
      _layout:add(make_plugin_selection_item(plugin))
    end

    -- lets add a button to the layout that toggles the example plugin
    local btn_image = wibox.widget.imagebox(icons.arrow_down)

    local body = wibox.widget {
      wibox.widget.textbox("Show example plugins"),
      btn_image,
      layout = wibox.layout.fixed.horizontal
    }

    local function set_body()
      if b_show_examples then
        btn_image:set_image(icons.arrow_up)
        layout:add(_layout)
      else
        btn_image:set_image(icons.arrow_down)
        -- make sure we remove the correct element
        layout:remove_widgets(_layout)
      end
    end

    layout:add(button(body,
    function()
      b_show_examples = not b_show_examples

      set_body()
    end))

  set_body()
  end

  refresh = function()
    layout.children = {}

    local plugins = plugin_loader.list_plugins()

    local example_plugins = {}

    for _, plugin in ipairs(plugins) do
      if plugin.metadata["example"] == nil then
        layout:add(make_plugin_selection_item(plugin))
      else
        table.insert(example_plugins, plugin)
      end
    end

    handle_examples(example_plugins)
  end

  view.refresh = refresh

  return view
end
