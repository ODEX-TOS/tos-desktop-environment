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
-- The one that generates notification in right-panel
--
--

local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local theme = require("theme.icons.dark-light")

local lgi = require("lgi")
local Pango = lgi.Pango

local beautiful = require("beautiful")

local PATH_TO_ICONS = "/etc/xdg/tde/widget/notification-center/icons/"

local notif_layout = wibox.layout.fixed.vertical(reverse)
notif_layout.spacing = dpi(5)

-- useful variable to check the notification's content
_G.notification_firstime = true

local notif_icon = function(ico_image)
  local noti_icon =
    wibox.widget {
    {
      id = "icon",
      resize = true,
      forced_height = dpi(45),
      forced_width = dpi(45),
      widget = wibox.widget.imagebox
    },
    layout = wibox.layout.fixed.horizontal
  }
  noti_icon.icon:set_image(ico_image)
  return noti_icon
end

local notif_title = function(title)
  return wibox.widget {
    markup = gears.string.xml_escape(title),
    font = "SFNS Display Bold 12",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
  }
end

local notif_message = function(msg)
  return wibox.widget {
    markup = msg,
    font = "SFNS Display Regular 12",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
  }
end

-- Empty content
local empty_title = i18n.translate("Spooky...")
local empty_message = i18n.translate("There's nothing in here... Come back later.")

-- The function that generates notifications in right-panel
local function notif_generate(title, message, icon, noti)
  -- make sure the message is valid, otherwise we escape it
  local attr, _ = Pango.parse_markup(message, -1, 0)
  if not attr then
    message = gears.string.xml_escape(message)
  end

  -- naughty.list.actions
  local notif_actions =
    wibox.widget {
    notification = noti,
    base_layout = wibox.widget {
      spacing = dpi(5),
      layout = wibox.layout.flex.vertical
    },
    widget_template = {
      {
        {
          {
            id = "text_role",
            font = "SFNS Display Regular 10",
            widget = wibox.widget.textbox
          },
          widget = wibox.container.place
        },
        bg = beautiful.bg_modal,
        shape = gears.shape.rounded_rect,
        forced_height = 30,
        widget = wibox.container.background
      },
      margins = 4,
      widget = wibox.container.margin
    },
    widget = naughty.list.actions
  }

  -- The layout of notification to be generated
  local notif_template =
    wibox.widget {
    id = "notif_template",
    expand = "none",
    layout = wibox.layout.fixed.vertical,
    {
      {
        expand = "none",
        layout = wibox.layout.align.horizontal,
        {
          nil,
          layout = wibox.layout.fixed.horizontal
        },
        {
          wibox.container.margin(notif_title(title), dpi(0), dpi(0), dpi(4), dpi(4)),
          layout = wibox.layout.fixed.horizontal
        }
        -- {
        --   gen_button(notif_del_button),
        --   layout = wibox.layout.fixed.horizontal,
        -- },
      },
      bg = beautiful.bg_modal_title,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 6)
      end,
      widget = wibox.container.background
    },
    {
      {
        expand = "none",
        layout = wibox.layout.fixed.horizontal,
        {
          wibox.widget {
            notif_icon(icon),
            margins = dpi(4),
            widget = wibox.container.margin
          },
          margins = dpi(5),
          widget = wibox.container.margin
        },
        {
          wibox.widget {
            notif_message(message),
            margins = dpi(4),
            widget = wibox.container.margin
          },
          layout = wibox.layout.flex.horizontal
        }
      },
      bg = beautiful.bg_modal,
      widget = wibox.container.background
    },
    {
      wibox.widget {
        {
          notif_actions,
          margins = dpi(4),
          widget = wibox.container.margin
        },
        bg = beautiful.bg_modal,
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 6)
        end,
        widget = wibox.container.background
      },
      layout = wibox.layout.flex.horizontal
    }
  }

  -- Delete notification if naughty.list.actions was pressed
  notif_actions:connect_signal(
    "button::press",
    function(_, _, _, _)
      -- Don't let the user make the notification center null
      if #notif_layout.children == 1 then
        notif_layout:reset(notif_layout)
        _G.notification_firstime = true
        notif_layout:insert(1, notif_generate(empty_title, empty_message, theme(PATH_TO_ICONS .. "boo" .. ".svg")))
      else
        notif_layout:remove_widgets(notif_template, true)
      end
    end
  )

  -- Delete notification if the generated notification was pressed
  notif_template:connect_signal(
    "button::press",
    function(_, _, _, _)
      -- Don't let the user make the notification center null
      if #notif_layout.children == 1 then
        notif_layout:reset(notif_layout)
        _G.notification_firstime = true
        notif_layout:insert(1, notif_generate(empty_title, empty_message, theme(PATH_TO_ICONS .. "boo" .. ".svg")))
      else
        notif_layout:remove_widgets(notif_template, true)
      end
    end
  )

  --return template to generate
  return notif_template
end

-- add a message to an empty notification center
local function add_empty()
  notif_layout:insert(1, notif_generate(empty_title, empty_message, theme(PATH_TO_ICONS .. "boo" .. ".svg")))
end

-- Add empty message on startup
add_empty()

-- Clear all. Will be called in right-panel
local function clear_all()
  -- Clear all notification
  notif_layout:reset(notif_layout)
  add_empty()
end

_G.notification_clear_all = clear_all

-- Check signal
naughty.connect_signal(
  "request::display",
  function(n)
    if _G.notification_firstime then
      -- Delete empty message if the 1st notification is generated
      notif_layout:remove(1)
      _G.notification_firstime = false
    end

    -- Check and set icon to the notification message in panel
    -- Then generate a widget based on naughty.notify data
    if n.icon == nil then
      -- if naughty sends a signal without an icon then use this instead
      notif_layout:insert(1, notif_generate(n.title, n.message, theme(PATH_TO_ICONS .. "new-notif" .. ".svg"), n))
    else
      -- Use the notification's icon
      notif_layout:insert(1, notif_generate(n.title, n.message, n.icon, n))
    end
  end
)

-- Return notif_layout to right-panel.lua to display it
return notif_layout
