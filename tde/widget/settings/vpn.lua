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
local file = require("lib-tde.file")
local mat_colors = require("theme.mat-colors")
local card = require("lib-widget.card")
local button_widget = require("lib-widget.button")
local inputfield = require("lib-widget.inputfield")
local signals = require("lib-tde.signals")
local scrollbox = require("lib-widget.scrollbox")
local highlight_text = require("lib-tde.function.common").highlight_text
local icons = require("theme.icons")
local naughty = require("naughty")

local dpi = beautiful.xresources.apply_dpi

local m = dpi(10)

local function refresh() end

local function fetch_open_vpn_files()
  local result = {}

  local dirs = {os.getenv("HOME") .. "/Documents", os.getenv("HOME") .. "/VPN", os.getenv("HOME") .. "/vpn"}

  for _, dir in ipairs(dirs) do
    for _, _file in ipairs(file.list_dir(dir)) do
      if string.sub(_file, #_file-4, #_file) == ".ovpn" then
        table.insert(result, _file)
      end
    end
  end

  return result
end

local function pid_exists(pid)
  pid = math.floor(pid)
  return file.dir_exists('/proc/' .. tostring(pid))
end


local function connect_to_vpn(_file, user, pass)
  local tmp_file = file.mktemp()
  file.overwrite(tmp_file, user .. '\n' .. pass .. '\n')

  _G.save_state.vpn_data[_file] = {
    username = user,
    password = pass,
    active = true
  }

  root.elements.settings.close()

  local cmd = "pkexec openvpn --config " .. _file

  if user ~= "" and pass ~= "" then
    cmd = cmd .. " --auth-user-pass" .. " " .. tmp_file
  end

  _G.save_state.vpn_data[_file].pid = awful.spawn.easy_async(cmd, function(_, _, _, code)
    _G.save_state.vpn_data[_file].active = false
    _G.save_state.vpn_data[_file].pid = nil
    signals.emit_vpn_connection_data(_G.save_state.vpn_data)

    file.rm(tmp_file)

    -- something went wrong when connecting, telling user that the vpn ended in a crash
    local urgency = "normal"
    if code ~= 0 then
      urgency = "critical"
    end

    naughty.notification({
      title = i18n.translate("VPN"),
      text = i18n.translate('VPN stopped'),
      timeout = 5,
      urgency = urgency,
      icon = icons.vpn
    })

    refresh()
  end)

  signals.emit_vpn_connection_data(_G.save_state.vpn_data)

  refresh()
end

-- This is used by the stop() function to remove focus on the inputfields
local _field_reset = {}

local __openvpn_cache = {}

local function create_openvpn_config(_file)

  if __openvpn_cache[_file] ~= nil then
    return __openvpn_cache[_file]
  end

  local canonical = file.basename(_file)
  canonical = string.sub(canonical, 0, #canonical - 5)

  local vpn_card = card({title=canonical})

  local username_field = inputfield({
    typing_callback = function(text)
      if _G.save_state.vpn_data[_file] ~= nil then
        _G.save_state.vpn_data[_file].username = text
      else
        _G.save_state.vpn_data[_file] = {
          active = false,
          username = text,
          password = ""
        }
      end
    end,
    icon = icons.user
  })

  local password_field = inputfield({
    typing_callback = function(text)
      if _G.save_state.vpn_data[_file] ~= nil then
        _G.save_state.vpn_data[_file].password = text
      else
        _G.save_state.vpn_data[_file] = {
          active = false,
          username = "",
          password = text
        }
      end
    end,
    hidden = true,
    icon = icons.password
  })

  table.insert(_field_reset, username_field)
  table.insert(_field_reset, password_field)

  if _G.save_state.vpn_data[_file] ~= nil then
    username_field.update_text(_G.save_state.vpn_data[_file].username)
    password_field.update_text(_G.save_state.vpn_data[_file].password)
  end

  local username_ratio = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    wibox.widget.textbox("Username"),
    wibox.widget.base.empty_widget(),
    username_field
  }

  local password_ratio = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    wibox.widget.textbox("Password"),
    wibox.widget.base.empty_widget(),
    password_field
  }

  username_ratio:adjust_ratio(2, 0.15, 0.05, 0.8)
  password_ratio:adjust_ratio(2, 0.15, 0.05, 0.8)


  local connect = button_widget({
    body = "Connect",
    callback = function()
      print("Connecting vpn profile: ")
      print(_file)
      connect_to_vpn(_file, username_field.get_text(), password_field.get_text())
    end
  })

  local disconnect = button_widget({
    body = "Disconnect",
    callback = function()
      if _G.save_state.vpn_data[_file] ~= nil and _G.save_state.vpn_data[_file].pid ~= nil then
        root.elements.settings.close()
        awful.spawn.easy_async("pkexec kill " .. tostring(math.floor(_G.save_state.vpn_data[_file].pid)), function(_,_,_, code)
          if code == 0 then
            _G.save_state.vpn_data[_file].pid = nil
            _G.save_state.vpn_data[_file].active = false
            refresh()
          end
        end)
      end
    end,
    pallet = mat_colors.red,
    no_update = true
  })

  local _btn_widget

  if _G.save_state.vpn_data[_file] ~= nil and _G.save_state.vpn_data[_file].active and pid_exists(_G.save_state.vpn_data[_file].pid) then
    _btn_widget = wibox.container.margin(disconnect,m*2,m,m,m)
  else
    _btn_widget = wibox.container.margin(connect,m*2,m,m,m)
  end

  vpn_card.update_body(wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = m,
    wibox.container.margin(username_ratio,m,m,m,m),
    wibox.container.margin(password_ratio,m,m,m,m),
    _btn_widget,
  })

  __openvpn_cache[_file] = wibox.container.margin(vpn_card, m*2, m*2 ,m*2, m*2)
  return __openvpn_cache[_file]
end


return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local layout = wibox.layout.fixed.vertical()

  local notify_text = i18n.translate("Openvpn files should be present in either %s or %s", highlight_text("~/Documents"), highlight_text("~/vpn"))

  local textbox = wibox.widget {
    widget = wibox.widget.textbox,
    markup = notify_text
  }

  local textbox_card = card()

  textbox_card.update_body(wibox.widget {
    widget = wibox.container.place,
    forced_height = m * 10,
    textbox
  })

  local scroll = scrollbox(layout)

  view:setup {
    layout = wibox.container.background,
    bg = beautiful.transparent,
    scroll
  }



  refresh = function()
    scroll.reset()

    -- get all openvpn files
    local files = fetch_open_vpn_files()

    layout.children = {}

    -- we have multiple ovpn files, now lets display them
    for _, _file in ipairs(files) do
      layout:add(create_openvpn_config(_file))
    end

    if #files == 0 then
      layout:add(wibox.container.margin(textbox_card, m*2, m*2 ,m*2, m*2))
    end
  end

  view.refresh = refresh

  -- Ensure the inputfields lose focus
  view.stop = function ()
    for _, field in ipairs(_field_reset) do
      field.reset()
    end
  end


  view.stop_view = function()
    print("Stopping vpn view")
    signals.emit_vpn_connection_data(_G.save_state.vpn_data)
  end
  return view
end
