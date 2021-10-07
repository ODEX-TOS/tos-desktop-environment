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
local inputfield = require("lib-widget.inputfield")

local mat_colors = require("theme.mat-colors")

local naughty = require("naughty")

local common = require("lib-tde.function.common")
local highlight_text = common.highlight_text
local split = common.split

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)

local function refresh() end

local plugins = plugin_loader.list_plugins()


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

local function version_highlight(version)
  local splitted = split(version,'.') or {}

  if #splitted < 1  then
    return version
  end

  if splitted[1] == "v0" or splitted[1] == "0" then
    return highlight_text(version, mat_colors.red.hue_600)
  end
  return highlight_text(version, mat_colors.white.hue_600)
end


return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local layout = wibox.layout.fixed.vertical()

  local scroll = scrollbox(layout)

  local _widget = wibox.layout.fixed.vertical()

  view:setup {
    layout = wibox.container.background,
    bg = beautiful.transparent,
    scroll
  }

  local __plugin_widget_cache = {}

  local function make_plugin_selection_item(plugin)
    if __plugin_widget_cache[plugin.__name] ~= nil then
      return __plugin_widget_cache[plugin.__name]
    end

    local plugin_card = card()


    local is_active = false

    if _G.save_state.plugins ~= nil and _G.save_state.plugins[plugin.__name] ~= nil then
      is_active = _G.save_state.plugins[plugin.__name].active or false
    end

    local version_ratio = wibox.widget {
      layout = wibox.layout.ratio.horizontal,
      wibox.widget.textbox(common.capitalize(plugin.metadata.type)),
      wibox.widget.base.empty_widget(),
      wibox.widget.textbox(version_highlight(plugin.metadata.version) or ""),
    }

    version_ratio:adjust_ratio(2, 0.4, 0.2, 0.4)

    local ratio = wibox.widget {
      layout = wibox.layout.ratio.horizontal,
      wibox.widget {
        widget = wibox.widget.textbox,
        text = plugin.name,
        font = beautiful.title_font,
      },
      version_ratio,
      checkbox({
        checked = is_active,
        callback = function(checked)
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
      end
      })
    }


    ratio:adjust_ratio(2, 0.6, 0.35, 0.05)

    ratio.forced_height = m * 3

    if plugin.metadata.icon ~= nil then
      -- Add the image
      ratio:insert(1, fetch_plugin_icon(plugin))
      ratio:adjust_ratio(2, 0.05, 0.55, 0.40)
      ratio:adjust_ratio(3, 0.60, 0.35, 0.05)
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

    __plugin_widget_cache[plugin.__name] = wibox.container.margin(plugin_card, m/2, m/2, m/2, m/2)

    return __plugin_widget_cache[plugin.__name]
  end

  local b_show_examples = false

  local function handle_examples(_plugins)
    if #_plugins == 0 or not _G.save_state.developer.enabled then
      return
    end

    local _layout = wibox.layout.fixed.vertical()

    for _, plugin in ipairs(_plugins) do
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
        _widget:add(_layout)
      else
        btn_image:set_image(icons.arrow_down)
        -- make sure we remove the correct element
        _widget:remove_widgets(_layout)
      end
    end

    _widget:add(button({
      body = body,
      callback = function()
        b_show_examples = not b_show_examples

        set_body()
      end
    }))

  set_body()
  end

  -- a simple function for people to get more information about plugins
  local function plugin_description()

    local marketplace = button({
      body = "Marketplace",
      callback = function ()
        -- TODO: Implement some kind of plugin marketplace
        naughty.notification(
          {
              title = i18n.translate("Marketplace"),
              text = i18n.translate("The Plugin Marketplace is currently in the works, it will be implemented shortly"),
              timeout = 5,
              urgency = "normal",
              icon = icons.plugin
          })
      end
  })

    local build_your_own = button({
      body = "Build your own plugin",
      callback = function()
        require('module.docs').open_doc("/usr/share/doc/tde/doc/documentation/plugin.md.html")
      end
    })

    local ratio = wibox.widget {
      layout = wibox.layout.ratio.horizontal,
      marketplace,
      wibox.widget.base.empty_widget(),
      build_your_own
    }

    ratio:adjust_ratio(2, 0.4, 0.2, 0.4)

    return wibox.container.margin(ratio, m, m, m, m)
  end

  local search = inputfield({
    typing_callback = function(text)
        scroll.reset()

        _widget.children = {}

        -- filter out the widgets inside the _widget based on the name
        for _, plugin in ipairs(plugins) do
            if (string.find(plugin.name, text) ~= nil or string.find(plugin.__name, text) ~= nil) and plugin.metadata["example"] == nil then
                _widget:add(make_plugin_selection_item(plugin))
            end
        end
    end,
    icon = icons.search
  })

  layout:add(plugin_description())
  layout:add(wibox.container.margin(search, m, m, m, m))
  layout:add(_widget)


  refresh = function()
    plugins = plugin_loader.list_plugins()

    local example_plugins = {}

    _widget.children = {}

    for _, plugin in ipairs(plugins) do
      if plugin.metadata["example"] == nil then
        _widget:add(make_plugin_selection_item(plugin))
      else
        table.insert(example_plugins, plugin)
      end
    end


    handle_examples(example_plugins)

  end

  view.refresh = refresh

  -- Ensure the inputfields lose focus
  view.stop = function ()
    search.reset()
  end

  return view
end
