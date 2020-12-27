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
local icons = require("tde.theme.icons")
local file_exists = function(loc)
    local exists = require("lib-tde.file").exists
    loc = loc:gsub("/etc/xdg/tde/", os.getenv("PWD") .. "/tde/")
    return exists(loc)
end

function test_theme_icon_chrome()
    assert(file_exists(icons.chrome), "Check that the chrome icon exists")
end

function test_theme_icon_code()
    assert(file_exists(icons.code), "Check that the code icon exists")
end

function test_theme_icon_social()
    assert(file_exists(icons.social), "Check that the social icon exists")
end

function test_theme_icon_folder()
    assert(file_exists(icons.folder), "Check that the folder icon exists")
end

function test_theme_icon_music()
    assert(file_exists(icons.music), "Check that the music icon exists")
end

function test_theme_icon_game()
    assert(file_exists(icons.game), "Check that the game icon exists")
end

function test_theme_icon_lab()
    assert(file_exists(icons.lab), "Check that the lab icon exists")
end

function test_theme_icon_terminal()
    assert(file_exists(icons.terminal), "Check that the terminal icon exists")
end

function test_theme_icon_art()
    assert(file_exists(icons.art), "Check that the art icon exists")
end

function test_theme_icon_menu()
    assert(file_exists(icons.menu), "Check that the menu icon exists")
end

function test_theme_icon_logo()
    assert(file_exists(icons.logo), "Check that the logo icon exists")
end

function test_theme_icon_settings()
    assert(file_exists(icons.settings), "Check that the settings icon exists")
end

function test_theme_icon_close()
    assert(file_exists(icons.close), "Check that the close icon exists")
end

function test_theme_icon_logout()
    assert(file_exists(icons.logout), "Check that the logout icon exists")
end

function test_theme_icon_sleep()
    assert(file_exists(icons.sleep), "Check that the sleep icon exists")
end

function test_theme_icon_power()
    assert(file_exists(icons.power), "Check that the power icon exists")
end

function test_theme_icon_lock()
    assert(file_exists(icons.lock), "Check that the lock icon exists")
end

function test_theme_icon_restart()
    assert(file_exists(icons.restart), "Check that the restart icon exists")
end

function test_theme_icon_search()
    assert(file_exists(icons.search), "Check that the search icon exists")
end

function test_theme_icon_monitor()
    assert(file_exists(icons.monitor), "Check that the monitor icon exists")
end

function test_theme_icon_wifi()
    assert(file_exists(icons.wifi), "Check that the wifi icon exists")
end

function test_theme_icon_volume()
    assert(file_exists(icons.volume), "Check that the volume icon exists")
end

function test_theme_icon_muted()
    assert(file_exists(icons.muted), "Check that the muted icon exists")
end

function test_theme_icon_brightness()
    assert(file_exists(icons.brightness), "Check that the brightness icon exists")
end

function test_theme_icon_chart()
    assert(file_exists(icons.chart), "Check that the chart icon exists")
end

function test_theme_icon_memory()
    assert(file_exists(icons.memory), "Check that the memory icon exists")
end

function test_theme_icon_harddisk()
    assert(file_exists(icons.harddisk), "Check that the harddisk icon exists")
end

function test_theme_icon_thermometer()
    assert(file_exists(icons.thermometer), "Check that the thermometer icon exists")
end

function test_theme_icon_plus()
    assert(file_exists(icons.plus), "Check that the plus icon exists")
end

function test_theme_icon_network()
    assert(file_exists(icons.network), "Check that the network icon exists")
end

function test_theme_icon_upload()
    assert(file_exists(icons.upload), "Check that the upload icon exists")
end

function test_theme_icon_download()
    assert(file_exists(icons.download), "Check that the download icon exists")
end

function test_theme_icon_warning()
    assert(file_exists(icons.warning), "Check that the warning icon exists")
end
