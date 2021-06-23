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
local exists = require("lib-tde.file").dir_exists

local home = os.getenv("HOME")
local pwd = os.getenv("PWD")

-- the home env is /tmp/tde when running integration tests
local bIsIntegrationTest = home == "/tmp/tde"
local bIsreleaseMode = not bIsIntegrationTest and not exists(home .. "/.config/awesome")

-- in release mode we use /etc/xdg
if bIsreleaseMode then
    pwd = "/etc/xdg"
end

if bIsIntegrationTest then
    pwd = os.getenv("PWD") .. "/tos-tde"
end

package.loaded["naughty.dbus"] = {}

-- Used to enable custom widgets as a plugin mechanism for TDE
package.path = home .. "/.config/tde/?/init.lua;" .. package.path
package.path = home .. "/.config/tde/?.lua;" .. package.path

-- TODO: Correctly load path in when developing or when running integration tests
-- In that case don't use the /etc/xdg/ paths

-- Setup custom lua scripts (libraries)
-- If the user dir exists then use that
-- Otherwise use the system files
if exists(home .. "/.config/awesome") then
    package.path =
        home ..
        "/.config/awesome/?.lua;" .. home .. "/.config/awesome/?/?.lua;" .. package.path
end

if exists(home .. "/.config/awesome/lib-tde/lib-lua") then
    package.path =
        package.path ..
        ";" ..
            home ..
                "/.config/awesome/lib-tde/lib-lua/?/?.lua;" ..
                    home .. "/.config/awesome/lib-tde/lib-lua/?.lua"
end

if exists(home .. "/.config/awesome/lib-tde/translations") then
    package.path = package.path .. ";" .. home .. "/.config/awesome/lib-tde/translations/?.lua"
end

package.path = package.path .. ";" .. pwd .. "/tde/lib-tde/lib-lua/?/?.lua;" .. pwd .. "/tde/lib-tde/lib-lua/?.lua"
package.path = package.path .. ";" .. pwd .. "/tde/lib-tde/translations/?.lua"


-- same applies for the c libraries
if exists(home .. "/.config/awesome/lib-tde/lib-so") then
    package.cpath =
        package.cpath ..
        ";" ..
            home ..
                "/.config/awesome/lib-tde/lib-so/?/?.so;" .. home .. "/.config/awesome/lib-tde/lib-so/?.so"
end

package.cpath = package.cpath .. ";" .. pwd .. "/tde/lib-tde/lib-so/?/?.so;" .. pwd .. "/tde/lib-tde/lib-so/?.so"

