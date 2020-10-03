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
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local theme_name = "main"
local titlebar_icon_path = "/etc/xdg/awesome/theme/barthemes/" .. theme_name .. "/titlebar/"
local tip = titlebar_icon_path --alias to save time/space
local dpi = require("beautiful").xresources.apply_dpi
local titleBarSize = dpi(25)
local mode = general["draw_mode"]

-- Titlebar Colors
beautiful.titlebar_bg_focus = "#00000099"
beautiful.titlebar_bg_normal = "#00000077"

-- event handler that checks if  2 clicks occurend within 0.2 seconds
-- Use this function inside a button press
-- Accepts a callback that will be called if a double click occured
function double_click_event_handler(double_click_event)
  if double_click_timer then
    double_click_timer:stop()
    double_click_timer = nil
    double_click_event()
    return
  end

  double_click_timer =
    gears.timer.start_new(
    0.20,
    function()
      double_click_timer = nil
      return false
    end
  )
end

-- Define the images to load
beautiful.titlebar_close_button_normal = tip .. "close_normal.svg"
beautiful.titlebar_close_button_focus = tip .. "close_focus.svg"
beautiful.titlebar_minimize_button_normal = tip .. "minimize_normal.svg"
beautiful.titlebar_minimize_button_focus = tip .. "minimize_focus.svg"
beautiful.titlebar_ontop_button_normal_inactive = tip .. "ontop_normal_inactive.svg"
beautiful.titlebar_ontop_button_focus_inactive = tip .. "ontop_focus_inactive.svg"
beautiful.titlebar_ontop_button_normal_active = tip .. "ontop_normal_active.svg"
beautiful.titlebar_ontop_button_focus_active = tip .. "ontop_focus_active.svg"
beautiful.titlebar_sticky_button_normal_inactive = tip .. "sticky_normal_inactive.svg"
beautiful.titlebar_sticky_button_focus_inactive = tip .. "sticky_focus_inactive.svg"
beautiful.titlebar_sticky_button_normal_active = tip .. "sticky_normal_active.svg"
beautiful.titlebar_sticky_button_focus_active = tip .. "sticky_focus_active.svg"
beautiful.titlebar_floating_button_normal_inactive = tip .. "floating_normal_inactive.svg"
beautiful.titlebar_floating_button_focus_inactive = tip .. "floating_focus_inactive.svg"
beautiful.titlebar_floating_button_normal_active = tip .. "floating_normal_active.svg"
beautiful.titlebar_floating_button_focus_active = tip .. "floating_focus_active.svg"
beautiful.titlebar_maximized_button_normal_inactive = tip .. "maximized_normal_inactive.svg"
beautiful.titlebar_maximized_button_focus_inactive = tip .. "maximized_focus_inactive.svg"
beautiful.titlebar_maximized_button_normal_active = tip .. "maximized_normal_active.svg"
beautiful.titlebar_maximized_button_focus_active = tip .. "maximized_focus_active.svg"
-- hover
beautiful.titlebar_close_button_normal_hover = tip .. "close_normal_hover.svg"
beautiful.titlebar_close_button_focus_hover = tip .. "close_focus_hover.svg"
beautiful.titlebar_minimize_button_normal_hover = tip .. "minimize_normal_hover.svg"
beautiful.titlebar_minimize_button_focus_hover = tip .. "minimize_focus_hover.svg"
beautiful.titlebar_ontop_button_normal_inactive_hover = tip .. "ontop_normal_inactive_hover.svg"
beautiful.titlebar_ontop_button_focus_inactive_hover = tip .. "ontop_focus_inactive_hover.svg"
beautiful.titlebar_ontop_button_normal_active_hover = tip .. "ontop_normal_active_hover.svg"
beautiful.titlebar_ontop_button_focus_active_hover = tip .. "ontop_focus_active_hover.svg"
beautiful.titlebar_sticky_button_normal_inactive_hover = tip .. "sticky_normal_inactive_hover.svg"
beautiful.titlebar_sticky_button_focus_inactive_hover = tip .. "sticky_focus_inactive_hover.svg"
beautiful.titlebar_sticky_button_normal_active_hover = tip .. "sticky_normal_active_hover.svg"
beautiful.titlebar_sticky_button_focus_active_hover = tip .. "sticky_focus_active_hover.svg"
beautiful.titlebar_floating_button_normal_inactive_hover = tip .. "floating_normal_inactive_hover.svg"
beautiful.titlebar_floating_button_focus_inactive_hover = tip .. "floating_focus_inactive_hover.svg"
beautiful.titlebar_floating_button_normal_active_hover = tip .. "floating_normal_active_hover.svg"
beautiful.titlebar_floating_button_focus_active_hover = tip .. "floating_focus_active_hover.svg"
beautiful.titlebar_maximized_button_normal_inactive_hover = tip .. "maximized_normal_inactive_hover.svg"
beautiful.titlebar_maximized_button_focus_inactive_hover = tip .. "maximized_focus_inactive_hover.svg"
beautiful.titlebar_maximized_button_normal_active_hover = tip .. "maximized_normal_active_hover.svg"
beautiful.titlebar_maximized_button_focus_active_hover = tip .. "maximized_focus_active_hover.svg"

local roundCorners = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, beautiful.corner_radius)
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
  "request::titlebars",
  function(c)
    -- buttons for the titlebar
    local buttons =
      gears.table.join(
      awful.button(
        {},
        1,
        function()
          double_click_event_handler(
            function()
              if c.floating then
                c.floating = false
                return
              end

              c.maximized = not c.maximized
              c:raise()
              return
            end
          )
          c:emit_signal("request::activate", "titlebar", {raise = true})
          awful.mouse.client.move(c)
        end
      ),
      awful.button(
        {},
        3,
        function()
          c:emit_signal("request::activate", "titlebar", {raise = true})
          awful.mouse.client.resize(c)
        end
      )
    )

    awful.titlebar(c, {position = "top", size = titleBarSize}):setup {
      {
        -- Top

        awful.titlebar.widget.floatingbutton(c),
        layout = wibox.layout.fixed.horizontal
      },
      {
        -- Middle
        {
          -- Title
          align = "center",
          widget = awful.titlebar.widget.titlewidget(c)
        },
        buttons = buttons,
        layout = wibox.layout.flex.horizontal
      },
      {
        -- Bottom
        awful.titlebar.widget.minimizebutton(c),
        awful.titlebar.widget.maximizedbutton(c),
        awful.titlebar.widget.closebutton(c),
        layout = wibox.layout.fixed.horizontal
      },
      layout = wibox.layout.align.horizontal
    }

    -- CUSTOM TITLEBAR FOR TERMINALS
    -- You need XPROP for this to work
    if c.class == "kitty" or c.class == "XTerm" then
      awful.titlebar(c, {bg = "#000000AA", size = titleBarSize}):setup {
        {
          awful.titlebar.widget.floatingbutton(c),
          layout = wibox.layout.fixed.horizontal
        },
        nil,
        {
          -- Bottom
          awful.titlebar.widget.minimizebutton(c),
          awful.titlebar.widget.maximizedbutton(c),
          awful.titlebar.widget.closebutton(c),
          layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
      }
    end
  end
)

-- Show the titlebar if it's not maximized layout
_G.tag.connect_signal(
  "property::layout",
  function(t)
    local clients = t:clients()
    for k, c in pairs(clients) do
      if c.first_tag.layout.name ~= "max" then
        awful.titlebar.show(c, "top")
      else
        awful.titlebar.hide(c, "top")
      end
    end
  end
)

-- On Spawn
_G.client.connect_signal(
  "manage",
  function(c)
    if c.first_tag.layout.name ~= "max" then
      awful.titlebar.show(c, "top")
    else
      awful.titlebar.hide(c, "top")
    end
  end
)

function full(s)
  for _, c in pairs(s.clients) do
    if #s.tiled_clients >= 0 and (c.floating or c.first_tag.layout.name == "floating") then
      awful.titlebar.show(c, "top")
      c.shape = function(cr, w, h)
        gears.shape.rectangle(cr, w, h)
      end
    elseif #s.tiled_clients == 1 and c.fullscreen == true then
      awful.titlebar.show(c, "top")
      c.shape = function(cr, w, h)
        gears.shape.rectangle(cr, w, h)
      end
    elseif #s.tiled_clients >= 1 and c.fullscreen == true then
      awful.titlebar.show(c, "top")
      c.shape = function(cr, w, h)
        gears.shape.rectangle(cr, w, h)
      end
    elseif #s.tiled_clients >= 1 and c.maximized == true then
      if c.maximized then
        awful.titlebar.show(c, "top")
        c.shape = function(cr, w, h)
          gears.shape.rectangle(cr, w, h)
        end
      end
    elseif #s.tiled_clients == 1 and c.first_tag.layout.name == "dwindle" then
      awful.titlebar.hide(c, "top")
      c.shape = function(cr, w, h)
        gears.shape.rectangle(cr, w, h)
      end
    elseif #s.tiled_clients > 1 and c.first_tag.layout.name == "dwindle" then
      awful.titlebar.show(c, "top")
      c.shape = roundCorners
    elseif #s.tiled_clients == 1 and c.first_tag.layout.name == "tile" then
      awful.titlebar.hide(c, "top")
      c.shape = function(cr, w, h)
        gears.shape.rectangle(cr, w, h)
      end
    elseif #s.tiled_clients > 1 and c.first_tag.layout.name == "tile" then
      awful.titlebar.show(c, "top")
      c.shape = roundCorners
    end
  end
end

function fast(s)
  for _, c in pairs(s.clients) do
    if #s.tiled_clients >= 2 or (c.floating or c.first_tag.layout.name == "floating") then
      awful.titlebar.show(c, "top")
      c.shape = function(cr, w, h)
        gears.shape.rectangle(cr, w, h)
      end
    else
      awful.titlebar.hide(c, "top")
      c.shape = function(cr, w, h)
        gears.shape.rectangle(cr, w, h)
      end
    end
  end
end

function none(s)
  for _, c in pairs(s.clients) do
    awful.titlebar.hide(c, "top")
    c.shape = function(cr, w, h)
      gears.shape.rectangle(cr, w, h)
    end
  end
end

-- This is a messy script on manipulating titlebars and window shape.
-- If you can fixed it please send a PR HAHAHA
-- Plan: If first_tag.layout.name is not max and tiled_clients >1 : Show Titlebars and make client shape rounded ? Hide and make the c.shape rectangle
_G.screen.connect_signal(
  "arrange",
  function(s)
    if mode == "full" then
      full(s)
    elseif mode == "none" then
      none(s)
    else
      fast(s)
    end
  end
)

_G.client.connect_signal(
  "property::floating",
  function(c)
    if c.floating then
      awful.titlebar.show(c, "top")
      awful.placement.centered(c)
    else
      awful.titlebar.hide(c, "top")
    end
  end
)

return beautiful
