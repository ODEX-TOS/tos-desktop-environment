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
local apps = require("configuration.apps")
local xrandr = require("lib-tde.xrandr")
local volume = require("lib-tde.volume")

local signals = require('lib-tde.signals')

local focused_screen = require("lib-tde.function.common").focused_screen

-- returns true if we cannot create a screenshot
local function send_notification_if_maim_missing(callback)
  has_package_installed("maim", function (installed)
    if not installed then
      require("naughty").notification(
        {
          title = i18n.translate("Cannot create screenshot"),
          message = i18n.translate("maim is not installed, install it using tde-contrib package"),
          app_name = i18n.translate("tde package notifier")
        }
      )
      return callback(true)
    end
    return callback(false)
  end)
end

-- Key bindings
local globalKeys =
  awful.util.table.join(
  -- Hotkeys
  awful.key(
    config.to_modifiers("helpMenu"),
    config.to_key_string("helpMenu"),
    hotkeys_popup.show_help,
    {description = i18n.translate("show help"), group = i18n.translate("TDE")}
  ),
  awful.key(
    config.to_modifiers("prompt"),
    config.to_key_string("prompt"),
    function()
      if _G.root.prompt ~= nil then
        _G.root.prompt()
      end
    end,
    {description = i18n.translate("Show the prompt"), group = i18n.translate("TDE")}
  ),
  -- Custom Keys
  awful.key(
    config.to_modifiers("randr"),
    config.to_key_string("randr"),
    function()
      xrandr.xrandr()
    end,
    {description = i18n.translate("Launch screen layout mode"), group = i18n.translate("Launcher")}
  ),
  awful.key(
    config.to_modifiers("terminal"),
    config.to_key_string("terminal"),
    function()
      print("Spawning terminal")
      awful.spawn(apps.default.terminal)
    end,
    {description = i18n.translate("Open Terminal"), group = i18n.translate("Launcher")}
  ),
  awful.key(
    config.to_modifiers("window"),
    config.to_key_string("window"),
    function()
      print("Spawning rofi window switcher")
      awful.spawn(apps.default.rofiwindowswitch)
    end,
    {description = i18n.translate("Open a Window Switcher"), group = i18n.translate("launcher")}
  ),
  awful.key(
    config.to_modifiers("launcher"),
    config.to_key_string("launcher"),
    function()
      print("Spawning rofi app menu")
      awful.spawn(apps.default.rofiappmenu)
    end,
    {description = i18n.translate("Open Rofi"), group = i18n.translate("Launcher")}
  ),
  awful.key(
    config.to_modifiers("browser"),
    config.to_key_string("browser"),
    function()
      local browser = os.getenv("BROWSER") or "firefox-developer-edition"
      print("Opening browser: " .. browser)
      awful.spawn(browser)
    end,
    {description = i18n.translate("Open Browser"), group = i18n.translate("Launcher")}
  ),
  awful.key(
    config.to_modifiers("filemanager"),
    config.to_key_string("filemanager"),
    function()
      print("Opening filemanager: thunar")
      awful.spawn("thunar")
    end,
    {description = i18n.translate("Open file manager"), group = i18n.translate("Launcher")}
  ),
  awful.key(
    config.to_modifiers("monitor"),
    config.to_key_string("monitor"),
    function()
      print("Opening system monitor")
      awful.spawn("gnome-system-monitor")
    end,
    {description = i18n.translate("Open system monitor"), group = i18n.translate("Launcher")}
  ),
  awful.key(
    {"Mod1"},
    "Tab",
    function()
      print("Tabbing between applications")
      _G.switcher.switch(1, "Mod1", "Alt_L", "Shift", "Tab")
    end,
    {description = i18n.translate("Tab between applications"), group = i18n.translate("Laucher")}
  ),
  awful.key(
    {"Mod1", "Shift"},
    "Tab",
    function()
      print("Reverse tabbing between applications")
      _G.switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
    end,
    {description = i18n.translate("Tab between applications in reverse order"), group = i18n.translate("Laucher")}
  ),
  -- Toggle System Tray
  awful.key(
    {modkey},
    "=",
    function()
      print("Toggeling systray visibility")
      tde.emit_signal("widget::systray:toggle")
    end,
    {description = i18n.translate("Toggle systray visibility"), group = i18n.translate("custom")}
  ),
  -- Tag browsing
  awful.key(
    config.to_modifiers("previousWorkspace"),
    config.to_key_string("previousWorkspace"),
    awful.tag.viewprev,
    {description = i18n.translate("view previous"), group = i18n.translate(i18n.translate("tag"))}
  ),
  awful.key(
    config.to_modifiers("nextWorkspace"),
    config.to_key_string("nextWorkspace"),
    awful.tag.viewnext,
    {description = i18n.translate("view next"), group = i18n.translate(i18n.translate("tag"))}
  ),
  awful.key(
    config.to_modifiers("swapWorkspace"),
    config.to_key_string("swapWorkspace"),
    awful.tag.history.restore,
    {description = i18n.translate("go back"), group = i18n.translate(i18n.translate("tag"))}
  ),
  awful.key(
    config.to_modifiers("configPanel"),
    config.to_key_string("configPanel"),
    function()
      print("Showing action center")
      if focused_screen().control_center then
        focused_screen().control_center:toggle()
      end
    end,
    {description = i18n.translate("Open Control panel"), group = i18n.translate("Launcher")}
  ),
  awful.key({modkey}, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
  awful.key(
    config.to_modifiers("toggleFocus"),
    config.to_key_string("toggleFocus"),
    function()
      awful.client.focus.history.previous()
      if _G.client.focus then
        _G.client.focus:raise()
      end
    end,
    {description = i18n.translate("go back"), group = i18n.translate("client")}
  ),
  -- Programs
  awful.key(
    config.to_modifiers("lock"),
    config.to_key_string("lock"),
    function()
      print("Locking screen")
      awful.spawn(apps.default.lock)
    end,
    {description = i18n.translate("lock the screen"), group = i18n.translate("hotkeys")}
  ),
  awful.key(
    config.to_modifiers("notificationPanel"),
    config.to_key_string("notificationPanel"),
    function()
      print("Toggeling right panel")
      if focused_screen().info_center then
        focused_screen().info_center:toggle()
      end
    end,
    {description = i18n.translate("Open Notification Center"), group = i18n.translate("Launcher")}
  ),
  -- Standard program
  awful.key(
    config.to_modifiers("restart"),
    config.to_key_string("restart"),
    _G.tde.restart,
    {description = i18n.translate("reload TDE"), group = i18n.translate("TDE")}
  ),
  awful.key(
    config.to_modifiers("quit"),
    config.to_key_string("quit"),
    _G.tde.quit,
    {description = i18n.translate("quit TDE"), group = i18n.translate("TDE")}
  ),
  awful.key(
    config.to_modifiers("nextLayout"),
    config.to_key_string("nextLayout"),
    function()
      awful.layout.inc(1)
    end,
    {description = i18n.translate("select next"), group = i18n.translate("layout")}
  ),
  awful.key(
    config.to_modifiers("prevLayout"),
    config.to_key_string("prevLayout"),
    function()
      awful.layout.inc(-1)
    end,
    {description = i18n.translate("select previous"), group = i18n.translate("layout")}
  ),
  awful.key(
    config.to_modifiers("restoreMinimized"),
    config.to_key_string("restoreMinimized"),
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        _G.client.focus = c
        c:raise()
      end
    end,
    {description = i18n.translate("restore minimized"), group = i18n.translate("client")}
  ),
  -- Dropdown application
  awful.key(
    config.to_modifiers("dropdownTerminal"),
    config.to_key_string("dropdownTerminal"),
    function()
      _G.toggle_quake()
    end,
    {description = i18n.translate("dropdown terminal"), group = i18n.translate("Launcher")}
  ),
  -- Brightness
  awful.key(
    {},
    "XF86MonBrightnessUp",
    function()
      print("Increasing brightness")
      if (_G.oled) then
        awful.spawn("brightness -a 5 -F", false)
      else
        awful.spawn("brightness -s 100 -F", false) -- reset pixel values when using backlight
        awful.spawn("brightness -a 5", false)
      end
      tde.emit_signal("widget::brightness")
      if _G.toggleBriOSD ~= nil then
        _G.toggleBriOSD(true)
      end
      if _G.UpdateBrOSD ~= nil then
        _G.UpdateBrOSD()
      end
    end,
    {description = i18n.translate("+10%"), group = i18n.translate(i18n.translate("hardware"))}
  ),
  awful.key(
    {},
    "XF86MonBrightnessDown",
    function()
      print("Decreasing brightness")
      if (_G.oled) then
        awful.spawn("brightness -d 5 -F", false)
      else
        awful.spawn("brightness -s 100 -F", false) -- reset pixel values when using backlight
        awful.spawn("brightness -d 5", false)
      end
      tde.emit_signal("widget::brightness")
      if _G.toggleBriOSD ~= nil then
        _G.toggleBriOSD(true)
      end
      if _G.UpdateBrOSD ~= nil then
        _G.UpdateBrOSD()
      end
    end,
    {description = i18n.translate("-10%"), group = i18n.translate(i18n.translate("hardware"))}
  ),
  -- ALSA volume control
  awful.key(
    {},
    "XF86AudioRaiseVolume",
    function()
      print("Raising volume")
      volume.inc_volume()
    end,
    {description = i18n.translate("volume up"), group = i18n.translate(i18n.translate("hardware"))}
  ),
  awful.key(
    {},
    "XF86AudioLowerVolume",
    function()
      print("Lowering volume")
      volume.dec_volume()
    end,
    {description = i18n.translate("volume down"), group = i18n.translate(i18n.translate("hardware"))}
  ),
  awful.key(
    {},
    "XF86AudioMute",
    function()
      print("Toggeling volume")
      volume.toggle_master()
    end,
    {description = i18n.translate("toggle mute"), group = i18n.translate(i18n.translate("hardware"))}
  ),
  awful.key(
    {},
    "XF86AudioNext",
    function()
      print("Pressed Audio Next")
    end,
    {description = "toggle mute", group = i18n.translate("hardware")}
  ),
  awful.key(
    {},
    "XF86PowerDown",
    function()
      print("Showing exit screen")
      _G.exit_screen_show()
    end,
    {description = i18n.translate("toggle exit screen"), group = i18n.translate(i18n.translate("hardware"))}
  ),
  awful.key(
    {},
    "XF86PowerOff",
    function()
      print("Showing exit screen")
      _G.exit_screen_show()
    end,
    {description = i18n.translate("toggle exit screen"), group = i18n.translate(i18n.translate("hardware"))}
  ),
  awful.key(
    {},
    "XF86Display",
    function()
      print("Spawning arandr")
      awful.spawn("arandr")
    end,
    {description = i18n.translate("arandr"), group = "hotkeys"}
  ),
  -- Music player keys
  awful.key(
    {},
    "XF86AudioPlay",
    function()
      print("toggeling music")
      awful.spawn("playerctl play-pause", false)
    end,
    {description = i18n.translate("toggle music"), group = i18n.translate("hardware")}
  ),
  awful.key(
    {},
    "XF86AudioPause",
    function()
      print("toggeling music")
      awful.spawn("playerctl play-pause", false)
    end,
    {description = i18n.translate("toggle music"), group = i18n.translate("hardware")}
  ),
  awful.key(
    {},
    "XF86AudioPrev",
    function()
      print("Previous song")
      awful.spawn("playerctl previous", false)
    end,
    {description = i18n.translate("go to the previous song"), group = i18n.translate("hardware")}
  ),
  awful.key(
    {},
    "XF86AudioNext",
    function()
      print("Next song")
      awful.spawn("playerctl next", false)
    end,
    {description = i18n.translate("go to the next song"), group = i18n.translate("hardware")}
  ),
  -- keys for keyboards without xf86 keys
  awful.key(
    config.to_modifiers("toggleMusic"),
    config.to_key_string("toggleMusic"),
    function()
      print("toggeling music")
      awful.spawn("playerctl play-pause", false)
    end,
    {description = i18n.translate("toggle music"), group = i18n.translate("hardware")}
  ),
  awful.key(
    config.to_modifiers("prevMusic"),
    config.to_key_string("prevMusic"),
    function()
      print("Previous song")
      awful.spawn("playerctl previous", false)
    end,
    {description = i18n.translate("go to the previous song"), group = i18n.translate("hardware")}
  ),
  awful.key(
    config.to_modifiers("nextMusic"),
    config.to_key_string("nextMusic"),
    function()
      print("Next song")
      awful.spawn("playerctl next", false)
    end,
    {description = i18n.translate("go to the next song"), group = i18n.translate("hardware")}
  ),
  awful.key(
    config.to_modifiers("printscreen"),
    config.to_key_string("printscreen"),
    function()
      print("Taking a full screenshot")
      send_notification_if_maim_missing(function (missing)
        if not missing then
          if general["window_screen_mode"] == "none" then
            awful.spawn(apps.bins().full_blank_screenshot, false)
          else
            awful.spawn(apps.bins().full_screenshot, false)
          end
        end
      end)
    end,
    {description = i18n.translate("fullscreen screenshot"), group = i18n.translate("Utility")}
  ),
  awful.key(
    config.to_modifiers("snapArea"),
    config.to_key_string("snapArea"),
    function()
      print("Taking an area screenshot")
      send_notification_if_maim_missing(function (missing)
        if not missing then
          if general["window_screen_mode"] == "none" then
            awful.spawn(apps.bins().area_blank_screenshot, false)
          else
            awful.spawn(apps.bins().area_screenshot, false)
          end
        end
      end)
    end,
    {description = i18n.translate("area/selected screenshot"), group = i18n.translate("Utility")}
  ),
  awful.key(
    config.to_modifiers("windowSnapArea"),
    config.to_key_string("windowSnapArea"),
    function()
      print("Taking a screenshot of a window")
      send_notification_if_maim_missing(function (missing)
        if not missing then
          if general["window_screen_mode"] == "none" then
            awful.spawn(apps.bins().window_blank_screenshot, false)
          else
            awful.spawn(apps.bins().window_screenshot, false)
          end
        end
      end)
    end,
    {description = i18n.translate("window screenshot"), group = i18n.translate("Utility")}
  ),
  awful.key(
    config.to_modifiers("emoji"),
    config.to_key_string("emoji"),
    function()
      print("Opening rofi emoji menu")
      awful.spawn(apps.default.rofiemojimenu)
    end,
    {description = i18n.translate("Show emoji selector"), group = i18n.translate("Utility")}
  ),
  awful.key(
    config.to_modifiers("clipboard"),
    config.to_key_string("clipboard"),
    function()
      print("Opening rofi clipboard")
      awful.spawn(apps.default.roficlipboard)
    end,
    {description = i18n.translate("Show clipboard history"), group = i18n.translate("Utility")}
  ),
  awful.key(
    config.to_modifiers("settings"),
    config.to_key_string("settings"),
    function()
      print("Opening settings application")
      root.elements.settings.enable_view_by_index(-1, mouse.screen)
    end,
    {description = i18n.translate("Open settings application"), group = "Launcher"}
  ),
  awful.key(
    config.to_modifiers("keyboard_layout"),
    config.to_key_string("keyboard_layout"),
    function()
      print("Going to the next layout")
      signals.emit_keyboard_layout()
    end,
    {description = i18n.translate("Go to the next keyboard layout"), group = i18n.translate("Utility")}
  )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
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
        if _G.clear_desktop_selection then
          _G.clear_desktop_selection()
        end
        if tag then
          tag:view_only()
        end
      end
    ),
    -- Toggle tag display.
    awful.key(
      {modkey, "Control"},
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        print("Toggeling tag: " .. i)
        if _G.clear_desktop_selection then
          _G.clear_desktop_selection()
        end
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end
    ),
    -- Move client to tag.
    awful.key(
      {modkey, "Shift"},
      "#" .. i + 9,
      function()
        print("Moving client to tag: " .. i)
        if _G.clear_desktop_selection then
          _G.clear_desktop_selection()
        end

        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:move_to_tag(tag)
          end
        end
      end
    ),
    -- Toggle tag on focused client.
    awful.key(
      {modkey, "Control", "Shift"},
      "#" .. i + 9,
      function()
        print("Toggeling tag " .. i .. " focused client")
        if _G.clear_desktop_selection then
          _G.clear_desktop_selection()
        end

        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:toggle_tag(tag)
          end
        end
      end
    )
  )
end

return globalKeys
