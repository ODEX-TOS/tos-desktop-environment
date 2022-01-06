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
-- This file overrides existing global variables in TDE with mock implementations

awesome = {
    conffile = os.getenv("PWD"),
    connect_signal = function(location)
        print("Awesome signal connector: " .. location)
    end,
    register_xproperty = function()
    end,
    release = "unit-test-mock",
    version = "v0.0"
}

tde = awesome

client = {
    connect_signal = function(location, _)
        print("Awesome signal connector: " .. location)
    end,
    get = function()
    end
}

screen = {
    connect_signal = function(location)
        print("Awesome signal connector: " .. location)
    end,
    set_index_miss_handler = function()
    end,
    set_newindex_miss_handler = function()
    end,
    primary = {
        dpi = 100
    }
}
mouse = {
    screen = ""
}

i18n = {
    translate = function(str)
        return str
    end
}

-- general configuration file
general = {
    audio_change_sound = "1"
}

keys = {}

awful = require("tests.tde.mock.awful")

require("tde.lib-tde.lib-lua.strace")

save_state= {
    theming = {

    },
    plugins = {

    },
    keyboard_shortcuts = {

    },
    hardware_only_volume_controls = {}
}

-- some generic counter for tables to make sure the user didn't forget to add a unit test
-- it is a simple way to force people to test
function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end
