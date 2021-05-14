---------------------------------------------------------------------------
--- Remote control module allowing usage of tde-client.
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @module awful.remote
---------------------------------------------------------------------------

-- Grab environment we need
require("awful.dbus")
local load = loadstring or load -- luacheck: globals loadstring (compatibility with Lua 5.1)
local tostring = tostring
local ipairs = ipairs
local table = table
local unpack = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)
local dbus = dbus
local type = type
local split = require('gears.string').split

local function table_to_string(tbl, depth, indent)
    depth = depth or 3
    indent = indent or 1
    -- limit the max size
    if indent > depth then
        if type(tbl) == "table" then
            return "{  ..."
        end
        return ""
    end
    local formatting = string.rep("  ", indent)
    local result = "{\n"
    for k, v in pairs(tbl) do
        local format = formatting .. tostring(k) .. ": "
        if type(v) == "table" then
            result = result .. format .. table_to_string(v, depth - 1, indent + 1) .. formatting .. "},\n"
        else
            if type(v) == "string" then
                result = result .. format .. "'" .. v .. "',\n"
            else
                result = result .. format .. tostring(v) .. ",\n"
            end
        end
    end
    -- edge case initial indentation requires manually adding ending bracket
    if indent == 1 then
        return result .. "}"
    end
    return result
end

local LOG_ERR = "\27[0;31m[ ERROR "

if dbus then
    dbus.connect_signal(
        "org.awesomewm.awful.Remote",
        function(data, code)
            if data.member == "Eval" then
                print("Loading code from dbus")
                local splitted_code = split(code, '\n')
                for _, code_line in ipairs(splitted_code) do
                    print("\t\t\27[0;33m" .. code_line .. "\27[0m")
                end
                local f, e = load(code)
                if not f then
                    return "s", e
                end
                local results = {pcall(f)}
                if not table.remove(results, 1) then
                    local err_res = "Error during tde-client code execution: " .. tostring(results[1])
                    print(err_res, LOG_ERR)
                    return "s", err_res
                end
                local retvals = {}
                for _, v in ipairs(results) do
                    local t = type(v)
                    if t == "boolean" then
                        table.insert(retvals, "b")
                        table.insert(retvals, v)
                    elseif t == "number" then
                        table.insert(retvals, "d")
                        table.insert(retvals, v)
                    elseif t == "table" then
                        table.insert(retvals, "s")
                        table.insert(retvals, table_to_string(v))
                    else
                        table.insert(retvals, "s")
                        table.insert(retvals, tostring(v))
                    end
                end
                return unpack(retvals)
            end
        end
    )
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
