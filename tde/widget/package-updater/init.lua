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
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local theme = require("theme.icons.dark-light")
local icon = require("theme.icons").warning
local signals = require("lib-tde.signals")

local PATH_TO_ICONS = "/etc/xdg/tde/widget/package-updater/icons/"
local updateAvailable = false
local numOfUpdatesAvailable
local numOfSecUpdatesAvailable
local config = require("config")

local securityUpdateNotShown = true

local function split(str)
  local lines = {}
  for s in str:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

local widget =
  wibox.widget {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local widget_button = clickable_container(wibox.container.margin(widget, dpi(14), dpi(14), dpi(7), dpi(7))) -- 4 is top and bottom margin
widget_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        if updateAvailable then
          awful.spawn((os.getenv("TERMINAL") or "st") .. ' -e sh -c "system-updater || read"')
        else
          awful.spawn(os.getenv("TERMINAL") or "st")
        end
      end
    )
  )
)
-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
awful.tooltip(
  {
    objects = {widget_button},
    mode = "outside",
    align = "right",
    timer_function = function()
      if updateAvailable then
        local str
        if numOfUpdatesAvailable == "1" then
          str = i18n.translate("%s update is available!", numOfUpdatesAvailable)
        else
          str = i18n.translate("%s updates are available!", numOfUpdatesAvailable)
        end
        if numOfSecUpdatesAvailable == "1" then
          return str ..
            "\n" .. i18n.translate("Of which %s is security related", numOfSecUpdatesAvailable)
        elseif numOfSecUpdatesAvailable == "0" then
          return str
        end
        return str ..
          "\n" .. i18n.translate("Of which %s are security related", numOfSecUpdatesAvailable)
      else
        return i18n.translate("We are up-to-date!")
      end
    end,
    preferred_positions = {"right", "left", "top", "bottom"}
  }
)

local function notifySecurityUpdate(num)
  local str =
    i18n.translate("There are %s security vulnerabilities. Please try and update the system to prevent risks.", num)
  if num == "1" then
    str = i18n.translate("There is %s security vulnerability. Please try and update the system to prevent risks.", num)
  end
  if securityUpdateNotShown then
    naughty.notify(
      {
        title = i18n.translate("Security Updates"),
        text = str,
        icon = icon,
        timeout = 10,
        urgency = "critical",
        app_name = i18n.translate("Security center")
      }
    ):connect_signal(
      "destroyed",
      function()
        -- we already notified the users of the security update
        -- we don't want to spam them every x minutes
        securityUpdateNotShown = false
      end
    )
  end
end

local COMMAND = "/bin/bash " .. "/etc/xdg/tde/updater.sh"
watch(
  COMMAND,
  config.package_timeout,
  function(_, stdout)
    local _ = split(stdout)
    numOfUpdatesAvailable = _[1]
    numOfSecUpdatesAvailable = _[2]
    print("Packages to update: " .. numOfUpdatesAvailable)
    print("Security patch packages to update: " .. numOfSecUpdatesAvailable)
    local widgetIconName
    if numOfUpdatesAvailable == "0" then
      widgetIconName = "package"
      updateAvailable = false
    elseif not (numOfSecUpdatesAvailable == "0") then
      widgetIconName = "package-sec"
      notifySecurityUpdate(numOfSecUpdatesAvailable)
      updateAvailable = true
    else
      widgetIconName = "package-up"
      updateAvailable = true
    end
    widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. ".svg"))
    signals.emit_packages_to_update(numOfUpdatesAvailable)
  end,
  widget
)

return widget_button
