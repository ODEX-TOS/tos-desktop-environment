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
-- This contains functions that help with manipulating time.
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.datetime
---------------------------------------------------------------------------

local split = require("lib-tde.function.common").split

--- Adds a leading 0 if the number is smaller than 10
-- @param number integer the number to pad zero's in front of
-- @return string a string representing the number with padded zero's
-- @staticfct numberZeroPadding
-- @usage -- This will return 06
-- lib-tde.function.datetime.numberZeroPadding(6)
local function numberZeroPadding(number)
    if not (type(number) == "number") then
        return "00"
    end
    if number < 0 then
        return tostring(number)
    end
    if number < 10 then
        return "0" .. number
    end
    return tostring(number)
end

--- Format the amount of seconds to MM:SS (M = minutes, S = seconds)
-- @param number integer the number in seconds that need to be converted to a MINUTE:SECOND string representation
-- @return string The string format of the time in MM:SS
-- @staticfct numberInSecToMS
-- @usage -- This will return 02:06
-- lib-tde.function.datetime.leadingZero(126)
local function numberInSecToMS(number)
    if not (type(number) == "number") then
        return "00:00"
    end
    if number < 0 then
        return "00:00"
    end

    local minutes = math.floor(number / 60)
    local seconds = math.floor(number % 60)
    return numberZeroPadding(minutes) .. ":" .. numberZeroPadding(seconds)
end

--- Check if the current system time is in between 2 time's
-- @param time_start string A string in the form HH:MM (Hour:Minute) representing the start time
-- @param time_end string A string in the form HH:MM (Hour:Minute) representing the end time
-- @return boolean Returns if the system time is between these numbers
-- @staticfct current_time_inbetween
-- @usage -- This will return True if the system time is before 1 pm
-- lib-tde.function.datetime.current_time_inbetween("00:00", "13:00")
local function current_time_inbetween(time_start, time_end, mock_time)
    local time = os.date("*t")

    -- mock time is used in unit tests to verify if this function works as intended
    if not (mock_time == nil) then
        time = mock_time
    end

    if not (type(time_start) == "string") then
        return false
    end

    if not (type(time_end) == "string") then
        return false
    end

    local time_start_split = split(time_start, ":")
    local time_end_split = split(time_end, ":")
    local time_start_hour = tonumber(time_start_split[1])
    local time_start_min = tonumber(time_start_split[2])
    local time_end_hour = tonumber(time_end_split[1])
    local time_end_min = tonumber(time_end_split[2])

    if
        not (type(time_start_hour) == "number") or not (type(time_start_min) == "number") or
            not (type(time_end_hour) == "number") or
            not (type(time_end_min) == "number")
     then
        return false
    end

    if time_start_hour < 0 or time_start_min < 0 or time_end_hour < 0 or time_end_min < 0 then
        return false
    end

    if time_start_hour > 24 or time_start_min > 60 or time_end_hour > 24 or time_end_min > 60 then
        return false
    end

    local currentTimeInMin = (time.hour * 60) + time.min

    return currentTimeInMin >= ((time_start_hour * 60) + time_start_min) and
        currentTimeInMin <= ((time_end_hour * 60) + time_end_min)
end
return {
    numberZeroPadding = numberZeroPadding,
    numberInSecToMS = numberInSecToMS,
    current_time_inbetween = current_time_inbetween,
    unit_test_split = split
}
