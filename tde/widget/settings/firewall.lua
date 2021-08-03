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
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")
local naughty = require("naughty")


local common = require("lib-tde.function.common")

local signals = require("lib-tde.signals")

local firewall = require("lib-tde.firewall")

local loading = require("lib-widget.loading")()
loading.stop()

local card = require('lib-widget.card')
local button = require('lib-widget.button')
local inputfield = require('lib-widget.inputfield')

local colorized_svg = require("lib-tde.function.svg").colorize

local LIST_STATE = 0
local ADD_STATE = 1

local STATE = LIST_STATE

local m = dpi(10)
local settings_index = dpi(40)

local active_rule_list = wibox.layout.fixed.vertical()
active_rule_list.spacing = m

local refresh = function (_)

end

local _svg
local not_exists_text
local empty_text
local disabled_text

local function notify_invalid(txt)
  naughty.notification(
    {
        title = i18n.translate("Firewall"),
        text = txt,
        timeout = 5,
        icon = icons.firewall
    }
)
end

local function gen_images()
  if _svg ~= nil and not_exists_text ~= nil and empty_text ~= nil and disabled_text then
    return
  end
  _svg = colorized_svg(icons.firewall_Large, "#00b0ff", beautiful.primary.hue_500)
  not_exists_text = wibox.container.place(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      wibox.widget {
        widget = wibox.widget.imagebox,
        id = "img",
        image = _svg,
        resize = true,
        forced_height = dpi(200)
      },
      wibox.container.margin(wibox.widget.base.empty_widget(), 0,0, m,m),
      wibox.widget {
        widget = wibox.widget.textbox,
        text = i18n.translate("No firewall installed"),
        align = "center",
        valign = "center",
        font = beautiful.title_font
      }
    }
  )

  disabled_text = wibox.container.place(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      wibox.widget {
        widget = wibox.widget.imagebox,
        id = "img",
        image = _svg,
        resize = true,
        forced_height = dpi(200)
      },
      wibox.container.margin(wibox.widget.base.empty_widget(), 0,0, m,m),
      wibox.widget {
        widget = wibox.widget.textbox,
        text = i18n.translate("Firewall disabled"),
        align = "center",
        valign = "center",
        font = beautiful.title_font
      }
    }
  )

  empty_text = wibox.container.place(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      wibox.widget {
        widget = wibox.widget.imagebox,
        id = "img",
        image = _svg,
        resize = true,
        forced_height = dpi(200)
      },
      wibox.container.margin(wibox.widget.base.empty_widget(), 0,0, m,m),
      wibox.widget {
        widget = wibox.widget.textbox,
        text = i18n.translate("No rules found"),
        align = "center",
        valign = "center",
        font = beautiful.title_font
      }
    }
  )

  not_exists_text.set_image = function(self, svg)
    self.children[1].children[1]:set_image(svg)
  end
  disabled_text.set_image = function(self, svg)
    self.children[1].children[1]:set_image(svg)
  end
  empty_text.set_image = function(self, svg)
    self.children[1].children[1]:set_image(svg)
  end

  signals.connect_primary_theme_changed(function(pallet)
    _svg = colorized_svg(icons.firewall_Large, "#00b0ff", pallet.hue_500)
    if not_exists_text ~= nil then
      not_exists_text:set_image(_svg)
    end
    if disabled_text ~= nil then
      disabled_text:set_image(_svg)
    end
    if empty_text ~= nil then
      empty_text:set_image(_svg)
    end
  end)
end



local function start_loading()
  active_rule_list.children = {}
  loading.start()
  active_rule_list:add(wibox.container.place(loading))
  root.elements.settings.ontop = false
  root.elements.settings_grabber:stop()
end

local function stop_loading(bFromRefresh)
  loading.stop()
  -- Regrab the focus back (unless we closed the settings)
  if root.elements.settings.visible then
    root.elements.settings.ontop = true
    root.elements.settings_grabber:start()
  end

  if bFromRefresh ~= true then
    refresh(false)
  end
end

local rules = {}
local is_active = false

local function equals(rule1, rule2)
  if type(rule1) ~= "table" or type(rule2) ~= "table" then
    return false
  end

  return rule1.ip == rule2.ip and
  rule1.port == rule2.port and
  rule1.default == rule2.default and
  rule1.state == rule2.state and
  rule1.direction == rule2.direction
end

local function create_rule_card(rule)
  local ip = rule.ip
  local port = rule.port
  if rule.ip == "" or rule.ip == nil then
    ip = "Anywhere"
  end

  if rule.port == "" or rule.port == nil then
    port = "Anywhere"
  end

  local _card = card()

  local _table = wibox.widget {
    layout = wibox.layout.flex.horizontal,
    wibox.widget.textbox(i18n.translate(rule.direction)),
    wibox.widget.textbox(i18n.translate(rule.state)),
    wibox.widget.textbox(ip),
    wibox.widget.textbox(port)
  }

  local remove_button = wibox.widget {
    wibox.widget {
      wibox.widget {
              image = icons.close,
              resize = true,
              forced_height = dpi(20),
              widget = wibox.widget.imagebox
          },
          layout = wibox.container.place
      },
      shape = function(cr, width, height)
          gears.shape.circle(cr, width, height, height/2)
      end,
      widget = wibox.container.background
  }

  remove_button:connect_signal("button::press", function()
    print("Removing rule")
    print(rule)
    start_loading()
    firewall.remove_rule(rule, function()
      -- find the rule in _rules and remove it
      for index, _rule in ipairs(rules) do
        if equals(_rule, rule) then
          table.remove(rules, index)
        end
      end
      stop_loading()
    end)
  end)

  remove_button:connect_signal("mouse::enter", function()
    remove_button.bg = beautiful.groups_bg
  end)

  remove_button:connect_signal("mouse::leave", function()
    remove_button.bg = beautiful.transparent
  end)

  local body = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    _table,
    wibox.widget.base.empty_widget(),
    remove_button,
  }

  body.forced_height = dpi(20)

  body:adjust_ratio(2, 0.8, 0.05, 0.15)

  _card.update_body(
    wibox.container.margin(body,m,m,m,m)
  )

  return wibox.container.margin(_card, m,m, 0, 0)
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox(i18n.translate("Firewall"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  view:setup {
    layout = wibox.container.background,
    active_rule_list
  }

  local function populate_data(_rules, _is_active)
    rules = _rules
    is_active = _is_active

    active_rule_list.children = {}
    stop_loading(true)

    active_rule_list:add(button("Toggle Firewall", function()
      is_active = not is_active
      start_loading()
      firewall.set_active(is_active, function ()
        stop_loading(true)
        -- in case we go active, repopulate the list
        refresh(false)
      end)
    end))

    active_rule_list:add(button("Reload rules", function()
      STATE = LIST_STATE
      refresh(true)
    end))

    if is_active then
      active_rule_list:add(button("Add rule", function()
        STATE = ADD_STATE
        refresh(false)
      end))
      if #rules == 0 then
        active_rule_list:add(empty_text)
      end
      for _, rule in ipairs(rules) do
        active_rule_list:add(create_rule_card(rule))
      end
    else
      active_rule_list:add(disabled_text)
    end

  end

  local button_widgets = {}

  local function create_multi_option_array(name, tooltip, options, default, changed_callback)
    local name_widget =
      wibox.widget {
      text = name,
      font = beautiful.title_font,
      widget = wibox.widget.textbox
    }
    if tooltip then
      awful.tooltip {
        objects = {name_widget},
        timer_function = function()
          return tooltip
        end
      }
    end
    local layout = wibox.layout.ratio.horizontal()
    local flex = wibox.layout.flex.horizontal()

    flex.spacing = m

    layout:add(name_widget)
    layout:add(wibox.widget.base.empty_widget())
    layout:add(flex)

    layout:adjust_ratio(2, 0.15, 0.05, 0.8)

    button_widgets[name] = {}
    for _, option in ipairs(options) do
      -- leave focus button callback
      local leave = function()
        if button_widgets[name][option] == nil then
          return
        end
        if button_widgets[name][option].active then
          button_widgets[name][option].bg = beautiful.primary.hue_600
        else
          button_widgets[name][option].bg = beautiful.bg_modal
        end
      end

      -- the button object
      local option_widget
      option_widget =
        button(
        option,
        function()
          print("Pressed button")
          for _, widget in pairs(button_widgets[name]) do
            widget.bg = beautiful.bg_modal
            widget.active = false
          end
          option_widget.bg = beautiful.primary.hue_800
          option_widget.active = true

          if type(changed_callback) == "function" then
            changed_callback(option)
          end
        end,
        nil,
        nil,
        nil,
        leave
      )

      option_widget.forced_height = settings_index * 0.7

      if option == default then
        option_widget.active = true
      else
        option_widget.bg = beautiful.bg_modal
      end

      button_widgets[name][option] = option_widget
      flex:add(option_widget)
    end
    return layout
  end

  local function add_state_func()
    active_rule_list.children = {}
    local weak = {}
    weak.__mode = "k"
    setmetatable(active_rule_list.children, weak)

    local rule = {
      default = false,
      port = nil,
      ip = nil,
      state = firewall.state.DENY,
      direction = firewall.direction.IN
    }

    -- it can either be an ip (x.y.z.a) or a network (x.y.z.a/b) where b >=0 and b <= 32 and x,y,z,a are between 0 and 255
    local function is_ip(text)
      if text == "" then
        return false
      end

      -- check if it has a network component
      local network_split = common.split(text, '/')
      if #network_split == 2 and tonumber(network_split[2]) ~= nil then
        local num = tonumber(network_split[2])
        if num >= 0 and num <= 32 and is_ip(network_split[1]) then
          return true
        end
      elseif #network_split == 1 then
        -- this should be an ip
        local octets = common.split(network_split[1], '%.')
        -- an ip address consists of 4 octets
        if #octets ~= 4 then
          return false
        end

        -- check if each octet it a number and is between 0 and 255, otherwise it isn't an ip
        for _, octet in ipairs(octets) do
          local num_octet = tonumber(octet)
          if num_octet == nil then
            return false
          end

          if num_octet < 0 or num_octet > 255 then
            return false
          end
        end
        return true
      end
      return false
    end

    local port_if
    local port_done = function (text)
      if text == "" then
        rule.port = nil
        return false
      end
      local _is_valid = false
      local res = common.split(text, ':')

      -- check that the format is either a number or two number in the form x-y where x < y
      if #res == 1 and tonumber(res[1]) ~= nil then
        _is_valid = true
      elseif #res == 2 and tonumber(res[1]) ~= nil and tonumber(res[2]) ~= nil and tonumber(res[2])  > tonumber(res[1]) then
        _is_valid = true
      end

      if _is_valid then
        rule.port = text
      else
        notify_invalid(i18n.translate("Port %s is invalid", text))
        rule.port = nil
        port_if.clear_text()
      end
    end
    port_if = inputfield(nil, port_done)
    local ip_if

    local ip_done = function (text)
      if text == "" then
        rule.ip = nil
        return false
      end

      local _is_valid = is_ip(text)

      if _is_valid then
        rule.ip = text
      else
        notify_invalid(i18n.translate("Ip address %s is invalid", text))
        rule.ip = nil
        ip_if.clear_text()
      end
    end

    ip_if = inputfield(nil, ip_done)

    local state_btn = create_multi_option_array("State", nil, {firewall.state.DENY, firewall.state.ALLOW}, firewall.state.DENY, function (state)
      rule.state = state
    end)
    local dir_btn = create_multi_option_array("Direction", nil, {firewall.direction.OUT, firewall.direction.IN}, firewall.direction.IN, function (dir)
      rule.direction = dir
    end)


    local btn = button("Save", function ()

      port_done(port_if.get_text())
      ip_done(ip_if.get_text())

      if rule.ip == nil and rule.port == nil then
        STATE = LIST_STATE
        refresh(false)
        return
      end

      start_loading()
      firewall.add_rule(rule, function()
        table.insert(rules, rule)
        STATE = LIST_STATE
        stop_loading(true)
        refresh(false)
      end)
    end)


    local ip_box = wibox.widget {
      layout = wibox.layout.ratio.horizontal,
      wibox.widget {
        text = i18n.translate("IP"),
        font = beautiful.title_font,
        widget = wibox.widget.textbox
      },
      wibox.widget.base.empty_widget(),
      ip_if,
    }

    local port_box = wibox.widget {
      layout = wibox.layout.ratio.horizontal,
      wibox.widget {
        text = i18n.translate("Port"),
        font = beautiful.title_font,
        widget = wibox.widget.textbox
      },
      wibox.widget.base.empty_widget(),
      port_if,
    }

    ip_box:adjust_ratio(2, 0.15, 0.05, 0.8)
    port_box:adjust_ratio(2, 0.15, 0.05, 0.8)

    active_rule_list:add(wibox.widget {
      layout = wibox.layout.fixed.vertical,
      spacing = m,
      dir_btn,
      state_btn,
      ip_box,
      port_box,
      btn,
    })
  end

  local function list_state_func(fetch_data)
    active_rule_list.children = {}
    local weak = {}
    weak.__mode = "k"
    setmetatable(active_rule_list.children, weak)


    start_loading()

    local installed = firewall.is_installed()

    if fetch_data and installed then
      firewall.get_rules(populate_data)
    elseif not installed then
      stop_loading(true)
      active_rule_list.children = {}
      setmetatable(active_rule_list.children, weak)
      active_rule_list:add(not_exists_text)
    else
      populate_data(rules, is_active)
    end
  end

  refresh = function (fetch_data)
    if fetch_data == nil then
      fetch_data = #rules == 0
    end

    gen_images()

   if STATE == ADD_STATE then
    add_state_func()
   else
    STATE = LIST_STATE
    list_state_func(fetch_data)
   end
  end

  view.refresh = refresh

  return view
end
