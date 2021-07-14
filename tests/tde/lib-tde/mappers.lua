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
local mappers = require("tde.lib-tde.mappers")

local function compare_list(first, second)
    assert(#first == #second, "Arrays are not the same length")
    for index, element in ipairs(first) do
        assert(element == second[index], "Values in index " .. index .. " are not the same for both arrays")
    end
end

function Test_mappers_mapping_basics()
    local list = {1, 2, 3}
    local result =
        mappers.map(
        list,
        function(element, _)
            return element * 2
        end
    )
    local expected = {2, 4, 6}
    compare_list(result, expected)
end

function Test_mappers_mapping_with_index()
    local list = {1, 2, 3, 5}
    local result =
        mappers.map(
        list,
        function(element, index)
            return element * index
        end
    )
    local expected = {1, 4, 9, 20}
    compare_list(result, expected)
end

function Test_mappers_mapping_with_string()
    local list = {"A", "B", "C"}
    local result =
        mappers.map(
        list,
        function(element, _)
            return element .. "E"
        end
    )
    local expected = {"AE", "BE", "CE"}
    compare_list(result, expected)
end

function Test_mappers_filter_basics()
    local list = {1, 2, 3, 5, 7, 9, 10}
    local result =
        mappers.filter(
        list,
        function(element, _)
            return element < 7
        end
    )
    local expected = {1, 2, 3, 5}
    compare_list(result, expected)
end

function Test_mappers_filter_basics_with_string()
    local list = {"a", "b", "c", "d"}
    local result =
        mappers.filter(
        list,
        function(element)
            return element < "c"
        end
    )
    local expected = {"a", "b"}
    compare_list(result, expected)
end

function Test_mapper_reducer_basics()
    local list = {1, 2, 3, 4}
    local result =
        mappers.reduce(
        list,
        function(acc, element)
            return acc + element
        end,
        0
    )
    assert(result == 10, "The result should be 10 but got: " .. tostring(result))
end

function Test_mapper_reducer_basics_with_initial_value()
    local list = {1, 2, 3, 4}
    local result =
        mappers.reduce(
        list,
        function(acc, element)
            return acc + element
        end,
        30
    )
    assert(result == 40, "The result should be 40 but got: " .. tostring(result))
end

function Test_mapper_reducer_basics_with_index()
    local list = {1, 2, 3, 4}
    local result =
        mappers.reduce(
        list,
        function(acc, element, index)
            return acc + element + index
        end,
        0
    )
    assert(result == 20, "The result should be 20 but got: " .. tostring(result))
end

function Test_mapper_reducer_with_string()
    local list = {"a", "b", "c"}
    local result =
        mappers.reduce(
        list,
        function(acc, element)
            return acc .. element
        end,
        ""
    )
    assert(result == "abc", "The result should be 'abc' but got: '" .. result .. "'")
end

function Test_mapper_contains_basic()
    local list = {1, 2, 3, 4, 5}
    local result =
        mappers.contains(
        list,
        function(element)
            return element == 4
        end
    )
    assert(result, "The result should be true but got false")
end

function Test_mapper_contains_basic_not_exists()
    local list = {1, 2, 3, 4, 5}
    local result =
        mappers.contains(
        list,
        function(element)
            return element == 9
        end
    )
    assert(not result, "The result should be false but got true")
end

function Test_mapper_contains_basic_not_exists_index()
    local list = {1, 2, 3, 4, 5}
    local result =
        mappers.contains(
        list,
        function(_, index)
            return index > 10
        end
    )
    assert(not result, "The result should be false but got true")
end

function Test_mapper_contains_string()
    local list = {"A", "B", "C"}
    local result =
        mappers.contains(
        list,
        function(element)
            return element == "a"
        end
    )
    assert(not result, "The result should be false but got true")
end

function Test_mapper_contains_string()
    local list = {"A", "B", "C", "a", "b", "c"}
    local result =
        mappers.contains(
        list,
        function(element)
            return element == "a"
        end
    )
    assert(result, "The result should be true but got false")
end

function Test_mappers_api_is_correct()
    assert(type(mappers.map) == "function", "The mappers api should be contain a map function")
    assert(type(mappers.filter) == "function", "The mappers api should be contain a filter function")
    assert(type(mappers.reduce) == "function", "The mappers api should be contain a reduce function")
    assert(type(mappers.contains) == "function", "The mappers api should be contain a contains function")
end

function Test_mappers_api_unit_tested()
    local amount = 4
    local result = tablelength(mappers)
    assert(
        result == amount,
        "You didn't test all mappers api endpoints, please add them then update the amount to: " .. result
    )
end
