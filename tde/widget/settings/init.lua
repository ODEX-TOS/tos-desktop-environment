local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local file_exists = require("lib-tde.file").exists
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")
local naughty = require("naughty")
local plugins = require("lib-tde.plugin-loader")("settings")
local err = require("lib-tde.logger").error

root.elements = {}
root.widget = {}
root.elements.settings_views = {}

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_height = dpi(800)
local settings_nw = dpi(260)
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
      title = "Plugin error",
      urgency = "critical",
      message = msg,
      timeout = 10
    }
  )
end

function close_views()
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
end

function enable_view_by_index(i, s, loc)
  if root.elements.settings_views[i] then
    close_views()
    print("Starting keygrab")
    grabber:start()

    root.elements.settings_views[i].view.visible = true
    root.elements.settings_views[i].title.font = beautiful.title_font
    if root.elements.settings_views[i].view.refresh then
      root.elements.settings_views[i].view.refresh()
    end
    if not s then
      return
    end
    -- center the hub in height
    root.elements.settings.y = ((s.workarea.height - settings_height - m) / 2) + s.workarea.y
    if loc == "right" then
      root.elements.settings.x = (s.workarea.width - settings_width - m) + s.workarea.x
    else
      root.elements.settings.x = ((s.workarea.width / 2) - (settings_width / 2)) + s.workarea.x
    end
    root.elements.settings.visible = true
  end
end

function make_view(i, t, v, a)
  local button = wibox.container.background()
  button.forced_height = m + settings_index + m

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

  button:connect_signal(
    "mouse::enter",
    function()
      button.bg = beautiful.accent.hue_600
    end
  )
  button:connect_signal(
    "mouse::leave",
    function()
      button.bg = beautiful.bg_modal_title .. "00"
    end
  )

  button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          close_views()
          view.visible = true
          title.font = beautiful.title_font
          if view.refresh then
            view.refresh()
          end
        end
      )
    )
  )
  button:setup {
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

  return {link = button, view = view, title = title}
end

function make_nav()
  local nav = wibox.container.background()
  nav.bg = beautiful.bg_modal_title
  nav.forced_width = settings_nw

  local user = wibox.widget.textbox("")
  user.font = beautiful.title_font
  awful.spawn.easy_async_with_shell(
    "whoami",
    function(u)
      user.text = u:gsub("^%s*(.-)%s*$", "%1")
    end
  )
  local img = os.getenv("HOME") .. "/.cache/tos/user-icons/user.jpg"
  if not file_exists(img) then
    img = "/etc/xdg/awesome/user-profile/icons/user.svg"
  end

  local avatar =
    wibox.widget {
    layout = wibox.container.background,
    shape = gears.shape.circle,
    shape_clip = gears.shape.circle,
    forced_width = settings_index,
    forced_height = settings_index,
    {
      widget = wibox.widget.imagebox,
      image = img,
      resize = true
    }
  }

  local rule = wibox.container.background()
  rule.forced_height = 1
  rule.bg = beautiful.background.hue_800
  rule.widget = wibox.widget.base.empty_widget()

  table.insert(
    root.elements.settings_views,
    make_view(icons.calendar, "calendar", require("widget.settings.calendar")())
  )
  table.insert(
    root.elements.settings_views,
    make_view(icons.wifi, "connections", require("widget.settings.connections")())
  )
  table.insert(root.elements.settings_views, make_view(icons.chart, "system", require("widget.settings.system")()))
  table.insert(root.elements.settings_views, make_view(icons.monitor, "display", require("widget.settings.display")()))
  table.insert(root.elements.settings_views, make_view(icons.volume, "media", require("widget.settings.media")()))

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

  local power = wibox.container.background()
  local red = require("theme.mat-colors").red
  power.bg = red.hue_600
  power.shape = rounded()
  power.forced_height = settings_index

  power:connect_signal(
    "mouse::enter",
    function()
      power.bg = red.hue_800
    end
  )
  power:connect_signal(
    "mouse::leave",
    function()
      power.bg = red.hue_600
    end
  )

  power:setup {
    layout = wibox.container.place,
    halign = "center",
    wibox.widget.imagebox(icons.power)
  }
  power:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          _G.exit_screen_show()
        end
      )
    )
  )

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

  return nav
end

return function()
  local hub =
    wibox(
    {
      ontop = true,
      visible = false,
      type = "toolbar",
      bg = beautiful.background.hue_800,
      width = settings_width,
      height = settings_height,
      screen = awful.screen.primary
    }
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
          hub.visible = false
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

  hub.close = function()
    root.elements.settings_grabber:stop()
    hub.visible = false
  end
  hub.enable_view_by_index = enable_view_by_index
  hub.close_views = close_views
  hub.make_view = make_view

  close_views()
  root.elements.settings = hub
end
