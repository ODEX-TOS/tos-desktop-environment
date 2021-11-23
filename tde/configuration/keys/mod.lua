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

local split = require("lib-tde.function.common").split

local keybindings = {
    -- Key Bindings use the to_modifiers and to_key_string functions to update the global buttons
    randr = "Mod4+#27", -- r
    terminal = "Mod4+Return",
    kill = "Mod4+#24", -- q
    floating = "Mod4+#54", -- c
    fullscreen = "Mod4+#41", -- f
    ontop = "Mod4+#32", -- o
    window = "Mod4+#56", -- b
    launcher = "Mod4+#40", -- d
    browser = "Mod4+Shift+#56", -- b
    filemanager = "Mod4+Shift+#26", -- e
    monitor = "Control+Shift+Escape",
    previousWorkspace = "Mod4+#25", -- w
    nextWorkspace = "Mod4+#38", -- a
    swapWorkspace = "Mod4+Escape",
    configPanel = "Mod4+#26", -- e
    toggleFocus = "Mod4+Tab",
    lock = "Mod4+#46", -- l
    notificationPanel = "Mod4+#53", -- x
    restart = "Mod4+Control+#27", -- r
    quit = "Mod4+Control+#24", -- q
    nextLayout = "Mod4+space",
    prevLayout = "Mod4+Shift+space",
    restoreMinimized = "Mod4+Control+#57", -- n
    drop = "F12",
    toggleMusic = "Mod4+#28", -- t
    prevMusic = "Mod4+#45", -- k
    nextMusic = "Mod4+#57", -- n
    printscreen = "Print",
    snapArea = "Mod4+Print",
    windowSnapArea = "Mod4+Shift+Print",
    emoji = "Mod4+#58", -- m
    clipboard = "Mod4+#33", -- p
    settings = "Mod4+#39", -- s
    keyboard_layout = "Mod4+#31",
}

local function get_str_from_shortcut(shortcut)
    if _G.save_state.keyboard_shortcuts[shortcut] ~= nil then
        return _G.save_state.keyboard_shortcuts[shortcut]
    end

    return keybindings[shortcut]
end


return {
    modKey = "Mod4",
    altKey = "Mod1",
    keybindings = keybindings,
    get_str_from_shortcut = get_str_from_shortcut,
    to_modifiers = function(shortcut)
            local str = get_str_from_shortcut(shortcut)
            local splitted_keys = split(str, "+")

            if #splitted_keys == 1 then
                return {}
            end

            local modifiers = {}

            for index, value in ipairs(splitted_keys) do
                if index < #splitted_keys then
                    table.insert(modifiers, value)
                end
            end

            return modifiers
    end,
    to_key_string = function(shortcut)
        local str = get_str_from_shortcut(shortcut)
        local splitted_keys = split(str, "+")
        return splitted_keys[#splitted_keys]
    end
}
