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

    assert(list.head.value == nil)
    assert(list.head.next.value == nil)
    assert(list.head.previous.value == nil)

    list.setHead("test")
    list.setNext("test2")
    list.setPrevious("test-1")

    assert(list.head.value == "test")

    list.next()

    assert(list.head.value == "test2")
    assert(list.head.next == nil)
    assert(list.head.previous.value == "test")

    list.previous()
    assert(list.head.value == "test")
    assert(list.head.next.value == "test2")
    assert(list.head.previous.value == "test-1")
end

function test_data_structure_linkedList_api_exists()
    local list = linkedList()

    assert(type(list.setHead) == "function")
    assert(type(list.setNext) == "function")
    assert(type(list.setPrevious) == "function")

    assert(type(list.insertNext) == "function")
    assert(type(list.insertPrevious) == "function")

    assert(type(list.removePrevious) == "function")
    assert(type(list.removeNext) == "function")

    assert(type(list.head) == "table")
    assert(type(list.next) == "function")
    assert(type(list.previous) == "function")
end

function test_data_structure_linkedList_delete_works_previous()
    local list = linkedList()
    list.setHead("hello")
    list.setNext("World")
    list.next()
    assert(list.head.previous.value == "hello")
    list.removePrevious()
    assert(list.head.previous.value == nil)
    assert(list.head.value == "World")
end

function test_data_structure_linkedList_delete_works_next()
    local list = linkedList()
    list.setHead("hello")
    list.setPrevious("World")
    list.previous()
    assert(list.head.next.value == "hello")
    list.removeNext()
    assert(list.head.next.value == nil)
    assert(list.head.value == "World")
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
    assert(list.head.next.value == 3)
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
    assert(list.head.previous.value == 3)
end

function test_data_structure_linkedList_multi_next()
    local list = linkedList()
    list.setHead(0)
    for i = 1, 50 do
        list.setNext(i)
        list.next()
    end
    assert(list.head.value == 50)
    assert(list.head.next == nil)
    assert(list.head.previous.value == 49)
    assert(list.head.previous.previous.value == 48)
end

function test_general_linked_list()
    local list = linkedList()
    assert(list.head.value == nil)
    assert(list.head.next.value == nil)
    assert(list.head.previous.value == nil)
    list.setHead("Hello")
    list.setNext("world")
    list.setPrevious("olla")

    assert(list.head.value == "Hello")
    assert(list.head.next.value == "world")
    assert(list.head.previous.value == "olla")
    list.next()
    assert(list.head.next == nil)
    assert(list.head.value == "world")
    assert(list.head.previous.value == "Hello")
end

function test_data_structure_linkedList_insertBetween_Nodes()
    local list = linkedList()
    list.setHead(0)
    list.setNext(1)
    list.insertNext(2)
    assert(list.head.value == 0)
    assert(list.head.next.value == 2)
    assert(list.head.next.next.value == 1)
end

function test_data_structure_linkedList_insertBetween_Nodes_previous()
    local list = linkedList()
    list.setHead(0)
    list.setPrevious(1)
    list.insertPrevious(2)
    assert(list.head.value == 0)
    assert(list.head.previous.value == 2)
    assert(list.head.previous.previous.value == 1)
end
