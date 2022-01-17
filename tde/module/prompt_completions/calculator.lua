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
local icons = require("theme.icons")
local common = require("lib-tde.function.common")

-- convert some common math symbols to their respective lua representation
--
-- Symbols
-- a ** b (Power) -> math.pow(a,b)
-- a ^ b (power)  -> math.pow(a,b)
-- min -> math.min()
local function math_to_lua (query)
    local replace = {
        "min",
        "modf",
        "ceil",
        "floor",
        "log",
        "deg",
        "asin",
        "abs",
        "sinh",
        "tanh",
        "ult",
        "log10",
        "sqrt",
        "atan",
        "pi",
        "fmod",
        "acos",
        "cos",
        "max",
        "exp",
        "atan2",
        "cosh",
        "sin",
        "rad",
        "pow"
    }

    local _

    query, _ = string.gsub(query, "math%.", "")
    -- update simple value
    for _, val in ipairs(replace) do
        query, _ = string.gsub(query, "%f[%a]" .. val .. "%(", "math." .. val .. '(' )
    end

     -- Now we do a search and replace for know values such as pi, tau
     query, _ = string.gsub(query, "pi", common.to_point(math.pi))

     local tau = 1.618033988749894
     query, _ = string.gsub(query, "tau", common.to_point(tau))

     local star_regex = "([%d%s%w]+)(%*%*)([%d%s%w]+)"
     while string.find(query, star_regex) ~= nil do
        query, _ = string.gsub(query, star_regex, " math.pow(%1, %3) ")
     end


     local had_pow_regex = "([%d%s%w]+)(%^)([%d%s%w]+)"
     while string.find(query, had_pow_regex) ~= nil do
        query, _ = string.gsub(query, had_pow_regex, " math.pow(%1, %3) ")
     end


    return query
end

local function get_completions(query)
    local res = {}

    local evaluated = load("return " .. math_to_lua(query))

    if type(evaluated) == "function" then
        local err, payload = pcall(evaluated)
        if not err then
            return res
        end

        if type(payload) ~= "number" and type(payload) ~= "string" then
            return res
        end

        table.insert(res, {
            icon = icons.calc,
            text = tostring(payload),
            __score = math.huge,
            payload = {}
        })
    end

    return res
end

local function perform_action(_)
end

local name = "Calc"

return {
    get_completion = get_completions,
    perform_action = perform_action,
    name = name,
}