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
local hashmap = require("tde.lib-tde.datastructure.hashmap")

function Test_data_structure_hashmap_basic_usage()
    local map = hashmap()
    assert(map.get("test") == nil, "The hashmap should't have a: 'test' key in it")
    map.add("test", "hello")
    assert(map.get("test") == "hello", "The hashmap should have a: 'test' key in it")
end

function Test_data_structure_hashmap_api_exists()
    local map = hashmap()
    assert(type(map.get) == "function", "hashmap should have a get function")
    assert(type(map.add) == "function", "hashmap should have a add function")
    assert(type(map.delete) == "function", "hashmap should have a delete function")
end

function Test_data_structure_hashmap_delete_works()
    local map = hashmap()
    assert(map.get("test") == nil, "The hashmap should't have a: 'test' key in it")
    map.add("test", "hello")
    assert(map.get("test") == "hello", "The hashmap should have a: 'test' key in it")
    map.delete("test")
    assert(map.get("test") == nil, "The hashmap should't have a: 'test' key in it")
end

function Test_data_structure_hashmap_add_a_lot_of_keys()
    local map = hashmap()
    for i = 0, 50 do
        map.add(tostring(i), tostring(i) .. " value")
    end
    for i = 0, 50 do
        assert(
            map.get(tostring(i)) == (tostring(i) .. " value"),
            "The hashmap should have the key: '" .. (tostring(i) .. " value") .. "' in it"
        )
    end
end

function Test_data_structure_hashmap_works_with_number_as_key()
    local map = hashmap()
    assert(map.get(1) == nil, "The hashmap should't have a: '1' key in it")
    map.add(1, "hello")
    assert(map.get(1) == "hello", "The hashmap should't have a: '1' key in it")
    map.delete(1)
    assert(map.get(1) == nil, "The hashmap should't have a: '1' key in it")
end

function Test_data_structure_hashmap_works_with_negative_number_as_key()
    local map = hashmap()
    assert(map.get(-98) == nil, "The hashmap should't have a: '-98' key in it")
    map.add(-98, "hello")
    assert(map.get(-98) == "hello", "The hashmap should't have a: '-98' key in it")
    map.delete(-98)
    assert(map.get(-98) == nil, "The hashmap should't have a: '-98' key in it")
end

function Test_hashmap_api_unit_tested()
    local tree = hashmap()
    local amount = 3
    local result = tablelength(tree)
    assert(
        result == amount,
        "You didn't test all hashmap api endpoints, please add them then update the amount to: " .. result
    )
end
