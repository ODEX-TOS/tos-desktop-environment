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

local weak = {}
weak.__mode = "k"
setmetatable(root.elements, weak)
setmetatable(root.widget, weak)
setmetatable(root.elements.settings_views, weak)

local view_container = wibox.layout.stack()

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_height = dpi(1000)
local settings_nw = dpi(260)

-- This gets populated by the scrollbox
local body = {}

-- if we are dragging the settings app with the mouse
local bIsDragging = false

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
        modifiers = keyconfig.to_modifiers("settings"),
        key = keyconfig.to_key_string("settings"),
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

      if v.view.stop ~= nil and type(v.view.stop) == "function" then
        v.view.stop()
      end

    end,
    root.elements.settings_views
  )
  if grabber.is_running then
    grabber:stop()
  end

  -- make sure we have no lingering keygrabber left
  -- Some grabbers might use a 'stop_callback' and start another grabber
  while awful.keygrabber.is_running do
    awful.keygrabber.current_instance:stop()
  end



  -- perform an entire garbage collection
  -- this operation is heavy
  -- however the settings app can open up a lot of images which will consume a lot of memory
  collectgarbage("collect")
end

local title = wibox.widget.textbox()
title.font = beautiful.title_font


local function setActiveView(i, link)
  print("Active view: " .. i)
  for index, widget in ipairs(root.elements.settings_views) do
    if index == i or widget.link == link then
      root.elements.settings_views[index].link.active = true
      root.elements.settings_views[index].link.activate()
      title.text = root.elements.settings_views[index].title.text or ""
      INDEX = index
      view_container:raise(index)
    elseif root.elements.settings_views[index].link.active then
      root.elements.settings_views[index].link.bg = beautiful.bg_modal_title .. "00"
      root.elements.settings_views[index].link.active = false
      -- Ensure that button presses call this function
      if root.elements.settings_views[INDEX].view.stop_view then
        root.elements.settings_views[INDEX].view.stop_view()
      end
    end
  end
end


-- If you set the index to -1 then we go to the last remembered index
local function enable_view_by_index(i, s, bNoAnimation)
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

    if not s then
      return
    end

    -- reset the scrollbox when we open the settings app
    if not root.elements.settings.visible then
      body:reset()
      -- center the hub in height
      local y_height = ((s.workarea.height - settings_height - m) / 2) + s.workarea.y
      root.elements.settings.x = ((s.workarea.width / 2) - (settings_width / 2)) + s.workarea.x
      root.elements.settings.visible = true

      if not (bNoAnimation == true) then
        root.elements.settings.y = s.geometry.y - settings_height
        animate(_G.anim_speed, root.elements.settings, {y = y_height}, "outCubic", function()
          if root.elements.settings_views[INDEX].view.refresh then
            root.elements.settings_views[INDEX].view.refresh()
          end
        end)
      -- IN case there should be no animation
      elseif root.elements.settings_views[INDEX].view.refresh then
        root.elements.settings_views[INDEX].view.refresh()
      end
    end
  end
end

local function make_view(i, t, v, a)
  local icon = wibox.widget.imagebox(i)
  icon.forced_height = settings_index
  icon.forced_width = settings_index
  icon.align = "center"

  local _title = wibox.widget.textbox(t)
  _title.font = beautiful.title_font

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
    margins = m/2,
    {
      layout = wibox.layout.align.horizontal,
      wibox.container.margin(icon, dpi(7), dpi(7), dpi(7), dpi(7)),
      {
        layout = wibox.container.margin,
        left = m,
        _title
      }
    }
  }

  -- weird hack in order to be able to use the setActiveView(-1, btn) line in the callback
  -- aka making sure a reference to the head pointer stays the same, even during construction
  local btn
  btn =
    button({
      body = btn_body,
      callback = function()
        close_views()
        view.visible = true
        setActiveView(-1, btn)
        if view.refresh then
          view.refresh()
        end
      end,
      center = false,
      -- when hover is lost we make the button transparent
      leave_callback = function(curr_btn)
        if curr_btn.active == false then
          curr_btn.bg = beautiful.transparent
        end
      end
    })
  btn.forced_height = (m * 1.5) + settings_index

  btn.bg = beautiful.bg_modal_title .. "00"
  btn.active = false

  btn.activate = function()
    btn.emulate_focus_loss()
  end

  return {link = btn, view = view, title = _title}
end

local function validate_plugin(plugin)
  if plugin.icon == nil then
    send_plugin_error("Settings app plugin is missing icon")
  elseif plugin.name == nil then
    send_plugin_error("Settings app plugin is missing name")
  elseif plugin.widget == nil then
    send_plugin_error("Settings app plugin is missing widget")
  else
    local view = make_view(plugin.icon, plugin.name, plugin.widget)
    table.insert(root.elements.settings_views, view)
    return view
  end
end

local function make_nav(load_callback)
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
  signals.emit_request_user()
  local img = "/etc/xdg/tde/widget/user-profile/icons/user.svg"

  local avatar =
    profilebox({
      picture = img,
      diameter = settings_index
    })


  signals.connect_profile_picture_changed(
    function(picture)
      avatar.update(picture)
    end
  )

  signals.emit_request_profile_pic()

  local rule = wibox.container.background()
  rule.forced_height = 1
  rule.bg = beautiful.background.hue_800 .. beautiful.background_transparency
  rule.widget = wibox.widget.base.empty_widget()

  signals.connect_background_theme_changed(
    function(theme)
      rule.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )


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
  local nav_btn_container = wibox.layout.fixed.vertical()

  body = scrollbox(nav_btn_container)

  nav_container.forced_width = settings_nw
  nav_container.forced_height = settings_height
  nav_btn_container:add(header)
  nav_btn_container:add(rule)
  nav_container:add(body)

  local function nav_container_populate()
    gears.table.map(
        function(v)
          nav_btn_container:add(v.link)
        end,
        root.elements.settings_views
    )
  end

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


  hardware.hasBluetooth(function(bHasBT)
    if bHasBT then
      local view = make_view(icons.bluetooth, i18n.translate("Bluetooth"), require("widget.settings.bluetooth")())
      table.insert(
        root.elements.settings_views,
        4,
        view
      )
      view.link.bg = beautiful.transparent
      view.link.active = false

    end
    hardware.has_package_installed("openvpn",function(bHasVPN)
      if bHasVPN then
        local view = make_view(icons.vpn, i18n.translate("VPN"), require("widget.settings.vpn")())
        table.insert(
          root.elements.settings_views,
          4,
          view
        )
        view.link.bg = beautiful.transparent
        view.link.active = false
      end
      nav_container_populate()
      load_callback()
    end)
  end)


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
    make_view(icons.plugin, i18n.translate("Plugins"), require("widget.settings.plugins")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.dwindle, i18n.translate("Tag"), require("widget.settings.tag")())
  )
  table.insert(
  root.elements.settings_views,
    make_view(icons.firewall, i18n.translate("Firewall"), require("widget.settings.firewall")())
  )
  table.insert(
    root.elements.settings_views,
      make_view(icons.mime, i18n.translate("Default Applications"), require("widget.settings.mime")())
    )
  table.insert(
    root.elements.settings_views,
    make_view(icons.about, i18n.translate("About"), require("widget.settings.about")())
  )

  if general["developer"] == "1" then
    table.insert(
      root.elements.settings_views,
      make_view(icons.developer, i18n.translate("Developer"), require("widget.settings.developer")())
    )
  end

  for _, plugin in ipairs(plugins) do
    validate_plugin(plugin)
  end

  local red = require("theme.mat-colors").red
  local power =
    button({
      body = wibox.widget.imagebox(icons.power),
      callback = function()
        root.elements.settings.close()
        _G.exit_screen_show()
      end,
      pallet = red
    })

  nav:setup {
    layout = wibox.container.place,
    {
      layout = wibox.layout.align.vertical,
      wibox.widget.base.empty_widget(),
      nav_container,
      {
        layout = wibox.container.margin,
        margins = m,
        power
      }
    }
  }

  return nav, nav_btn_container
end

return function()
  local scrn = screen.primary
  local hub =
    wibox(
    {
      ontop = true,
      visible = false,
      type = "toolbar",
      bg = beautiful.background.hue_800 .. beautiful.background_transparency,
      width = settings_width,
      height = settings_height,
      screen = scrn,
      shape = function(cr, shapeWidth, shapeHeight)
        gears.shape.rounded_rect(cr, shapeWidth, shapeHeight, _G.save_state.rounded_corner)
      end,
    }
  )

  signals.connect_change_rounded_corner_dpi(function(radius)
    hub.shape = function(cr, shapeWidth, shapeHeight)
      gears.shape.rounded_rect(cr, shapeWidth, shapeHeight, radius)
    end
  end)

  signals.connect_background_theme_changed(
    function(theme)
      hub.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )

  view_container.children = {}

  local nav, nav_btn_container = make_nav(function()
    gears.table.map(
      function(v)
        view_container:add(v.view)
      end,
      root.elements.settings_views
    )
  end)

  signals.connect_add_plugin(function(location, plugin)
    if location ~= "settings" then
      return
    end

    local view = validate_plugin(plugin)
    if view == nil then
      return
    end

    if root.elements.settings_views[INDEX].view.stop_view then
      root.elements.settings_views[INDEX].view.stop_view()
    end

    close_views()

    view_container:add(view.view)
    nav_btn_container:add(view.link)

    INDEX = #view_container.children
    root.elements.settings_views[INDEX].view.visible = true
    root.elements.settings_views[INDEX].title.font = beautiful.title_font

    setActiveView(INDEX)

    if view.view.refresh ~= nil then
      print("Refreshing the view")
      view.view.refresh()
    end
  end)

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

  local close = wibox.widget.imagebox(icons.close)
  close.forced_height = settings_index * 1.5
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

  local top_bar = wibox.widget {
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
  }

  top_bar:connect_signal("button::press", function()
    if bIsDragging then
      return
    end
    bIsDragging = true
    awful.mouse.wibox.move(hub, function()
      bIsDragging = false
    end)
  end)

  hub:setup {
    layout = wibox.layout.flex.vertical,
    {
      layout = wibox.layout.align.horizontal,
      nav,
      wibox.widget{
        layout = wibox.container.background,
        {
          layout = wibox.layout.fixed.vertical,
          top_bar,
          view_container
        }
      }
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

  hub.widget:connect_signal("button::press", function(_, _, _, btn, mods)
    if bIsDragging then
      return
    end

    if btn == 1 and mods[1] == modKey and #mods == 1 then
      bIsDragging = true
      awful.mouse.wibox.move(hub, function()
        bIsDragging = false
      end)
    end
  end)


  hub.close = function()
    bIsDragging = false
    scrn = screen.primary
    if root.elements.settings_views[INDEX].view.stop_view then
      root.elements.settings_views[INDEX].view.stop_view()
    end

    animate(
      _G.anim_speed,
      hub,
      {y = scrn.geometry.y - settings_height},
      "outCubic",
      function()
        hub.visible = false
        -- Make sure the settings are closed
        root.elements.settings_grabber:stop()
      end
    )
  end

  hub.enable_view_by_index = enable_view_by_index
  hub.close_views = close_views
  hub.make_view = make_view

  close_views()
  root.elements.settings = hub

  -- Let's ensure no lingering inputfield is active
  require("lib-widget.inputfield").unfocus()

  root.elements.settings_grabber:stop()


end
