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
-- Lua implementation of radixsort
--
-- radixsort is a divide and concur approach to sorting
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
--    radixsort(list, func) -- where func it the new comparison function
--
-- Default usage is as followed:
--
--    local list = {10, 20, 15, 7, 12, 19}
--    local sorted = radixsort(list) -- looks like this: {7, 10, 12, 15, 19, 20}
--
-- Time complexity:
--
-- * `Lookup element`   O(n log(n) ) with worst case n²
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.sort.radixsort
---------------------------------------------------------------------------

-- Radix sort a list
-- @tparam table list The list to be sorted
-- @tparam[opt] function func A comparison function -> takes 2 arguments should return true if the first argument is smaller
-- @treturn table A list containing the sorted elements
-- @staticfct lib-tde.sort.radixsort
-- @usage -- This will sort the input list
-- lib-tde.sort.radixsort(list)
-- @usage -- This will sort the input list with a custom comparison function (based on the string length)
-- lib-tde.sort.radixsort(list, function(smaller, bigger)
--    return #smaller < #bigger
-- end)
--
local function radixsort(list, func)
    -- default comparison function
    local function compare(smaller, bigger)
        return smaller < bigger
    end

    -- if a comparison function is provided, use it
    if func then
        compare = func
    end

    -- if the list is empty or contains only one element, return it
    if #list < 2 then
        return list
    end

    -- the list is divided in two parts
    local left, right = {}, {}

    -- the middle element
    local mid = math.floor(#list / 2)

    -- split the list in two parts
    for i = 1, #list do
        if i <= mid then
            table.insert(left, list[i])
        else
            table.insert(right, list[i])
        end
    end

    -- sort both parts
    left = radixsort(left, compare)
    right = radixsort(right, compare)

    -- merge the two parts
    local i, j, k = 1, 1, 1
    while i <= #left and j <= #right do
        if compare(left[i], right[j]) then
            list[k] = left[i]
            i = i + 1
        else
            list[k] = right[j]
            j = j + 1
        end
        k = k + 1
    end

    -- the rest of the list
    while i <= #left do
        list[k] = left[i]
        i = i + 1
        k = k + 1
    end

    while j <= #right do
        list[k] = right[j]
        j = j + 1
        k = k + 1
    end

    return list
end

return radixsort
