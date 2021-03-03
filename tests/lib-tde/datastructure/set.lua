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
local set = require("tde.lib-tde.datastructure.set")

function test_data_structure_set_basic_usage()
    local map = set()
    assert(not map.exists("test"), "The set should't have a: 'test' key in it")
    map.add("test")
    assert(map.exists("test"), "The set should have a: 'test' key in it")
end

function test_data_structure_set_api_exists()
    local map = set()
    assert(type(map.exists) == "function", "set should have a exists function")
    assert(type(map.add) == "function", "set should have a add function")
    assert(type(map.remove) == "function", "set should have a remove function")
    assert(type(map.itterate) == "function", "set should have a itterate function")
    assert(type(map.to_list) == "function", "set should have a to_list function")
    assert(type(map.to_ordered_list) == "function", "set should have a to_ordered_list function")

end

function test_data_structure_set_remove_works()
    local map = set()
    map.add("test")
    assert(map.exists("test"), "The set should have a: 'test' key in it")
    assert(#map.to_list() == 1, "The length of the map should be 1")
    map.remove("test")
    assert(not map.exists("test"), "The set should't have a: 'test' key in it")
    assert(#map.to_list() == 0, "The length of the map should be 0")
end

function test_data_structure_set_loop()
    local map = set()
    for i = 1, 50 do
        map.add(i)
        map.add(i)
    end
    for i = 1, 50 do
        assert(
            map.exists(i),
            "The set should have the key: '" .. tostring(i) .. "' in it"
        )
    end

    assert(#map.to_list() == 50, "A set shouldn't have any unique keys expected 50 elements but got: " .. tostring(#map.to_list()))
end

function test_data_structure_set_works_with_number_as_key()
    local map = set()
    assert(not map.exists(1), "The set should't have a: '1' key in it")
    map.add(1)
    assert(map.exists(1), "The set should't have a: '1' key in it")
    map.remove(1)
    assert(not map.exists(1), "The set should't have a: '1' key in it")
end

function test_data_structure_set_itterator()
    local map = set()
    for i = 1, 10, 1 do
        print("Adding: " .. tostring(i*2))
        map.add(i * 2)
    end

    assert(#(map.to_list()) == 10, "Expected 10 elements but got: " .. #(map.to_list()))

    for index, item in map.itterate() do
        assert(item == (index*2), "The itterator gives a wrong result for the given index " .. item .. ":" .. index*2)
    end
end

function test_data_structure_set_unique_key()
    local map = set()

    assert(#map.to_list() == 0, "The set list should be empty")

    map.add("abc")
    assert(map.exists("abc"), "The set key 'abc' should exist")

    assert(#map.to_list() == 1, "The set list should only contain one item: ".. #map.to_list())

    assert(not map.add("abc"), "The set key should already exist")

    assert(#map.to_list() == 1 ,"The set list should only contain one item")

    map.add("def")

    assert(#map.to_list() == 2,  "The set list should only contain two items")

end


function test_set_api_unit_tested()
    local map = set()
    local amount = 6
    local result = tablelength(map)
    assert(
        result == amount,
        "You didn't test all set api endpoints, please add them then update the amount to: " .. result
    )
end

function test_set_api_to_ordered_list()
    local map = set()
    for i = 1, 10, 1 do
        map.add(i)
    end
    -- in the ordered list all elements keep growing
    local prev_value = -1
    for _, value in ipairs(map.to_ordered_list()) do
        assert(value > prev_value, "The current element is smaller that the previous: " .. value .. " - But should be larger that " .. prev_value )
    end
end
