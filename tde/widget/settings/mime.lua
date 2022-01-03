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
local icons = require("theme.icons")

local mappers = require("lib-tde.mappers")

local mime = require('lib-tde.mime')

local fuzzy = require('lib-tde.fuzzy_find')

local scrollbox = require("lib-widget.scrollbox")

local card = require("lib-widget.card")
local button = require("lib-widget.button")
local inputfield = require("lib-widget.inputfield")

local mimetypes = {}

local dpi = beautiful.xresources.apply_dpi

local element_height = dpi(130)

local size = require("widget.settings.size")

local m = size.m
local settings_height = size.settings_height


local function refresh() end


-- force re-render the mimetypes
local function render_again() end

-- Make sure we don't generate to much results, as we can have a lot of different mimetypes
local max_results = (settings_height / element_height) - 2


local __mimetype_cache = {}

local function make_mimetype_field(content_type)

  if __mimetype_cache[content_type] ~= nil then
    __mimetype_cache[content_type].update_app()
    return __mimetype_cache[content_type]
  end

  local app_name, app_icon = mime.get_metadata(content_type)

  print(content_type)

  local image = wibox.widget.imagebox(app_icon)
  local textbox = wibox.widget.textbox(app_name or content_type or "")

  local widget = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    wibox.container.place(image),
    wibox.container.place(textbox),
    wibox.container.margin(button({
      body = "Change application",
      callback = function()
        root.elements.settings.ontop = false

        -- After the app has been chosen, we can resume
        mime.mimetypeAppChooser(content_type, function ()
          root.elements.settings.ontop = true
          render_again()
        end)
      end
    }), 0,0,m,m)
  }

  widget:adjust_ratio(2, 0.2, 0.6, 0.2)

  local _card = card({ title = content_type or "Unknown" })

  _card.update_body(widget)

  local res = wibox.container.margin(_card, m,m,m,m)

  __mimetype_cache[content_type] = res

  res.update_app = function ()
    local _app_name, _app_icon = mime.get_metadata(content_type)
    textbox.text = _app_name or content_type or ""
    image:set_image(_app_icon)
  end

  res.forced_height = element_height

  return __mimetype_cache[content_type]
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




  local search = inputfield({
    typing_callback = function(text)
        scroll.reset()

        _widget.children = {}

        local __mimetypes = fuzzy.best_score(mimetypes, text, max_results)

        -- filter out the widgets inside the _widget based on the name
        for _, type in ipairs(__mimetypes) do
          _widget:add(make_mimetype_field(type))
        end
    end,
    icon = icons.search
  })

  layout:add(wibox.container.margin(search, m, m, m, m))
  layout:add(_widget)

  render_again = function ()
    for _, child in ipairs(_widget.children) do
      if child["update_app"] ~= nil then
        child.update_app()
      end
    end
  end

  local info = wibox.widget {
      widget = wibox.widget.textbox,
      text = i18n.translate("Search for a given filetype/mimetype and change the default application associated with it."),
      font = beautiful.title_font
    }

  refresh = function()
    mimetypes = mime.get_mimetypes()

   -- we now have the latest list of mimetypes, let the searchbox take care of rendering it
   mimetypes = mappers.filter(mimetypes, function(element, _)
    return string.find(element, '%+') == nil
   end)

   _widget.children = {}

   info.forced_height = settings_height

   _widget:add(wibox.container.place(info))
  end

  view.refresh = refresh

  -- Ensure the inputfields lose focus
  view.stop_view = function ()
    search.reset()
  end

  return view
end
