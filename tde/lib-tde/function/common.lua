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
---------------------------------------------------------------------------
-- This module adds extra functionality to widgets by exposing commonly used functions.
--
-- Lua directly implements the C - standard library and nothing more.
-- As a result a lot of common functions in higher level languages lack.
-- A solution is to use the this common module including some useful functions.
--
-- For example the split() function splits strings into a table of indexes:
--
--    lib-tde.function.common.split("a,b,c,d", ",") -- returns {1:"a",2:"b",3:"c",4:"d"}
--
-- As another example you can use the sleep() function to implement delay into you logic.
-- Be careful using sleep() as it blocks the main thread and can result in extreme poor performance.
-- As it also blocks user input from being processes.
--
--    lib-tde.function.common.sleep(0.5) -- blocks this thread for 0.5 seconds
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.common
---------------------------------------------------------------------------

local socket = require("socket")

--- split the input to a table based on the separator
-- @tparam string inputstr The string to split.
-- @tparam[opt] string sep a regular expression that splits the string (all matches are removed from the set).
-- @treturn table The table as a list of strings
-- @staticfct split
-- @usage -- This will return {1: "abc", 2: "def"}
-- lib-tde.function.common.split("abc;def", ";")
local function split(inputstr, sep)
    if not (type(sep) == "string") then
        sep = "%s"
    end
    if sep == "" then
        sep = "%s"
    end
    if not (type(inputstr) == "string") then
        return
    end
    local t = {}
    if inputstr == nil then
        return t
    end
    if inputstr == "" then
        return {""}
    end
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

--- Convert a number to a string with a given precision
-- @tparam number num The number to convert to a given precision
-- @tparam[opt] number precision The precision after the decimal point (by default 2)
-- @staticfct num_to_str
-- @usage -- returns 12.123
-- lib-tde.function.common.num_to_str(12.1234567)
local function num_to_str(num, precision)
    if precision == nil then
        precision = 2
    end
    if type(num) == "number" then
        return string.format("%." .. tostring(precision) .. "f", num)
    end
    return tostring(num)
end


--- sleep for x seconds where x can be subseconds long
-- @tparam number time The time in seconds
-- @staticfct sleep
-- @usage -- lib-tde.function.common.sleep(1)
-- lib-tde.function.common.sleep(5)
-- lib-tde.function.common.sleep(0.2)
local function sleep(time)
    if type(time) == "number" then
        if time < 0 then
            return
        end
        socket.select(nil, nil, time)
    end
end

--- Take any number bigger that 1 and return the number with its si prefix
-- @tparam number num the number to prefix
-- @tparam[opt] number start indicate if the number already has a prefix e.g. Kilo = 1, Mega =2, Giga = 3 etc
-- @staticfct num_to_si_prefix
-- @usage -- returns 42.0K and 123.0M respectively
-- lib-tde.function.common.num_to_si_prefix(42000)
-- lib-tde.function.common.num_to_si_prefix(123000000)
local function num_to_si_prefix(num, start)
    -- sanitize the input
    local number = num
    if type(num) == "string" then
        number = tonumber(num) or 0
    elseif not (type(num) == "number") then
        return num
    end

    local prefix = {"k", "M", "G", "T", "P", "E"}
    local index = start or 0
    while number >= 1000 do
        index = index + 1
        number = number / 1000
    end
    if index == 0 then
        return number
    end
    return num_to_str(number, 1) .. prefix[index]
end

--- Take any byte and add the appropriate si prefix
-- @tparam number bytes the amount of bytes to prefix
-- @tparam[opt] number start indicate if the number already has a prefix e.g. Kilo = 1, Mega =2, Giga = 3 etc
-- @staticfct bytes_to_grandness
-- @usage -- returns 42.0KB and 123.0MB respectively
-- lib-tde.function.common.bytes_to_grandness(42000)
-- lib-tde.function.common.bytes_to_grandness(123000000)
local function bytes_to_grandness(bytes, start)
    -- sanitize the input
    local number = bytes
    if type(bytes) == "string" then
        number = tonumber(bytes) or 0
    elseif not (type(number) == "number") then
        return number
    end
    return num_to_si_prefix(number, start) .. "B"
end

--- Returns the currently focused screen
-- @staticfct focused_screen
-- @usage -- returns the focused screen, otherwise the first screen
-- lib-tde.function.focused_screen()
local function focused_screen()
    if mouse ~= nil and mouse.screen ~= nil then
        return mouse.screen
    end
    return awful.screen.focused () or screen[1]
end

return {
    split = split,
    sleep = sleep,
    num_to_si_prefix = num_to_si_prefix,
    bytes_to_grandness = bytes_to_grandness,
    num_to_str = num_to_str,
    focused_screen = focused_screen
}
