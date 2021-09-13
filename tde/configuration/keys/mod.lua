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

-- Please make use of xkb keycodes as much as possible instead of chars
-- The reasoning behind it is that keyboard shortcuts still work across keyboard layouts
-- For example, when you make use of a cyrellic keyboard you can still use 'english' keys

-- Use the `xev` command to find the corresponding keysym

-- Here is an example output of xev:

--[[
    KeyPress event, serial 38, synthetic NO, window 0x4800001,
    root 0x1a1, subw 0x0, time 18451169, (306,559), root:(1270,595),
    state 0x0, keycode 46 (keysym 0x6c, l), same_screen YES,
    XLookupString gives 1 bytes: (6c) "l"
    XmbLookupString gives 1 bytes: (6c) "l"
    XFilterEvent returns: False
]]

-- For the 'l' key the corresponding keycode is 46

local config = keys

return {
    modKey = config["mod"] or "Mod4",
    randr = config["screen"] or "#27", -- r
    altKey = config["alt"] or "Mod1",
    terminal = config["terminal"] or "Return",
    kill = config["kill"] or "#24", -- q
    floating = config["floating"] or "#54", -- c
    fullscreen = config["fullscreen"] or "#41", -- f
    ontop = config["ontop"] or "#32", -- o
    window = config["window_switch"] or "#56", -- b
    launcher = config["launcher"] or "#40", -- d
    browser = config["browser"] or "#56", -- b
    filemanager = config["filemanager"] or "#26", -- e
    monitor = config["systemmonitor"] or "Escape",
    previousWorkspace = config["previous_workspace"] or "#25", -- w
    nextWorkspace = config["next_workspace"] or "#38", -- a
    swapWorkspace = config["swap_workspace"] or "Escape",
    configPanel = config["action_center"] or "#26", -- e
    toggleFocus = config["toggle_focus"] or "Tab",
    lock = config["lock"] or "#46", -- l
    notificationPanel = config["notification_panel"] or "#53", -- x
    restart = config["restart_wm"] or "#27", -- r
    quit = config["quit_wm"] or "#24", -- q
    nextLayout = config["next_layout"] or "space",
    prevLayout = config["previous_layout"] or "space",
    restoreMinimized = config["restore_minimized"] or "#57", -- n
    drop = config["dropdown_terminal"] or "F12",
    toggleMusic = config["toggle_sound"] or "#28", -- t
    prevMusic = config["previous_song"] or "#45", -- k
    nextMusic = config["next_song"] or "#57", -- n
    printscreen = config["printscreen"] or "Print",
    snapArea = config["snapshot_area"] or "Print",
    windowSnapArea = config["window_screenshot"] or "Print",
    emoji = config["emoji"] or "#58", -- m
    clipboard = config["clipboard"] or "#33", -- p
    settings = config["settings"] or "#39", -- s
    keyboard_layout = config["keyboard_layout"] or "#31"
}
