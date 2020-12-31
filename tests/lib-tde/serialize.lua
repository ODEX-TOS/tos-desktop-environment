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
local serialize = require("lib-tde.serialize")

function test_serialize_api()
    assert(type(serialize.deserialize) == "function", "Make sure serialize.deserialize exists")
    assert(type(serialize.serialize) == "function", "Make sure serialize.serialize exists")
    assert(type(serialize.serialize_to_file) == "function", "Make sure serialize.serialize_to_file exists")
    assert(type(serialize.deserialize_from_file) == "function", "Make sure serialize.deserialize_from_file exists")
end

function test_serialize_basic_usage()
    local table = {1, 2, 3}
    local result = serialize.serialize(table)
    local deserialized = serialize.deserialize(result)
    assert(
        serialize.serialize(deserialized) == result,
        "Make sure serializing the table to result in: " .. result .. " but got: " .. serialize.serialize(deserialized)
    )
end

function test_serialize_basic_usage_2()
    local table = {a = "a", b = "b", c = "c"}
    local result = serialize.serialize(table)
    local deserialized = serialize.deserialize(result)
    assert(
        serialize.serialize(deserialized) == result,
        "Make sure serialize the table to result in: " .. result .. " but got: " .. serialize.serialize(deserialized)
    )
end

function test_serialize_api_unit_tested()
    local amount = 4
    local result = tablelength(serialize)
    assert(
        result == amount,
        "You didn't test all serialize api endpoints, please add them then update the amount to: " .. result
    )
end
