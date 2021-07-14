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
    assert(mod.randr)
    assert(type(mod.randr) == "string")
end

function Test_configuration_mod_key_altKey()
    assert(mod.altKey)
    assert(type(mod.altKey) == "string")
end

function Test_configuration_mod_key_terminal()
    assert(mod.terminal)
    assert(type(mod.terminal) == "string")
end

function Test_configuration_mod_key_kill()
    assert(mod.kill)
    assert(type(mod.kill) == "string")
end

function Test_configuration_mod_key_floating()
    assert(mod.floating)
    assert(type(mod.floating) == "string")
end

function Test_configuration_mod_key_fullscreen()
    assert(mod.fullscreen)
    assert(type(mod.fullscreen) == "string")
end

function Test_configuration_mod_key_window()
    assert(mod.window)
    assert(type(mod.window) == "string")
end

function Test_configuration_mod_key_launcher()
    assert(mod.launcher)
    assert(type(mod.launcher) == "string")
end

function Test_configuration_mod_key_browser()
    assert(mod.browser)
    assert(type(mod.browser) == "string")
end

function Test_configuration_mod_key_filemanager()
    assert(mod.filemanager)
    assert(type(mod.filemanager) == "string")
end

function Test_configuration_mod_key_monitor()
    assert(mod.monitor)
    assert(type(mod.monitor) == "string")
end

function Test_configuration_mod_key_previousWorkspace()
    assert(mod.previousWorkspace)
    assert(type(mod.previousWorkspace) == "string")
end

function Test_configuration_mod_key_nextWorkspace()
    assert(mod.nextWorkspace)
    assert(type(mod.nextWorkspace) == "string")
end

function Test_configuration_mod_key_swapWorkspace()
    assert(mod.swapWorkspace)
    assert(type(mod.swapWorkspace) == "string")
end

function Test_configuration_mod_key_configPanel()
    assert(mod.configPanel)
    assert(type(mod.configPanel) == "string")
end

function Test_configuration_mod_key_toggleFocus()
    assert(mod.toggleFocus)
    assert(type(mod.toggleFocus) == "string")
end

function Test_configuration_mod_key_lock()
    assert(mod.lock)
    assert(type(mod.lock) == "string")
end

function Test_configuration_mod_key_notificationPanel()
    assert(mod.notificationPanel)
    assert(type(mod.notificationPanel) == "string")
end

function Test_configuration_mod_key_restart()
    assert(mod.restart)
    assert(type(mod.restart) == "string")
end

function Test_configuration_mod_key_quit()
    assert(mod.quit)
    assert(type(mod.quit) == "string")
end

function Test_configuration_mod_key_nextLayout()
    assert(mod.nextLayout)
    assert(type(mod.nextLayout) == "string")
end

function Test_configuration_mod_key_prevLayout()
    assert(mod.prevLayout)
    assert(type(mod.prevLayout) == "string")
end

function Test_configuration_mod_key_restoreMinimized()
    assert(mod.restoreMinimized)
    assert(type(mod.restoreMinimized) == "string")
end

function Test_configuration_mod_key_drop()
    assert(mod.drop)
    assert(type(mod.drop) == "string")
end

function Test_configuration_mod_key_toggleMusic()
    assert(mod.toggleMusic)
    assert(type(mod.toggleMusic) == "string")
end

function Test_configuration_mod_key_prevMusic()
    assert(mod.prevMusic)
    assert(type(mod.prevMusic) == "string")
end

function Test_configuration_mod_key_nextMusic()
    assert(mod.nextMusic)
    assert(type(mod.nextMusic) == "string")
end

function Test_configuration_mod_key_printscreen()
    assert(mod.printscreen)
    assert(type(mod.printscreen) == "string")
end

function Test_configuration_mod_key_snapArea()
    assert(mod.snapArea)
    assert(type(mod.snapArea) == "string")
end

function Test_configuration_mod_key_windowSnapArea()
    assert(mod.windowSnapArea)
    assert(type(mod.windowSnapArea) == "string")
end

function Test_configuration_mod_key_emoji()
    assert(mod.emoji)
    assert(type(mod.emoji) == "string")
end

function Test_configuration_mod_key_clipboard()
    assert(mod.clipboard)
    assert(type(mod.clipboard) == "string")
end

function Test_configuration_mod_key_settings()
    assert(mod.settings)
    assert(type(mod.settings) == "string")
end

function Test_configuration_mod_key_ontop()
    assert(mod.ontop)
    assert(type(mod.ontop) == "string")
end

function Test_configuration_mod_key_api_unit_tested()
    local amount = 35
    local result = tablelength(mod)
    assert(
        result == amount,
        "You didn't test all modifier keys endpoints, please add them then update the amount to: " .. result
    )
end
