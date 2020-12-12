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
local stack = require("tde.lib-tde.datastructure.stack")

function test_data_structure_stack_basic_usage()
    local list = stack()
    assert(list.next() == nil)
    list.push("first")
    list.push("second")
    assert(list.size() == 2)
    assert(list.next() == "second")
    assert(list.next() == "second")
    assert(list.pop() == "second")
    assert(list.next() == "first")
    assert(list.next() == "first")
    assert(list.pop() == "first")
    assert(list.next() == nil)
    assert(list.size() == 0)
end

function test_data_structure_stack_types_number()
    local list = stack()
    assert(list.next() == nil)
    list.push(1)
    list.push(2)
    assert(list.size() == 2)
    assert(list.next() == 2)
    assert(list.next() == 2)
    assert(list.pop() == 2)
    assert(list.next() == 1)
    assert(list.next() == 1)
    assert(list.pop() == 1)
    assert(list.next() == nil)
    assert(list.size() == 0)
end

function test_data_structure_stack_functions_exist()
    local list = stack()
    assert(type(list.next) == "function")
    assert(type(list.size) == "function")
    assert(type(list.push) == "function")
    assert(type(list.pop) == "function")
end

function test_data_structure_stack_large_dataset()
    local list = stack()
    for i = 1, 1000 do
        list.push(i)
    end
    assert(list.size() == 1000)
    for i = 1, 999 do
        list.pop()
    end
    assert(list.size() == 1)
end

function test_data_structure_stack_very_large_dataset()
    local list = stack()
    for i = 1, 10000 do
        list.push(i)
    end
    assert(list.size() == 10000)
    for _ = 1, 9999 do
        list.pop()
    end
    assert(list.size() == 1)
end
