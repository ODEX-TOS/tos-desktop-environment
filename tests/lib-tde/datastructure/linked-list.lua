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
local linkedList = require("tde.lib-tde.datastructure.linkedList")

function test_data_structure_linkedList_basic_usage()
    local list = linkedList()

    assert(list.head.value == nil, "Check that the double linked list has a head.value property")
    assert(list.head.next.value == nil, "Check that the double linked list has a head.next.value property")
    assert(list.head.previous.value == nil, "Check that the double linked list has a head.previous.value property")

    list.setHead("test")
    list.setNext("test2")
    list.setPrevious("test-1")

    assert(list.head.value == "test", "The linked list head should be set")

    list.next()

    assert(list.head.value == "test2", "The linked list head should be set")
    assert(list.head.next == nil, "The linked list head.next shouldn't exist")
    assert(list.head.previous.value == "test", "The linked list head.previous should exist")

    list.previous()
    assert(list.head.value == "test", "The head value should be correct")
    assert(list.head.next.value == "test2", "The next value should be correct")
    assert(list.head.previous.value == "test-1", "The previous value should be correct")
end

function test_data_structure_linkedList_api_exists()
    local list = linkedList()

    assert(type(list.setHead) == "function", "The linked list api should have a setHead function")
    assert(type(list.setNext) == "function", "The linked list api should have a setNext function")
    assert(type(list.setPrevious) == "function", "The linked list api should have a setPrevious function")

    assert(type(list.insertNext) == "function", "The linked list api should have a insertNext function")
    assert(type(list.insertPrevious) == "function", "The linked list api should have a insertPrevious function")

    assert(type(list.removePrevious) == "function", "The linked list api should have a removePrevious function")
    assert(type(list.removeNext) == "function", "The linked list api should have a removeNext function")

    assert(type(list.head) == "table", "The linked list api should have a head (table)")
    assert(type(list.next) == "function", "The linked list api should have a next function")
    assert(type(list.previous) == "function", "The linked list api should have a previous function")
end

function test_data_structure_linkedList_delete_works_previous()
    local list = linkedList()
    list.setHead("hello")
    list.setNext("World")
    list.next()
    assert(list.head.previous.value == "hello", "The previous attribute of the head is not set")
    list.removePrevious()
    assert(list.head.previous.value == nil, "The previous attribute of the head is set")
    assert(list.head.value == "World", "The value of head is not set")
end

function test_data_structure_linkedList_delete_works_next()
    local list = linkedList()
    list.setHead("hello")
    list.setPrevious("World")
    list.previous()
    assert(list.head.next.value == "hello", "The next attribute of the head is not set")
    list.removeNext()
    assert(list.head.next.value == nil, "The next attribute of the head is set")
    assert(list.head.value == "World", "The value of head is not set")
end

function test_data_structure_linkedList_delete_in_between_values_works()
    local list = linkedList()
    list.setHead(1)
    list.setNext(2)
    list.next()
    list.setNext(3)
    -- head is at 1
    list.previous()
    -- remove next
    list.removeNext()
    assert(list.head.next.value == 3, "The next attribute of head is not set")
end

function test_data_structure_linkedList_delete_in_between_values_works_previous()
    local list = linkedList()
    list.setHead(1)
    list.setPrevious(2)
    list.previous()
    list.setPrevious(3)
    -- head is at 1
    list.next()
    -- remove next
    list.removePrevious()
    assert(list.head.previous.value == 3, "The previous attribute of head is not set")
end

function test_data_structure_linkedList_multi_next()
    local list = linkedList()
    list.setHead(0)
    for i = 1, 50 do
        list.setNext(i)
        list.next()
    end
    assert(list.head.value == 50, "The head value is not set")
    assert(list.head.next == nil, "The head next attribute should be empty")
    assert(list.head.previous.value == 49, "The head previous attribute should exist")
    assert(list.head.previous.previous.value == 48, "The head previous attribute should also have a previous attribute")
end

function test_general_linked_list()
    local list = linkedList()
    assert(list.head.value == nil, "The head value should be empty")
    assert(list.head.next.value == nil, "The head next attribute should be empty")
    assert(list.head.previous.value == nil, "The head previouse attribute should be empty")
    list.setHead("Hello")
    list.setNext("world")
    list.setPrevious("olla")

    assert(list.head.value == "Hello", "The head value should exist")
    assert(list.head.next.value == "world", "The head next value should exist")
    assert(list.head.previous.value == "olla", "The head previous value should exist")
    list.next()
    assert(list.head.next == nil, "The head next should be empty")
    assert(list.head.value == "world", "The head value should exist")
    assert(list.head.previous.value == "Hello", "The head previous value should exist")
end

function test_data_structure_linkedList_insertBetween_Nodes()
    local list = linkedList()
    list.setHead(0)
    list.setNext(1)
    list.insertNext(2)
    assert(list.head.value == 0, "The head value should exist")
    assert(list.head.next.value == 2, "The head next attribute should exist")
    assert(list.head.next.next.value == 1, "The head next attribute should have a next attribute")
end

function test_data_structure_linkedList_insertBetween_Nodes_previous()
    local list = linkedList()
    list.setHead(0)
    list.setPrevious(1)
    list.insertPrevious(2)
    assert(list.head.value == 0, "The head value should exist")
    assert(list.head.previous.value == 2, "The head previous attribute should exist")
    assert(list.head.previous.previous.value == 1, "The head previous attribute should have a previous attribute")
end

function test_linked_list_api_unit_tested()
    local tree = linkedList()
    local amount = 10
    local result = tablelength(tree)
    assert(
        result == amount,
        "You didn't test all linked list api endpoints, please add them then update the amount to: " .. result
    )
end
