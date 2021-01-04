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
-- create a file with some data
local function create_file(location, value)
    file = io.open(location, "w")
    file:write(value)
    file:close()
end

-- WARNING: Be carefull with this function
-- It removes files for the filesystem
local function rm_file(location)
    os.remove(location)
end

function test_dark_light()
    assert(type(require("tde.theme.icons.dark-light")) == "function", "Make sure the theme dark-light toggler works")
end

function test_dark_light_light()
    local darkLight = require("tde.theme.icons.dark-light")

    local light = "test.svg"
    local dark = "test.dark.svg"
    create_file(light, "")
    create_file(dark, "")

    -- a dark theme uses light background icons
    local result = darkLight(light, "dark")
    rm_file(light)
    rm_file(dark)
    assert(result == light, "Make sure that " .. result .. " equals: " .. light)

    rm_file(light)
    rm_file(dark)
end

function test_dark_light_default_is_light()
    local darkLight = require("tde.theme.icons.dark-light")

    local light = "test.svg"
    local dark = "test.dark.svg"
    create_file(light, "")
    create_file(dark, "")

    -- a dark theme uses light background icons
    local result = darkLight(light)
    rm_file(light)
    rm_file(dark)

    assert(result == light, "Make sure that " .. result .. " equals: " .. light)
end

function test_dark_light_dark()
    local darkLight = require("tde.theme.icons.dark-light")

    local light = "test.svg"
    local dark = "test.dark.svg"
    create_file(light, "")
    create_file(dark, "")
    -- a light theme uses dark background icons
    local result = darkLight(light, "light")
    rm_file(light)
    rm_file(dark)
    assert(result == dark, "Make sure that " .. result .. " equals: " .. dark)

    rm_file(light)
    rm_file(dark)
end
