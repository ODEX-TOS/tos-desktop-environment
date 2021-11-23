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
local mod = require("tde.configuration.keys.mod")

function Test_configuration_mod_key_modKey()
    assert(mod.modKey)
    assert(type(mod.modKey) == "string")
end

function Test_configuration_mod_key_randr()
    assert(mod.keybindings.randr)
    assert(type(mod.keybindings.randr) == "string")
end

function Test_configuration_mod_key_altKey()
    assert(mod.altKey)
    assert(type(mod.altKey) == "string")
end

function Test_configuration_mod_key_terminal()
    assert(mod.keybindings.terminal)
    assert(type(mod.keybindings.terminal) == "string")
end

function Test_configuration_mod_key_kill()
    assert(mod.keybindings.kill)
    assert(type(mod.keybindings.kill) == "string")
end

function Test_configuration_mod_key_floating()
    assert(mod.keybindings.floating)
    assert(type(mod.keybindings.floating) == "string")
end

function Test_configuration_mod_key_fullscreen()
    assert(mod.keybindings.fullscreen)
    assert(type(mod.keybindings.fullscreen) == "string")
end

function Test_configuration_mod_key_window()
    assert(mod.keybindings.window)
    assert(type(mod.keybindings.window) == "string")
end

function Test_configuration_mod_key_launcher()
    assert(mod.keybindings.launcher)
    assert(type(mod.keybindings.launcher) == "string")
end

function Test_configuration_mod_key_browser()
    assert(mod.keybindings.browser)
    assert(type(mod.keybindings.browser) == "string")
end

function Test_configuration_mod_key_filemanager()
    assert(mod.keybindings.filemanager)
    assert(type(mod.keybindings.filemanager) == "string")
end

function Test_configuration_mod_key_monitor()
    assert(mod.keybindings.monitor)
    assert(type(mod.keybindings.monitor) == "string")
end

function Test_configuration_mod_key_previousWorkspace()
    assert(mod.keybindings.previousWorkspace)
    assert(type(mod.keybindings.previousWorkspace) == "string")
end

function Test_configuration_mod_key_nextWorkspace()
    assert(mod.keybindings.nextWorkspace)
    assert(type(mod.keybindings.nextWorkspace) == "string")
end

function Test_configuration_mod_key_swapWorkspace()
    assert(mod.keybindings.swapWorkspace)
    assert(type(mod.keybindings.swapWorkspace) == "string")
end

function Test_configuration_mod_key_configPanel()
    assert(mod.keybindings.configPanel)
    assert(type(mod.keybindings.configPanel) == "string")
end

function Test_configuration_mod_key_toggleFocus()
    assert(mod.keybindings.toggleFocus)
    assert(type(mod.keybindings.toggleFocus) == "string")
end

function Test_configuration_mod_key_lock()
    assert(mod.keybindings.lock)
    assert(type(mod.keybindings.lock) == "string")
end

function Test_configuration_mod_key_notificationPanel()
    assert(mod.keybindings.notificationPanel)
    assert(type(mod.keybindings.notificationPanel) == "string")
end

function Test_configuration_mod_key_restart()
    assert(mod.keybindings.restart)
    assert(type(mod.keybindings.restart) == "string")
end

function Test_configuration_mod_key_quit()
    assert(mod.keybindings.quit)
    assert(type(mod.keybindings.quit) == "string")
end

function Test_configuration_mod_key_nextLayout()
    assert(mod.keybindings.nextLayout)
    assert(type(mod.keybindings.nextLayout) == "string")
end

function Test_configuration_mod_key_prevLayout()
    assert(mod.keybindings.prevLayout)
    assert(type(mod.keybindings.prevLayout) == "string")
end

function Test_configuration_mod_key_restoreMinimized()
    assert(mod.keybindings.restoreMinimized)
    assert(type(mod.keybindings.restoreMinimized) == "string")
end

function Test_configuration_mod_key_drop()
    assert(mod.keybindings.drop)
    assert(type(mod.keybindings.drop) == "string")
end

function Test_configuration_mod_key_toggleMusic()
    assert(mod.keybindings.toggleMusic)
    assert(type(mod.keybindings.toggleMusic) == "string")
end

function Test_configuration_mod_key_prevMusic()
    assert(mod.keybindings.prevMusic)
    assert(type(mod.keybindings.prevMusic) == "string")
end

function Test_configuration_mod_key_nextMusic()
    assert(mod.keybindings.nextMusic)
    assert(type(mod.keybindings.nextMusic) == "string")
end

function Test_configuration_mod_key_printscreen()
    assert(mod.keybindings.printscreen)
    assert(type(mod.keybindings.printscreen) == "string")
end

function Test_configuration_mod_key_snapArea()
    assert(mod.keybindings.snapArea)
    assert(type(mod.keybindings.snapArea) == "string")
end

function Test_configuration_mod_key_windowSnapArea()
    assert(mod.keybindings.windowSnapArea)
    assert(type(mod.keybindings.windowSnapArea) == "string")
end

function Test_configuration_mod_key_emoji()
    assert(mod.keybindings.emoji)
    assert(type(mod.keybindings.emoji) == "string")
end

function Test_configuration_mod_key_clipboard()
    assert(mod.keybindings.clipboard)
    assert(type(mod.keybindings.clipboard) == "string")
end

function Test_configuration_mod_key_settings()
    assert(mod.keybindings.settings)
    assert(type(mod.keybindings.settings) == "string")
end

function Test_configuration_mod_key_ontop()
    assert(mod.keybindings.ontop)
    assert(type(mod.keybindings.ontop) == "string")
end

function Test_configuration_mod_key_ontop()
    assert(mod.keybindings.keyboard_layout)
    assert(type(mod.keybindings.keyboard_layout) == "string")
end

function Test_configuration_mod_key_keybindins_api_unit_tested()
    local amount = 34
    local result = tablelength(mod.keybindings)
    assert(
        result == amount,
        "You didn't test all modifier keys endpoints, please add them then update the amount to: " .. result
    )
end


function Test_configuration_mod_to_modifier()
    assert(mod.to_modifiers)
    assert(type(mod.to_modifiers) == "function")

    _G.save_state.keyboard_shortcuts["terminal"] = "Mod4+N"
    _G.save_state.keyboard_shortcuts["browser"] = "Mod4+Shift+N"


    assert(#mod.to_modifiers("terminal") == 1)
    assert(#mod.to_modifiers("browser") == 2)

    assert(mod.to_modifiers("browser")[1] == "Mod4")
    assert(mod.to_modifiers("terminal")[1] == "Mod4")
end

function Test_configuration_mod_to_key_string()
    assert(mod.to_key_string)
    assert(type(mod.to_key_string) == "function")

    _G.save_state.keyboard_shortcuts["terminal"] = "Mod4+N"

    assert(type(mod.to_key_string("terminal")) == "string")
    assert(type(mod.to_key_string("browser")) == "string")

    assert(mod.to_key_string("terminal") == "N")
end

function Test_configuration_mod_from_shortcut()
    assert(mod.get_str_from_shortcut)
    assert(type(mod.get_str_from_shortcut) == "function")

    _G.save_state.keyboard_shortcuts["terminal"] = "Mod4+N"

    assert(type(mod.get_str_from_shortcut("terminal")) == "string")
    assert(mod.get_str_from_shortcut("terminal") == "Mod4+N")
end



function Test_configuration_mod_key_api_unit_tested()
    local amount = 6
    local result = tablelength(mod)
    assert(
        result == amount,
        "You didn't test all modifier keys endpoints, please add them then update the amount to: " .. result
    )
end

