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
local dpi = require("beautiful").xresources.apply_dpi
local mat_list_item = require("widget.material.list-item")
local signals = require("lib-tde.signals")
local card = require("lib-widget.card")
local checkbox = require("lib-widget.checkbox")

local PATH_TO_ICONS = "/etc/xdg/tde/widget/notification-center/icons/"
local theme = require("theme.icons.dark-light")

_G.dont_disturb = false

local disturb_card = card()
local box

local dont_disturb_text =
  wibox.widget {
  text = i18n.translate("Do Not Disturb"),
  font = "SFNS Display 12",
  align = "left",
  widget = wibox.widget.textbox
}

local function update_disturb(state)
  -- luacheck: ignore dont_disturb
  dont_disturb = state
  if box then
    box.update(state)
  end
  signals.emit_do_not_disturb(dont_disturb)
end

box =
  checkbox(
  false,
  function(checked)
    update_disturb(checked)
  end
)

local dont_disturb_icon =
  wibox.widget {
  {
    image = theme(PATH_TO_ICONS .. "dont-disturb" .. ".svg"),
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

signals.connect_do_not_disturb(
  function(bDoNotDisturb)
    if dont_disturb == bDoNotDisturb then
      return
    end

    update_disturb(bDoNotDisturb)
  end
)

local content =
  wibox.widget {
  {
    wibox.container.margin(dont_disturb_icon, dpi(12), dpi(12), dpi(5), dpi(5)),
    dont_disturb_text,
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  {
    box,
    layout = wibox.layout.fixed.horizontal
  },
  layout = wibox.layout.align.horizontal
}

local dont_disturb_wrap =
  wibox.widget {
  wibox.widget {
    {
      content,
      margins = dpi(10),
      widget = wibox.container.margin
    },
    widget = wibox.container.background
  },
  widget = mat_list_item
}

disturb_card.update_body(dont_disturb_wrap)

return wibox.container.margin(disturb_card, dpi(15), dpi(15))
