-- put a 0 in front of a number if it is smaller than 10
local function leadingZero(number)
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

-- format the about of seconds to MM:SS (M = minutes, S = seconds)
local function numberInSecToMS(number)
    if not (type(number) == "number") then
        return "00:00"
    end
    if number < 0 then
        return "00:00"
    end

    local minutes = math.floor(number / 60)
    local seconds = math.floor(number % 60)
    return leadingZero(minutes) .. ":" .. leadingZero(seconds)
end

-- split the input to a table based on the seperator
-- usage: split("abc;def", ";") -> {1: "abc", 2: "def"}
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
        table.insert(t, "")
        return t
    end
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- check if the current time exists
-- the third property is used to mock time
-- don't use it in production
-- the format of time_start and time_end are HH:MM
local function current_time_inbetween(time_start, time_end, mock_time)
    local time = os.date("*t")
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
    numberZeroPadding = leadingZero,
    numberInSecToMS = numberInSecToMS,
    current_time_inbetween = current_time_inbetween,
    unit_test_split = split
}
