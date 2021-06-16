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
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")
local naughty = require("naughty")
local plugins = require("lib-tde.plugin-loader")("settings")
local err = require("lib-tde.logger").error
local signals = require("lib-tde.signals")
local scrollbox = require("lib-widget.scrollbox")
local animate = require("lib-tde.animations").createAnimObject
local profilebox = require("lib-widget.profilebox")
local button = require("lib-widget.button")
local hardware = require("lib-tde.hardware-check")

local keyconfig = require("configuration.keys.mod")
local modKey = keyconfig.modKey

root.elements = {}
root.widget = {}
root.elements.settings_views = {}

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_height = dpi(900)
local settings_nw = dpi(260)

-- This gets populated by the scrollbox
local body = {}

-- save the index state of last time
local INDEX = 1

local grabber = root.elements.settings_grabber
if grabber == nil then
  grabber =
    awful.keygrabber {
    keybindings = {
      awful.key {
        modifiers = {},
        key = "Escape",
        on_press = function()
          if root.elements.settings then
            root.elements.settings.close()
          end
        end
      },
      awful.key {
        modifiers = {modKey},
        key = keyconfig.settings,
        on_press = function()
          if root.elements.settings then
            root.elements.settings.close()
          end
        end
      },
      awful.key {
        modifiers = {},
        key = "Up",
        on_press = function()
          if INDEX > 1 then
            root.elements.settings.enable_view_by_index(INDEX - 1, mouse.screen, true)
          end
        end
      },
      awful.key {
        modifiers = {},
        key = "Down",
        on_press = function()
          if INDEX < #root.elements.settings_views then
            root.elements.settings.enable_view_by_index(INDEX + 1, mouse.screen, true)
          end
        end
      },
      awful.key {
        modifiers = {"Control"},
        key = "Tab",
        on_press = function()
          if INDEX < #root.elements.settings_views then
            root.elements.settings.enable_view_by_index(INDEX + 1, mouse.screen, true)
          else
            root.elements.settings.enable_view_by_index(1, mouse.screen, true)
          end
        end
      },
      awful.key {
        modifiers = {"Control", "Shift"},
        key = "Tab",
        on_press = function()
          if INDEX > 1 then
            root.elements.settings.enable_view_by_index(INDEX - 1, mouse.screen, true)
          else
            root.elements.settings.enable_view_by_index(#root.elements.settings_views, mouse.screen, true)
          end
        end
      }
    },
    -- Note that it is using the key name and not the modifier name.
    stop_key = "Escape",
    stop_event = "release"
  }
  root.elements.settings_grabber = grabber
end

local function send_plugin_error(msg)
  print("SETTINGS APP: " .. msg, err)
  naughty.notification(
    {
      title = i18n.translate("Plugin error"),
      urgency = "critical",
      message = msg,
      timeout = 10
    }
  )
end

local function close_views()
  gears.table.map(
    function(v)
      v.view.visible = false
      v.title.font = beautiful.title_font
    end,
    root.elements.settings_views
  )
  if grabber.is_running then
    grabber:stop()
  end
  -- perform an entire garbage collection
  -- this operation is heavy
  -- however the settings app can open up a lot of images which will consume a lot of memory
  collectgarbage("collect")
end

local function setActiveView(i, link)
  print("Active view: " .. i)
  for index, widget in ipairs(root.elements.settings_views) do
    if index == i or widget.link == link then
      root.elements.settings_views[index].link.active = true
      root.elements.settings_views[index].link.activate()
      INDEX = index
    else
      root.elements.settings_views[index].link.bg = beautiful.bg_modal_title .. "00"
      root.elements.settings_views[index].link.active = false
    end
  end
end

-- If you set the index to -1 then we go to the last remembered index
local function enable_view_by_index(i, s, bNoAnimation)
  if root.elements.settings_views[INDEX].view.stop_view then
    root.elements.settings_views[INDEX].view.stop_view()
  end

  if not (i == -1) then
    INDEX = i
  end
  if root.elements.settings_views[INDEX] then
    close_views()
    print("Starting keygrab")
    grabber:start()

    root.elements.settings_views[INDEX].view.visible = true
    root.elements.settings_views[INDEX].title.font = beautiful.title_font
    setActiveView(INDEX)
    if root.elements.settings_views[INDEX].view.refresh then
      root.elements.settings_views[INDEX].view.refresh()
    end
    if not s then
      return
    end
    -- center the hub in height
    local y_height = ((s.workarea.height - settings_height - m) / 2) + s.workarea.y
    root.elements.settings.x = ((s.workarea.width / 2) - (settings_width / 2)) + s.workarea.x

    -- reset the scrollbox when we open the settings app
    if not root.elements.settings.visible then
      body:reset()
    end
    root.elements.settings.visible = true

    if not (bNoAnimation == true) then
      root.elements.settings.y = s.geometry.y - settings_height
      animate(_G.anim_speed, root.elements.settings, {y = y_height}, "outCubic")
    end
  end
end

local function make_view(i, t, v, a)
  local icon = wibox.widget.imagebox(i)
  icon.forced_height = settings_index
  icon.forced_width = settings_index
  icon.align = "center"

  local title = wibox.widget.textbox(t)
  if a == nil then
    title.font = beautiful.title_font
  else
    title.font = beautiful.title_font
  end

  local view = wibox.container.margin()
  view.margins = m
  if a == nil then
    view.visible = false
  else
    view.visible = true
  end

  if (v == nil) then
    view:setup {
      layout = wibox.container.place,
      valign = "center",
      halign = "center",
      {
        layout = wibox.container.background,
        wibox.widget.textbox(t)
      }
    }
  else
    view = v
  end

  local btn_body =
    wibox.widget {
    layout = wibox.container.margin,
    margins = m,
    {
      layout = wibox.layout.align.horizontal,
      wibox.container.margin(icon, dpi(7), dpi(7), dpi(7), dpi(7)),
      {
        layout = wibox.container.margin,
        left = m,
        title
      }
    }
  }

  -- weird hack in order to be able to use the setActiveView(-1, btn) line in the callback
  -- aka making sure a reference to the head pointer stays the same, even during construction
  local btn
  btn =
    button(
    btn_body,
    function()
      close_views()
      view.visible = true
      title.font = beautiful.title_font
      setActiveView(-1, btn)
      if view.refresh then
        view.refresh()
      end
    end,
    nil,
    true,
    nil,
    -- when hover is lost we make the button transparent
    function(curr_btn)
      if curr_btn.active == false then
        curr_btn.bg = beautiful.transparent
      end
    end
  )
  btn.forced_height = m + settings_index + m

  btn.activate = function()
    btn.emulate_focus_loss()
  end

  return {link = btn, view = view, title = title}
end

local function make_nav()
  local nav = wibox.container.background()
  nav.bg = beautiful.bg_modal_title
  nav.forced_width = settings_nw

  local user = wibox.widget.textbox("")
  user.font = beautiful.title_font
  signals.connect_username(
    function(name)
      user.text = name
    end
  )
  local img = "/etc/xdg/tde/widget/user-profile/icons/user.svg"

  local avatar =
    profilebox(
    img,
    settings_index,
    function(_)
    end
  )

  signals.connect_profile_picture_changed(
    function(picture)
      avatar.update(picture)
    end
  )

  local rule = wibox.container.background()
  rule.forced_height = 1
  rule.bg = beautiful.background.hue_800
  rule.widget = wibox.widget.base.empty_widget()

  signals.connect_background_theme_changed(
    function(theme)
      rule.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )

  table.insert(
    root.elements.settings_views,
    make_view(icons.settings, i18n.translate("General"), require("widget.settings.general")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.user, i18n.translate("User"), require("widget.settings.user")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.wifi, i18n.translate("Connections"), require("widget.settings.connections")())
  )

  if hardware.hasBluetooth() then
    table.insert(
      root.elements.settings_views,
      make_view(icons.bluetooth, i18n.translate("Bluetooth"), require("widget.settings.bluetooth")())
    )
  end

  table.insert(
    root.elements.settings_views,
    make_view(icons.chart, i18n.translate("System"), require("widget.settings.system")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.monitor, i18n.translate("Display"), require("widget.settings.display")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.volume, i18n.translate("Media"), require("widget.settings.media")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.mouse, i18n.translate("Mouse"), require("widget.settings.mouse")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.brush, i18n.translate("Theme"), require("widget.settings.theme")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.dwindle, i18n.translate("Tag"), require("widget.settings.tag")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.about, i18n.translate("About"), require("widget.settings.about")())
  )

  for _, value in ipairs(plugins) do
    if value.icon == nil then
      send_plugin_error("Settings app plugin is missing icon")
    elseif value.name == nil then
      send_plugin_error("Settings app plugin is missing name")
    elseif value.wibox == nil then
      send_plugin_error("Settings app plugin is missing widget")
    else
      table.insert(root.elements.settings_views, make_view(value.icon, value.name, value.wibox))
    end
  end

  local header = wibox.container.margin()
  header.margins = m
  header.forced_height = m + settings_index + m
  header:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.container.margin,
      right = m,
      avatar
    },
    user
  }

  local nav_container = wibox.layout.fixed.vertical()
  nav_container.forced_width = settings_nw
  nav_container.forced_height = settings_height
  nav_container:add(header)
  nav_container:add(rule)
  gears.table.map(
    function(v)
      nav_container:add(v.link)
    end,
    root.elements.settings_views
  )

  local red = require("theme.mat-colors").red
  local power =
    button(
    wibox.widget.imagebox(icons.power),
    function()
      root.elements.settings.close()
      _G.exit_screen_show()
    end,
    red
  )

  body = scrollbox(nav_container)

  nav:setup {
    layout = wibox.container.place,
    {
      layout = wibox.layout.align.vertical,
      wibox.widget.base.empty_widget(),
      body,
      {
        layout = wibox.container.margin,
        margins = m,
        power
      }
    }
  }

  return nav
end

return function()
  local scrn = screen.primary
  local hub =
    wibox(
    {
      ontop = true,
      visible = false,
      type = "toolbar",
      bg = beautiful.background.hue_800,
      width = settings_width,
      height = settings_height,
      screen = scrn
    }
  )

  signals.connect_background_theme_changed(
    function(theme)
      hub.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )

  local nav = make_nav()
  local view_container = wibox.layout.stack()
  gears.table.map(
    function(v)
      view_container:add(v.view)
    end,
    root.elements.settings_views
  )

  hub:buttons(
    gears.table.join(
      awful.button(
        {},
        3,
        function()
          if hub.close then
            hub.close()
          end
        end
      )
    )
  )

  hub:setup {
    layout = wibox.layout.flex.vertical,
    {
      layout = wibox.layout.align.horizontal,
      nav,
      view_container
    }
  }

  signals.connect_refresh_screen(
    function()
      scrn = mouse.screen
      -- we only need to update the 'center' position when the hub is visible
      if hub.visible then
        hub.x = ((scrn.workarea.width / 2) - (settings_width / 2)) + scrn.workarea.x
        hub.y = ((scrn.workarea.height - settings_height - m) / 2) + scrn.workarea.y
      end
    end
  )

  hub.close = function()
    if root.elements.settings_views[INDEX].view.stop_view then
      root.elements.settings_views[INDEX].view.stop_view()
    end

    root.elements.settings_grabber:stop()

    animate(
      _G.anim_speed,
      hub,
      {y = scrn.geometry.y - settings_height},
      "outCubic",
      function()
        hub.visible = false
      end
    )
  end
  hub.enable_view_by_index = enable_view_by_index
  hub.close_views = close_views
  hub.make_view = make_view

  close_views()
  root.elements.settings = hub
end
