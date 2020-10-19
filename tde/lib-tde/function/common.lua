---------------------------------------------------------------------------
-- This module adds extra functionality to widgets by exposing commonly used functions.
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.common
---------------------------------------------------------------------------

--- split the input to a table based on the seperator
-- @tparam string inputstr The string to split.
-- @tparam[opt] string sep a regular expression that splits the string (all matches are removed from the set).
-- @treturn table The table as a list of strings
-- @staticfct lib-tde.function.common.split
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
        table.insert(t, "")
        return t
    end
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

--- sleep for x seconds where x can be subseconds long
-- @tparam number time The time in seconds
-- @staticfct lib-tde.function.common.sleep
-- @usage -- lib-tde.function.common.sleep(1)
-- lib-tde.function.common.sleep(5)
-- lib-tde.function.common.sleep(0.2)
local function sleep(time)
    if type(time) == "number" then
        if time < 0 then
            return
        end
        require("socket").select(nil, nil, time)
    end
end

return {
    split = split,
    sleep = sleep
}
