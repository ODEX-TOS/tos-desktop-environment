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
local config = keys

return {
    modKey = config["mod"] or "Mod4",
    randr = config["screen"] or "r",
    altKey = config["alt"] or "Mod1",
    terminal = config["terminal"] or "Return",
    kill = config["kill"] or "q",
    floating = config["floating"] or "c",
    fullscreen = config["fullscreen"] or "f",
    window = config["window_switch"] or "s",
    launcher = config["launcher"] or "d",
    browser = config["browser"] or "w",
    filemanager = config["filemanager"] or "e",
    monitor = config["systemmonitor"] or "Escape",
    previousWorkspace = config["previous_workspace"] or "w",
    nextWorkspace = config["next_workspace"] or "a",
    swapWorkspace = config["swap_workspace"] or "Escape",
    configPanel = config["action_center"] or "e",
    toggleFocus = config["toggle_focus"] or "Tab",
    lock = config["lock"] or "l",
    notificationPanel = config["notification_panel"] or "x",
    restart = config["restart_wm"] or "r",
    quit = config["quit_wm"] or "q",
    nextLayout = config["next_layout"] or "space",
    prevLayout = config["previous_layout"] or "space",
    restoreMinimized = config["restore_minimized"] or "n",
    drop = config["dropdown_terminal"] or "F12",
    toggleMusic = config["toggle_sound"] or "t",
    prevMusic = config["previous_song"] or "k",
    nextMusic = config["next_song"] or "n",
    printscreen = config["printscreen"] or "Print",
    snapArea = config["snapshot_area"] or "Print",
    windowSnapArea = config["window_screenshot"] or "Print",
    emoji = config["emoji"] or "m",
    clipboard = config["clipboard"] or "p"
}
