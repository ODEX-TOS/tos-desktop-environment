---------------------------------------------------------------------------
--- Commong functions used within TDE
--
-- @author Tom Meyers &lt;tom@odex.be&gt;
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.common
---------------------------------------------------------------------------

-- split the input to a table based on the seperator
-- usage: split("abc;def", ";") -> {1: "abc", 2: "def"}
--
-- @tparam string inputstr The string to split.
-- @tparam[opt] string sep a regular expression that splits the string (all matches are removed from the set).
-- @return table The table as a list of strings
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

-- sleep for x seconds where x can be subseconds long
--
-- @tparam number time The time in seconds
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
