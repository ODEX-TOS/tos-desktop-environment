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
local card = require("lib-widget.card")
local slider = require("lib-widget.slider")
local scrollbox = require("lib-widget.scrollbox")
local button = require("lib-widget.button")

local configWriter = require("lib-tde.config-writer")
local configFile = os.getenv("HOME") .. "/.config/tos/tags.conf"

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)
local settings_index = dpi(40)

local body

local function get_linked_tags(tag)
  local index = tag.index
  local tags = {}

  for _, _tag in ipairs(root.tags()) do
    if _tag.index == index then
      table.insert(tags, _tag)
    end
  end

  return tags
end

local function gen_master_width(tags)

  local text = wibox.widget.textbox(tostring(tags[1].master_count))

  local dec = button("-", function()
    for _, tag in ipairs(tags) do
      awful.tag.incnmaster(-1, tag)
    end
    text.text = tostring(tags[1].master_count)

    -- TODO: persist these changes
  end)

  local inc = button("+", function()
    for _, tag in ipairs(tags) do
      awful.tag.incnmaster(1, tag)
    end
    text.text = tostring(tags[1].master_count)

    -- TODO: persist these changes
  end)

  local w =  wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    dec,
    wibox.container.place(text),
    inc
  }
  w:adjust_ratio(2, 0.35, 0.30, 0.35)
  return wibox.container.margin(w, 0, 0, 0, m)
end

local function generate_tag(tags, t_card)
  if tags == nil then
    return wibox.widget.textbox('')
  end

  local max = tags[1].screen.geometry.width / 20
  local default_gap = tags[1].gap
  local _slider = slider(0, max, 1, default_gap, function (value)
    for _, tag in ipairs(tags) do
      tag.gap = value
    end
  end, function()
    return tostring(tags[1].gap) .. 'px'
  end, function (_)
    print('Updating gap')
    configWriter.update_entry(configFile, "tag_gap_" .. tostring(tags[1].index), tostring(tags[1].gap))
  end)

  local btn = gen_master_width(tags)

  t_card.update_body(wibox.container.margin(wibox.widget {
    layout = wibox.layout.fixed.vertical,
    btn,
    nil,
    _slider,
  }, m, m, m, m))
  t_card.update_title(i18n.translate('Tag') .. ' ' .. tags[1].name)
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Tag"))
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

  local layout = wibox.layout.fixed.vertical()
  body = scrollbox(layout)


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
      {layout = wibox.container.margin, top = m, bottom = m, body}
    }
  }

  view.refresh = function()
    body.reset()
    layout:reset()

    for _, tag in ipairs(awful.screen.focused().tags) do
      local tag_c = card('Tag', dpi(100))
      generate_tag(get_linked_tags(tag), tag_c)
      layout:add(wibox.container.margin(tag_c, 0, 0, m, m))
    end
  end

  view.refresh()

  return view
end
