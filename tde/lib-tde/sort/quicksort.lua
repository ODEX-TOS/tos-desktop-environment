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
-- Lua implementation of quicksort
--
-- Quicksort is a divide and concur approach to sorting
-- This is a crude implementation that provides decent sorting in most use cases
-- However, it might not be the most optimal sorting algorithm for your case.
-- This module can have the comparison replaced by the user, so that you can also sort tables, numbers, strings etc
--
-- The default comparison function looks as followed:
--
--    function compare(smaller, bigger)
--        return smaller < bigger
--    end
--
-- You can override it using
--
--    quicksort(list, func) -- where func it the new comparison function
--
-- Default usage is as followed:
--
--    local list = {10, 20, 15, 7, 12, 19}
--    local sorted = quicksort(list) -- looks like this: {7, 10, 12, 15, 19, 20}
--
-- Time complexity:
--
-- * `Lookup element`   O(n log(n) ) with worst case n²
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.sort.quicksort
---------------------------------------------------------------------------

--- Sort a list of items in 0(n log(n)) time
-- @tparam table list The list to be sorted
-- @tparam[opt] function func A comparison function -> takes 2 arguments should return true if the first argument is smaller
-- @treturn table A list containing the sorted elements
-- @staticfct lib-tde.sort.quicksort
-- @usage -- This will sort the input list
-- lib-tde.sort.quicksort(list)
-- @usage -- This will sort the input list with a custom comparison function (based on the string length)
-- lib-tde.sort.quicksort(list, function(smaller, bigger)
--    return #smaller < #bigger
-- end)
--
return function(list, func)
    -- set our comparison function to the internal one or to the one provided by the user
    local comparison = function(smaller, bigger)
        return smaller < bigger
    end
    if type(func) == "function" then
        comparison = func
    end

    local function partition(arr, low, high)
        local pivot = arr[high]
        local index = low
        for j = low, high do
            if comparison(arr[j], pivot) then
                local temp = arr[index]
                arr[index] = arr[j]
                arr[j] = temp
                index = index + 1
            end
        end
        local temp = arr[index]
        arr[index] = arr[high]
        arr[high] = temp
        return index
    end

    local function quicksort(arr, low, high)
        if low < high then
            local part = partition(arr, low, high)
            quicksort(arr, low, part - 1)
            quicksort(arr, part + 1, high)
        end
    end

    quicksort(list, 1, #list)

    return list
end
