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
local beautiful = require("beautiful")
local card = require("lib-widget.card")
local slider = require("lib-widget.slider")
local scrollbox = require("lib-widget.scrollbox")
local button = require("lib-widget.button")
local signals = require("lib-tde.signals")

local dpi = beautiful.xresources.apply_dpi

local size = require("widget.settings.size")

local m = size.m
local settings_index = size.settings_index

local active_tags = {}
local body

local function highlight_tags(tags)
  print('Highlighting tag ' .. tostring(tags[1].index))
  for _, tag in ipairs(tags) do
    tag:view_only()
  end
end

local function unhighlight_tags()
  for _, tag in ipairs(active_tags) do
    tag:view_only()
  end
end

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

local function gen_master_count(tags)

  local text = wibox.widget.textbox(tostring(math.floor(tags[1].master_count)))

  local function update(amount)
    for _, tag in ipairs(tags) do
      awful.tag.incnmaster(amount, tag)
    end
    text.text = tostring(tags[1].master_count)

    signals.emit_save_tag_state()
  end

  local dec = button({body = "-", callback = function()
    update(-1)
  end})

  local inc = button({body = "+", callback = function()
    update(1)
  end})

  local w =  wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    dec,
    wibox.container.place(text),
    inc
  }
  w:adjust_ratio(2, 0.35, 0.30, 0.35)

  local res = wibox.container.margin(w, 0, 0, 0, m)

  res.update_text = function (_text)
    text.text = _text
  end

  return res
end


local __tag_cache = {}

local function generate_tag(tags)
  if tags == nil then
    return wibox.widget.textbox('')
  end

  local max = tags[1].screen.geometry.width / 20
  local default_gap = tags[1].gap
  local default_factor = tags[1].master_width_factor


  if __tag_cache[tags[1].name] ~= nil then
    local _tag = __tag_cache[tags[1].name]

    _tag.update_gap(default_gap)
    _tag.update_master_width(default_factor)
    _tag.update_master_count(tags[1].master_count)

    return _tag
  end

  local t_card = card({title='Tag', height=dpi(150)})

  local _slider_gap = slider({
    max= max,
    default = default_gap,
    callback = function (value)
      for _, tag in ipairs(tags) do
        tag.gap = value
      end
    end,
    tooltip_callback = function()
      return tostring(tags[1].gap) .. 'px'
    end,
    done_callback =function (_)
      print('Updating gap')
      signals.emit_save_tag_state()
    end
  })

  local _slider_factor = slider({
    max = 1,
    increment = 0.01,
    default = default_factor,
    callback =function (value)
      for _, tag in ipairs(tags) do
        tag.master_width_factor = value
      end
    end,
    tooltip_callback = function()
      return tostring(tags[1].master_width_factor * 100) .. '%'
    end,
    done_callback = function (_)
      print('Updating master width factor')
      signals.emit_save_tag_state()
    end
  })

  t_card.update_master_width = function (val)
    _slider_factor.update(val)
  end

  t_card.update_gap = function (val)
    _slider_gap.update(val)
  end

  local btn = gen_master_count(tags)

  t_card.update_master_count = function (count)
    btn.update_text(tostring(math.floor(count)))
  end


  local factor_line = wibox.widget {
    {
      layout = wibox.container.margin,
      right = m,
      wibox.widget.textbox(i18n.translate("Master Width Factor") .. ":")
    },
    wibox.widget.base.empty_widget(),
    _slider_factor,
    layout = wibox.layout.ratio.horizontal
  }

  local gap_line = wibox.widget {
    {
      layout = wibox.container.margin,
      right = m,
      wibox.widget.textbox(i18n.translate("Gap") .. ":")
    },
    wibox.widget.base.empty_widget(),
    _slider_gap,
    layout = wibox.layout.ratio.horizontal
  }

  factor_line:adjust_ratio(2, 0.19, 0.01, 0.80)
  gap_line:adjust_ratio(2, 0.19, 0.01, 0.80)

  t_card.update_body(wibox.container.margin(wibox.widget {
    layout = wibox.layout.flex.vertical,
    btn,
    factor_line,
    gap_line,
  }, m, m, m, m))

  t_card.update_title(i18n.translate('Tag') .. ' ' .. tags[1].name)

  t_card:connect_signal('mouse::enter', function ()
    highlight_tags(tags)
    -- change card background to the primary color
    t_card.highlight()
  end)

  t_card:connect_signal('mouse::leave', function ()
    unhighlight_tags()
    -- revert card background back
    t_card.unhighlight()
  end)

  __tag_cache[tags[1].name] = t_card

  return __tag_cache[tags[1].name]
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Tag"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local layout = wibox.layout.fixed.vertical()
  body = scrollbox(layout)


  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.fixed.vertical,
      {layout = wibox.container.margin, top = m, bottom = m, body}
    }
  }

  view.refresh = function()
    body.reset()
    layout:reset()

    active_tags = {}

    for s in screen do
      table.insert(active_tags, s.selected_tag)
    end

    for _, tag in ipairs(awful.screen.focused().tags) do
      layout:add(wibox.container.margin(generate_tag(get_linked_tags(tag)), 0, 0, m, m))
    end
  end

  view.refresh()

  return view
end
