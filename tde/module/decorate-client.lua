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

local function renderClient(client, mode)
  if client.skip_decoration or (client.rendering_mode == mode) then
    return
  end

  client.rendering_mode = mode
  client.floating = false
  client.maximized = false
  client.above = false
  client.below = false
  client.ontop = false
  client.sticky = false
  client.maximized_horizontal = false
  client.maximized_vertical = false

  if client.rendering_mode == "maximized" then
    client.border_width = 0
    client.shape = function(cr, w, h)
      gears.shape.rectangle(cr, w, h)
    end
  elseif client.rendering_mode == "tiled" or client.rendering_mode == "floating" or client.rendering_mode == "dwindle" then
    client.border_width = beautiful.border_width
    client.shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, 12)
    end
  end
end

local changesOnScreenCalled = false

local function changesOnScreen(currentScreen)
  local tagIsMax = currentScreen.selected_tag ~= nil and currentScreen.selected_tag.layout == awful.layout.suit.max
  local clientsToManage = {}

  for _, client in pairs(currentScreen.clients) do
    if not client.skip_decoration and not client.hidden then
      table.insert(clientsToManage, client)
    end
  end

  if (tagIsMax or #clientsToManage == 1) then
    currentScreen.client_mode = "maximized"
  else
    currentScreen.client_mode = "dwindle"
  end

  for _, client in pairs(clientsToManage) do
    renderClient(client, currentScreen.client_mode)
  end
  changesOnScreenCalled = false
end

function clientCallback(client)
  if not changesOnScreenCalled then
    if not client.skip_decoration and client.screen then
      changesOnScreenCalled = true
      local screen = client.screen
      gears.timer.delayed_call(
        function()
          changesOnScreen(screen)
        end
      )
    end
  end
end

function tagCallback(tag)
  if not changesOnScreenCalled then
    if tag.screen then
      changesOnScreenCalled = true
      local screen = tag.screen
      gears.timer.delayed_call(
        function()
          changesOnScreen(screen)
        end
      )
    end
  end
end

_G.client.connect_signal("manage", clientCallback)

_G.client.connect_signal("unmanage", clientCallback)

_G.client.connect_signal("property::hidden", clientCallback)

_G.client.connect_signal("property::minimized", clientCallback)

_G.client.connect_signal(
  "property::fullscreen",
  function(c)
    if c.fullscreen then
      renderClient(c, "maximized")
    else
      clientCallback(c)
    end
  end
)

_G.tag.connect_signal("property::selected", tagCallback)

_G.tag.connect_signal("property::layout", tagCallback)
