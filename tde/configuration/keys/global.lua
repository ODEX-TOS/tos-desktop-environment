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
require("awful.autofocus")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local has_package_installed = require("lib-tde.hardware-check").has_package_installed
require("awful.hotkeys_popup.keys")

local config = require("configuration.keys.mod")
local modkey = config.modKey
local altkey = config.altKey
local apps = require("configuration.apps")
local xrandr = require("lib-tde.xrandr")

-- returns true if we cannot create a screenshot
local function send_notification_if_maim_missing()
  if not has_package_installed("maim") then
    require("naughty").notification(
      {
        title = "cannot create screenshot",
        message = "maim is not installed, install it using tde-contrib package",
        app_name = "tde package notifier"
      }
    )
    return true
  end
  return false
end

-- Key bindings
local globalKeys =
  awful.util.table.join(
  -- Hotkeys
  awful.key({modkey}, "F1", hotkeys_popup.show_help, {description = "show help", group = "awesome"}),
  -- Custom Keys
  awful.key(
    {modkey},
    config.randr,
    function()
      xrandr.xrandr()
    end,
    {description = "Launch screen layout mode", group = "Launcher"}
  ),
  awful.key(
    {modkey},
    config.terminal,
    function()
      print("Spawning terminal")
      awful.spawn(apps.default.terminal)
    end,
    {description = "Open Terminal", group = "Launcher"}
  ),
  awful.key(
    {modkey},
    config.window,
    function()
      print("Spawning rofi window switcher")
      awful.spawn(apps.default.rofiwindowswitch)
    end,
    {description = "Open a Window Switcher", group = "launcher"}
  ),
  awful.key(
    {modkey},
    config.launcher,
    function()
      print("Spawning rofi app menu")
      awful.spawn(apps.default.rofiappmenu)
    end,
    {description = "Open Rofi", group = "Launcher"}
  ),
  awful.key(
    {modkey, "Shift"},
    config.browser,
    function()
      local browser = os.getenv("BROWSER") or "firefox-developer-edition"
      print("Opening browser: " .. browser)
      awful.spawn(browser)
    end,
    {description = "Open Browser", group = "Launcher"}
  ),
  awful.key(
    {modkey, "Shift"},
    config.filemanager,
    function()
      print("Opening filemanager: thunar")
      awful.spawn("thunar")
    end,
    {description = "Open file manager", group = "Launcher"}
  ),
  awful.key(
    {"Control", "Shift"},
    config.monitor,
    function()
      print("Opening system monitor")
      awful.spawn("gnome-system-monitor")
    end,
    {description = "Open system monitor", group = "Launcher"}
  ),
  -- Screen Shots
  -- Screen Shot and Save
  awful.key(
    {},
    "Print",
    function()
      print("Taking a full screenshot")
      if not send_notification_if_maim_missing() then
        awful.spawn("snap full")
      end
    end
  ),
  -- Screen Shot Area and Save
  awful.key(
    {modkey, "Shift"},
    "s",
    function()
      print("Taking an area screenhot")
      if not send_notification_if_maim_missing() then
        awful.spawn("snap area")
      end
    end
  ),
  -- Toggle System Tray
  awful.key(
    {modkey},
    "=",
    function()
      print("Toggeling systray visibility")
      awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
    end,
    {description = "Toggle systray visibility", group = "custom"}
  ),
  -- Tag browsing
  awful.key({modkey}, config.previousWorkspace, awful.tag.viewprev, {description = "view previous", group = "tag"}),
  awful.key({modkey}, config.nextWorkspace, awful.tag.viewnext, {description = "view next", group = "tag"}),
  awful.key({modkey}, config.swapWorkspace, awful.tag.history.restore, {description = "go back", group = "tag"}),
  -- Default client focus
  awful.key(
    {modkey},
    "d",
    function()
      awful.client.focus.byidx(1)
    end,
    {description = "focus next by index", group = "client"}
  ),
  awful.key(
    {modkey},
    "a",
    function()
      awful.client.focus.byidx(-1)
    end,
    {description = "focus previous by index", group = "client"}
  ),
  awful.key(
    {modkey},
    config.configPanel,
    function()
      print("Showing action center")
      _G.screen.primary.left_panel:toggle(true)
    end,
    {description = "Open Control panel", group = "awesome"}
  ),
  awful.key({modkey}, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
  awful.key(
    {modkey},
    config.toggleFocus,
    function()
      awful.client.focus.history.previous()
      if _G.client.focus then
        _G.client.focus:raise()
      end
    end,
    {description = "go back", group = "client"}
  ),
  -- Programms
  awful.key(
    {modkey},
    config.lock,
    function()
      print("Locking screen")
      awful.spawn(apps.default.lock)
    end,
    {description = "lock the screen", group = "hotkeys"}
  ),
  awful.key(
    {modkey},
    config.notificationPanel,
    function()
      print("Toggeling right panel")
      if _G.screen.primary.right_panel ~= nil then
        _G.screen.primary.right_panel:toggle()
      end
    end,
    {description = "Open Notification Center", group = "Launcher"}
  ),
  -- Standard program
  awful.key(
    {modkey, "Control"},
    config.restart,
    _G.awesome.restart,
    {description = "reload awesome", group = "awesome"}
  ),
  awful.key({modkey, "Control"}, config.quit, _G.awesome.quit, {description = "quit awesome", group = "awesome"}),
  awful.key(
    {altkey, "Shift"},
    "l",
    function()
      awful.tag.incmwfact(0.05)
    end,
    {description = "increase master width factor", group = "layout"}
  ),
  awful.key(
    {altkey, "Shift"},
    "h",
    function()
      awful.tag.incmwfact(-0.05)
    end,
    {description = "decrease master width factor", group = "layout"}
  ),
  awful.key(
    {modkey, "Shift"},
    "h",
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    {description = "increase the number of master clients", group = "layout"}
  ),
  awful.key(
    {modkey, "Shift"},
    "l",
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    {description = "decrease the number of master clients", group = "layout"}
  ),
  awful.key(
    {modkey, "Control"},
    "h",
    function()
      awful.tag.incncol(1, nil, true)
    end,
    {description = "increase the number of columns", group = "layout"}
  ),
  awful.key(
    {modkey, "Control"},
    "l",
    function()
      awful.tag.incncol(-1, nil, true)
    end,
    {description = "decrease the number of columns", group = "layout"}
  ),
  awful.key(
    {modkey},
    config.nextLayout,
    function()
      awful.layout.inc(1)
    end,
    {description = "select next", group = "layout"}
  ),
  awful.key(
    {modkey, "Shift"},
    config.prevLayout,
    function()
      awful.layout.inc(-1)
    end,
    {description = "select previous", group = "layout"}
  ),
  awful.key(
    {modkey, "Control"},
    config.restoreMinimized,
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        _G.client.focus = c
        c:raise()
      end
    end,
    {description = "restore minimized", group = "client"}
  ),
  -- Dropdown application
  awful.key(
    {},
    config.drop,
    function()
      _G.toggle_quake()
    end,
    {description = "dropdown terminal", group = "Launcher"}
  ),
  -- Brightness
  awful.key(
    {},
    "XF86MonBrightnessUp",
    function()
      print("Increasing brightness")
      if (_G.oled) then
        awful.spawn("brightness -a 5 -F")
      else
        awful.spawn("brightness -s 100 -F") -- reset pixel values when using backlight
        awful.spawn("brightness -a 5")
      end
      awesome.emit_signal("widget::brightness")
      if toggleBriOSD ~= nil then
        _G.toggleBriOSD(true)
      end
      if UpdateBrOSD ~= nil then
        _G.UpdateBrOSD()
      end
    end,
    {description = "+10%", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86MonBrightnessDown",
    function()
      print("Decreasing brightness")
      if (_G.oled) then
        awful.spawn("brightness -d 5 -F")
      else
        awful.spawn("brightness -s 100 -F") -- reset pixel values when using backlight
        awful.spawn("brightness -d 5")
      end
      awesome.emit_signal("widget::brightness")
      if toggleBriOSD ~= nil then
        _G.toggleBriOSD(true)
      end
      if UpdateBrOSD ~= nil then
        _G.UpdateBrOSD()
      end
    end,
    {description = "-10%", group = "hardware"}
  ),
  -- ALSA volume control
  awful.key(
    {},
    "XF86AudioRaiseVolume",
    function()
      print("Raising volume")
      awful.spawn("amixer -D pulse sset Master 5%+")
      awesome.emit_signal("widget::volume")
      if toggleVolOSD ~= nil then
        _G.toggleVolOSD(true)
      end
      if UpdateVolOSD ~= nil then
        _G.UpdateVolOSD()
      end
    end,
    {description = "volume up", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86AudioLowerVolume",
    function()
      print("Lowering volume")
      awful.spawn("amixer -D pulse sset Master 5%-")
      awesome.emit_signal("widget::volume")
      if toggleVolOSD ~= nil then
        _G.toggleVolOSD(true)
      end
      if UpdateVolOSD ~= nil then
        _G.UpdateVolOSD()
      end
    end,
    {description = "volume down", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86AudioMute",
    function()
      print("Toggeling volume")
      awful.spawn("amixer -D pulse set Master 1+ toggle")
      awesome.emit_signal("widget::volume")
      if toggleVolOSD ~= nil then
        _G.toggleVolOSD(true)
      end
      if UpdateVolOSD ~= nil then
        _G.UpdateVolOSD()
      end
    end,
    {description = "toggle mute", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86AudioNext",
    function()
      print("Pressed Audio Next")
    end,
    {description = "toggle mute", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86PowerDown",
    function()
      print("Showing exit screen")
      _G.exit_screen_show()
    end,
    {description = "toggle exit screen", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86PowerOff",
    function()
      print("Showing exit screen")
      _G.exit_screen_show()
    end,
    {description = "toggle exit screen", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86Display",
    function()
      print("Spawning arandr")
      awful.spawn("arandr")
    end,
    {description = "arandr", group = "hotkeys"}
  ),
  -- Music player keys
  awful.key(
    {},
    "XF86AudioPlay",
    function()
      print("toggeling music")
      awful.spawn("playerctl play-pause")
    end,
    {description = "toggle music", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86AudioPause",
    function()
      print("toggeling music")
      awful.spawn("playerctl play-pause")
    end,
    {description = "toggle music", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86AudioPrev",
    function()
      print("Previous song")
      awful.spawn("playerctl previous")
    end,
    {description = "go to the previous song", group = "hardware"}
  ),
  awful.key(
    {},
    "XF86AudioNext",
    function()
      print("Next song")
      awful.spawn("playerctl next")
    end,
    {description = "go to the next song", group = "hardware"}
  ),
  -- keys for keyboards without xf86 keys
  awful.key(
    {modkey},
    config.toggleMusic,
    function()
      print("toggeling music")
      awful.spawn("playerctl play-pause")
    end,
    {description = "toggle music", group = "hardware"}
  ),
  awful.key(
    {modkey},
    config.prevMusic,
    function()
      print("Previous song")
      awful.spawn("playerctl previous")
    end,
    {description = "go to the previous song", group = "hardware"}
  ),
  awful.key(
    {modkey},
    config.nextMusic,
    function()
      print("Next song")
      awful.spawn("playerctl next")
    end,
    {description = "go to the next song", group = "hardware"}
  ),
  awful.key(
    {},
    config.printscreen,
    function()
      print("Taking a full screenshot")
      if not send_notification_if_maim_missing() then
        awful.spawn(apps.bins.full_screenshot)
      end
    end,
    {description = "fullscreen screenshot", group = "Utility"}
  ),
  awful.key(
    {modkey},
    config.snapArea,
    function()
      print("Taking an area screenshot")
      if not send_notification_if_maim_missing() then
        awful.spawn(apps.bins.area_screenshot)
      end
    end,
    {description = "area/selected screenshot", group = "Utility"}
  ),
  awful.key(
    {modkey, "Shift"},
    config.windowSnapArea,
    function()
      print("Taking a screenshot of a window")
      if not send_notification_if_maim_missing() then
        if general["window_screen_mode"] == "none" then
          awful.spawn(apps.bins.window_blank_screenshot)
        else
          awful.spawn(apps.bins.window_screenshot)
        end
      end
    end,
    {description = "window screenshot", group = "Utility"}
  ),
  awful.key(
    {modkey},
    config.emoji,
    function()
      print("Opening rofi emoji menu")
      awful.spawn(apps.default.rofiemojimenu)
    end,
    {description = "Show emoji selector", group = "Utility"}
  ),
  awful.key(
    {modkey},
    config.clipboard,
    function()
      print("Opening rofi clipboard")
      awful.spawn(apps.default.roficlipboard)
    end,
    {description = "Show clipboard history", group = "Utility"}
  ),
  awful.key(
    {modkey},
    config.settings,
    function()
      print("Opening settings application")
      root.elements.settings.enable_view_by_index(-1, mouse.screen)
    end,
    {description = "Open settings application", group = "Launcher"}
  )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
  local descr_view, descr_toggle, descr_move, descr_toggle_focus
  if i == 1 or i == 9 then
    descr_view = {description = "view tag #", group = "tag"}
    descr_toggle = {description = "toggle tag #", group = "tag"}
    descr_move = {description = "move focused client to tag #", group = "tag"}
    descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
  end
  globalKeys =
    awful.util.table.join(
    globalKeys,
    -- View tag only.
    awful.key(
      {modkey},
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        print("Going to tag: " .. i)
        if tag then
          tag:view_only()
        end
      end,
      descr_view
    ),
    -- Toggle tag display.
    awful.key(
      {modkey, "Control"},
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        print("Toggeling tag: " .. i)
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      descr_toggle
    ),
    -- Move client to tag.
    awful.key(
      {modkey, "Shift"},
      "#" .. i + 9,
      function()
        print("Moving client to tag: " .. i)

        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:move_to_tag(tag)
          end
        end
      end,
      descr_move
    ),
    -- Toggle tag on focused client.
    awful.key(
      {modkey, "Control", "Shift"},
      "#" .. i + 9,
      function()
        print("Toggeling tag " .. i .. " focused client")

        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:toggle_tag(tag)
          end
        end
      end,
      descr_toggle_focus
    )
  )
end

return globalKeys
