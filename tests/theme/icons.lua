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
    assert(file_exists(icons.chrome))
end

function test_theme_icon_code()
    assert(file_exists(icons.code))
end

function test_theme_icon_social()
    assert(file_exists(icons.social))
end

function test_theme_icon_folder()
    assert(file_exists(icons.folder))
end

function test_theme_icon_music()
    assert(file_exists(icons.music))
end

function test_theme_icon_game()
    assert(file_exists(icons.game))
end

function test_theme_icon_lab()
    assert(file_exists(icons.lab))
end

function test_theme_icon_terminal()
    assert(file_exists(icons.terminal))
end

function test_theme_icon_art()
    assert(file_exists(icons.art))
end

function test_theme_icon_menu()
    assert(file_exists(icons.menu))
end

function test_theme_icon_logo()
    assert(file_exists(icons.logo))
end

function test_theme_icon_settings()
    assert(file_exists(icons.settings))
end

function test_theme_icon_close()
    assert(file_exists(icons.close))
end

function test_theme_icon_logout()
    assert(file_exists(icons.logout))
end

function test_theme_icon_sleep()
    assert(file_exists(icons.sleep))
end

function test_theme_icon_power()
    assert(file_exists(icons.power))
end

function test_theme_icon_lock()
    assert(file_exists(icons.lock))
end

function test_theme_icon_restart()
    assert(file_exists(icons.restart))
end

function test_theme_icon_search()
    assert(file_exists(icons.search))
end

function test_theme_icon_monitor()
    assert(file_exists(icons.monitor))
end

function test_theme_icon_wifi()
    assert(file_exists(icons.wifi))
end

function test_theme_icon_volume()
    assert(file_exists(icons.volume))
end

function test_theme_icon_muted()
    assert(file_exists(icons.muted))
end

function test_theme_icon_brightness()
    assert(file_exists(icons.brightness))
end

function test_theme_icon_chart()
    assert(file_exists(icons.chart))
end

function test_theme_icon_memory()
    assert(file_exists(icons.memory))
end

function test_theme_icon_harddisk()
    assert(file_exists(icons.harddisk))
end

function test_theme_icon_thermometer()
    assert(file_exists(icons.thermometer))
end

function test_theme_icon_plus()
    assert(file_exists(icons.plus))
end

function test_theme_icon_network()
    assert(file_exists(icons.network))
end

function test_theme_icon_upload()
    assert(file_exists(icons.upload))
end

function test_theme_icon_download()
    assert(file_exists(icons.download))
end

function test_theme_icon_warning()
    assert(file_exists(icons.warning))
end
