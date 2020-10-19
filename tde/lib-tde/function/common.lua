---------------------------------------------------------------------------
-- This module adds extra functionality to widgets by exposing commonly used functions.
--
-- Lua directly implements the C - standard library and nothing more
-- As a result a lot of common functions in higer level languages lack
-- A solution is to use the this common module including some usefull functions
--
-- For example the split() function splits strings into a table of indexes
--
--    lib-tde.function.common.split("a,b,c,d", ",") -- returns {1:"a",2:"b",3:"c",4:"d"}
--
-- As another example you can use the sleep() function to implement delay into you logic
-- Be carefull using sleep() as it blocks the main thread and can result in extreem poor performance
-- As it also blocks user input from beeing processes
--
--    lib-tde.function.common.sleep(0.5) -- blocks this thread for 0.5 seconds
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.common
---------------------------------------------------------------------------

--- split the input to a table based on the seperator
-- @tparam inputstr string The string to split.
-- @tparam[opt] sep string a regular expression that splits the string (all matches are removed from the set).
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
        table.insert(t, "")
        return t
    end
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

--- sleep for x seconds where x can be subseconds long
-- @tparam time number The time in seconds
-- @staticfct sleep
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
