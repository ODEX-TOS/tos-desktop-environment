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

-- Used to enable custom widgets as a plugin mechanism for TDE
package.path = os.getenv("HOME") .. "/.config/tde/?/init.lua;" .. package.path
package.path = os.getenv("HOME") .. "/.config/tde/?.lua;" .. package.path

-- Setup custom lua scripts (libraries)
-- If the user dir exists then use that
-- Otherwise use the system files
if exists(os.getenv("HOME") .. "/.config/awesome") then
    package.path =
        os.getenv("HOME") ..
        "/.config/awesome/?.lua;" .. os.getenv("HOME") .. "/.config/awesome/?/?.lua;" .. package.path
end

if exists(os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-lua") then
    package.path =
        package.path ..
        ";" ..
            os.getenv("HOME") ..
                "/.config/awesome/lib-tde/lib-lua/?/?.lua;" ..
                    os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-lua/?.lua"
end

if exists(os.getenv("HOME") .. "/.config/awesome/lib-tde/translations") then
    package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/awesome/lib-tde/translations/?.lua"
end

package.path = package.path .. ";" .. "/etc/xdg/tde/lib-tde/lib-lua/?/?.lua;" .. "/etc/xdg/tde/lib-tde/lib-lua/?.lua"
package.path = package.path .. ";" .. "/etc/xdg/tde/lib-tde/translations/?.lua"

-- same applies for the c libraries
if exists(os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-so") then
    package.cpath =
        package.cpath ..
        ";" ..
            os.getenv("HOME") ..
                "/.config/awesome/lib-tde/lib-so/?/?.so;" .. os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-so/?.so"
end
package.cpath = package.cpath .. ";" .. "/etc/xdg/tde/lib-tde/lib-so/?/?.so;" .. "/etc/xdg/tde/lib-tde/lib-so/?.so"
