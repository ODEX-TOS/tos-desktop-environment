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
local quicksort = require("tde.lib-tde.sort.quicksort")

function test_sorting_quicksort()
    local list = {1, 2, -1}
    local truth = {-1, 1, 2}
    local result = quicksort(list)
    for index, element in ipairs(result) do
        assert(
            element == truth[index],
            "The element: " .. tostring(element) .. " should be: " .. tostring(truth[index]) .. " during quicksort"
        )
    end
end

function test_sorting_quicksort_big()
    local list = {-7, 1, 8, -10, 101, 10, 22, -10, -5, 0, 55, -2, 0}
    local truth = {-10, -10, -7, -5, -2, 0, 0, 1, 8, 10, 22, 55, 101}
    local result = quicksort(list)
    for index, element in ipairs(result) do
        assert(
            element == truth[index],
            "The element: " .. tostring(element) .. " should be: " .. tostring(truth[index]) .. " during quicksort"
        )
    end
end

function test_sorting_quicksort_massive_random()
    local data = {}
    local expected = {}
    for i = 1, 10000 do
        expected[i] = i
    end

    -- shuffle the data
    for _, v in ipairs(expected) do
        local pos = math.random(1, #data + 1)
        table.insert(data, pos, v)
    end

    local result = quicksort(data)

    for index, element in ipairs(result) do
        assert(element == expected[index], "Expected: " .. expected[index] .. " but got " .. element)
    end
end

function test_sorting_quicksort_custom_function_inverted_sort()
    local list = {1, 2, -1}
    local truth = {2, 1, -1}

    -- invert the comparison
    local compare = function(smaller, bigger)
        return smaller > bigger
    end

    local result = quicksort(list, compare)

    for index, element in ipairs(result) do
        assert(element == truth[index], "Expected: " .. truth[index] .. " but got " .. element)
    end
end

function test_sorting_quicksort_works_with_string_size_sorting()
    local comparison = function(small, big)
        return #tostring(small) < #tostring(big)
    end
    local list = {"hello!", "he", "hello", "hel", "h", "hell"}
    local expected = {"h", "he", "hel", "hell", "hello", "hello!"}

    local result = quicksort(list, comparison)

    for index, element in ipairs(result) do
        assert(element == expected[index], "Expected: " .. expected[index] .. " but got " .. element)
    end
end
