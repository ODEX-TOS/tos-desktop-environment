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
local common = require("lib-tde.function.common")
local split = common.split
local trim = common.trim

--- Adds a leading 0 if the number is smaller than 10
-- @tparam number number the number to pad zero's in front of
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
-- @tparam number number the number in seconds that need to be converted to a MINUTE:SECOND string representation
-- @return string The string format of the time in MM:SS
-- @staticfct numberInSecToMS
-- @usage -- This will return 02:06
-- lib-tde.function.datetime.numberInSecToMS(126)
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

--- Format the amount of seconds to HH:MM:SS (H = Hours, M = minutes, S = seconds)
-- @tparam number number the number in seconds that need to be converted to a HOUR:MINUTE:SECOND string representation
-- @return string The string format of the time in HH:MM:SS
-- @staticfct numberInSecToHMS
-- @usage -- This will return 00:02:06
-- lib-tde.function.datetime.numberInSecToHMS(126)
local function numberInSecToHMS(number)
    if not (type(number) == "number") then
        return "00:00:00"
    end
    if number < 0 then
        return "00:00:00"
    end

    local hours = math.floor(number / 3600)
    local minutes = math.floor((number % 3600) / 60)
    local seconds = math.floor(number % 60)
    return numberZeroPadding(hours) .. ':' .. numberZeroPadding(minutes) .. ":" .. numberZeroPadding(seconds)
end

--- Check if the current system time is in between 2 time's
-- @tparam string time_start A string in the form HH:MM (Hour:Minute) representing the start time
-- @tparam string time_end A string in the form HH:MM (Hour:Minute) representing the end time
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

--- This function tries to parse the input string and convert it from datetime to seconds
-- @tparam string text A string in the form DD:HH:MM:SS or DD HH MM SS or DD-HH-MM-SS or HH:MM:SS XXh XXm XXs or any combination of the above
-- @return number The amount of seconds extracted, 0 when failing to parse
-- @staticfct toSeconds
-- @usage -- This will return the amount of seconds
-- lib-tde.function.datetime.toSeconds("10h5m2s")
-- lib-tde.function.datetime.toSeconds("100s")
-- lib-tde.function.datetime.toSeconds("10h 2s")
-- lib-tde.function.datetime.toSeconds("2s 5d")
-- lib-tde.function.datetime.toSeconds("3:2:1")
-- lib-tde.function.datetime.toSeconds("3 2 1")
-- lib-tde.function.datetime.toSeconds("3-2-1")
-- lib-tde.function.datetime.toSeconds("3:02:01")
-- lib-tde.function.datetime.toSeconds("10m-2s")
-- lib-tde.function.datetime.toSeconds("10h2m 7s 5d")
local function toSeconds(text)
    if type(text) ~= "string" then
        return 0
    end

    -- first lets check if it is a number
    local _num = tonumber(text)
    if _num ~= nil then
        if _num > 0 then
            return _num
        end
        return 0
    end

    -- possible delimiters to denote the timings
    local delimiters = {',', '%.', '-', ' ', '\t'}

    -- convert all delimiters to one generic delimiter ':'
    for _, delimiter in ipairs(delimiters) do
        text = string.gsub(text, delimiter, ':')
    end

    text = trim(text)

    local splitted = split(text, ':')

    if #splitted < 1 then
        return 0
    end

    local trimmed_split = {}

    -- remove possible leading/trailing whitespace and make all text lowercase
    for _, v in ipairs(splitted) do
        table.insert(trimmed_split, trim(v):lower())
    end

    -- translations to tell how much time is corresponding to the index
    local lookup_table_to_sec = {1, 60, 3600, 86400, 604800, 31449600}

    -- possible expressions to denote the timings,
    -- S: seconds, M: Minutes, H: hours, D: Days, W: weeks, Y: years
    local lookup_shortcuts = {"s", "m", "h", "d", "w", "y"}

    -- we should now have a sorted list of items in the possible following style
    -- ["10", "1d", "001", "01s"]

    local total = 0
    for index, value in ipairs(trimmed_split) do
        local weighted_index = (#trimmed_split + 1) - index
        -- check if the value is a number
        local num = tonumber(value)
        -- we have a simple number, lets add the weight to that
        if num ~= nil then
            total = total + (num * lookup_table_to_sec[weighted_index])
        else
            -- we most likely have the number followed by the date representation
            -- lets split those
            local splitted_date = split(value, '0-9')[1]
            local num_str = string.gsub(value, splitted_date, '')
            num = tonumber(num_str) or 0
            local found_index = -1
            -- find the corresponding lookup_table_to_sec value
            for _index, weight in ipairs(lookup_shortcuts) do
                if weight == splitted_date then
                    found_index = _index
                end
            end
            -- we found a match for the date
            if found_index > 0 then
                total = total + (num * lookup_table_to_sec[found_index])
            end

        end
    end

    return total
end

return {
    numberZeroPadding = numberZeroPadding,
    numberInSecToMS = numberInSecToMS,
    numberInSecToHMS = numberInSecToHMS,
    current_time_inbetween = current_time_inbetween,
    unit_test_split = split,
    toSeconds = toSeconds,
}
