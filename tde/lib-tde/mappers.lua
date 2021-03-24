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
-- This module exposes helper functions wrapped around lists in order to manipulate them
--
-- Useful functional principles exist such as, maps, reducers and filters.
--
-- Examples:
--
-- Mapping
--
--    local list = {1, 3, 2, 2}
--    -- result: {2, 5, 5, 6}
--    local result = map(list, function(element, index)
--       return element + index
--    end)
--
-- Filter
--    local list = {1, 3, 5, 7}
--    -- result: {1, 3}
--    local result = filter(list, function(element, index)
--       return element < 5
--    end)
--
-- Reduce
--    local list = {1, 3, 5, 7}
--    -- result: 16 ( 1 + 3 + 5 + 7)
--    local result = reduce(list, function(accumulator, element, index)
--       return accumulator + element
--    end, 0)
--    local list = {1, 3, 5, 7}
--    -- result: 26 ( 1 + 3 + 5 + 7) with initial value of 10
--    local result = reduce(list, function(accumulator, element, index)
--       return accumulator + element
--    end, 10)
--
-- Contains
--    local list = {1, 3, 5, 7}
--    -- result: true
--    local result = reduce(list, function(element, index)
--       return element == 3
--    end)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.mappers
-----------------

--- Returns a new array containing the results of calling a function on every element in this array.
-- @param arr table The array on which we iterate over
-- @param func function The function to call on each element (element, index)
-- @treturn array The array containing the mapped values
-- @staticfct map
-- @usage -- This returns {2, 5, 5, 6}
--    local list = {1, 3, 2, 2}
--    local result = map(list, function(element, index)
--       return element + index
--    end)
local function map(arr, func)
    local result = {}
    for index, element in ipairs(arr) do
        result[index] = func(element, index)
    end
    return result
end

--- Returns a new array containing all elements of the calling array for which the provided filtering function returns `true`.
-- @param arr table The array on which we iterate over
-- @param func function The function to call on each element (element, index)
-- @treturn array The array containing the 'allowed' elements
-- @staticfct filter
-- @usage -- This returns {1, 3}
--    local list = {1, 3, 5, 7}
--    local result = filter(list, function(element, index)
--       return element < 5
--    end)
local function filter(arr, func)
    local result = {}
    for index, element in ipairs(arr) do
        if func(element, index) then
            table.insert(result, element)
        end
    end
    return result
end

--- Apply a function against an accumulator and each value of the array (from left-to-right) as to reduce it to a single value.
-- @param arr table The array on which we iterate over
-- @param func function The function to call on each element (element, index)
-- @param initial_value any The initial value when first entering the reduce function
-- @treturn array The array containing the 'allowed' elements
-- @staticfct filter
-- @usage -- This returns 16
--    local list = {1, 3, 5, 7}
--    local result = reduce(list, function(accumulator, element, index)
--       return accumulator + element
--    end, 0)
local function reduce(arr, func, initial_value)
    local accumulator = initial_value
    for index, element in ipairs(arr) do
        accumulator = func(accumulator, element, index)
    end
    return accumulator
end

--- Returns true if at least one element in this array satisfies the provided testing function.
-- @param arr table The array on which we iterate over
-- @param func function The function to call on each element (element, index)
-- @treturn bool If at least one element returned `true` in the testing function
-- @staticfct contains
-- @usage -- This returns true
--    local list = {1, 3, 5, 7}
--    local result = reduce(list, function(element, index)
--       return element == 3
--    end)
local function contains(arr, func)
    for index, element in ipairs(arr) do
        if func(element, index) then
            return true
        end
    end
    return false
end

return {
    map = map,
    filter = filter,
    reduce = reduce,
    contains = contains
}
