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
    assert(list.next() == nil, "The stack should be empty")
    list.push("first")
    list.push("second")
    assert(list.size() == 2, "The stack size is incorrect")
    assert(list.next() == "second", "The stack next is incorrect")
    assert(list.next() == "second", "The stack next is incorrect")
    assert(list.pop() == "second", "The stack pop should be equal to the stack next")
    assert(list.next() == "first", "The stack next is incorrect")
    assert(list.next() == "first", "The stack next is incorrect")
    assert(list.pop() == "first", "The stack pop should be equal to the stack next")
    assert(list.next() == nil, "The stack should be empty")
    assert(list.size() == 0, "The stack size is incorrect")
end

function test_data_structure_stack_types_number()
    local list = stack()
    assert(list.next() == nil, "The stack should be empty")
    list.push(1)
    list.push(2)
    assert(list.size() == 2, "The stack size is incorrect")
    assert(list.next() == 2, "The stack next is incorrect")
    assert(list.next() == 2, "The stack next is incorrect")
    assert(list.pop() == 2, "The stack pop should be equal to the stack next")
    assert(list.next() == 1, "The stack next is incorrect")
    assert(list.next() == 1, "The stack next is incorrect")
    assert(list.pop() == 1, "The stack pop should be equal to the stack next")
    assert(list.next() == nil, "The stack should be empty")
    assert(list.size() == 0, "The stack size is incorrect")
end

function test_data_structure_stack_functions_exist()
    local list = stack()
    assert(type(list.next) == "function", "The stack api should have a next function")
    assert(type(list.size) == "function", "The stack api should have a size function")
    assert(type(list.push) == "function", "The stack api should have a push function")
    assert(type(list.pop) == "function", "The stack api should have a pop function")
end

function test_data_structure_stack_large_dataset()
    local list = stack()
    for i = 1, 1000 do
        list.push(i)
    end
    assert(list.size() == 1000, "The stack size is incorrect")
    for i = 1, 999 do
        list.pop()
    end
    assert(list.size() == 1, "The stack size is incorrect")
end

function test_data_structure_stack_very_large_dataset()
    local list = stack()
    for i = 1, 10000 do
        list.push(i)
    end
    assert(list.size() == 10000, "The stack size is incorrect")
    for _ = 1, 9999 do
        list.pop()
    end
    assert(list.size() == 1, "The stack size is incorrect")
end

function test_stack_api_unit_tested()
    local tree = stack()
    local amount = 4
    local result = tablelength(tree)
    assert(
        result == amount,
        "You didn't test all stack api endpoints, please add them then update the amount to: " .. result
    )
end
