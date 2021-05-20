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
-- Lua Implementation of a double linked list
--
-- This module describes the api usage of the double linked list
-- You can traverse the list in both directions, add items, remove items etc
--
--    local linkedList = require("lib-tde.datastructure.linkedList")
--    local list = linkedList()
--    list.setHead("This is the value of head")
--    for i = 1, 50 do
--         -- set the value of next
--         list.setNext(i)
--         -- traverse the list
--         list.next()
--    end
--    -- this prints out 50
--    print(list.head.value)
--
--    -- this prints out 49
--    print(list.head.previous.value)
--    -- this prints out 48
--    print(list.head.previous.previous.value)
--
-- Alternatively you can do the same with previous
--
--    local linkedList = require("lib-tde.datastructure.linkedList")
--    local list = linkedList()
--    list.setHead("This is the value of head")
--    for i = 1, 50 do
--         -- set the value of next
--         list.setPrevious(i)
--         -- traverse the list
--         list.previous()
--    end
--
-- Time complexity:
--
-- * `Lookup element`    O(n)
-- * `Insert element`    O(1)
-- * `Remove element`    O(1)
-- * `update element`    0(1)
--
-- Linked lists are extremely good to update values and read them
-- They are however bad at searching/traversing lists
--
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.datastructure.linkedList
-- @supermodule table
---------------------------------------------------------------------------

--- Create a new Double Linked List
-- @treturn table An empty linked list
-- @staticfct lib-tde.datastrucuture.linkedList
-- @usage -- This will create a new empty linked list
-- lib-tde.datastrucuture.linkedList()
local function genList()
    local list = {}

    --- The current pointer in the linked list
    -- @property head
    -- @param table
    list.head = {
        --- The next pointer in the linked list
        -- @property head.next
        -- @param table
        next = {
            value = nil
        },
        --- The previous pointer in the linked list
        -- @property head.previous
        -- @param table
        previous = {
            value = nil
        },
        --- The value that is stored in the linked list
        -- @property head.value
        -- @param object
        value = nil
    }

    -- functions to implement behavior of the linked list

    --- Update the value of the current head to value
    -- @tparam object value The value to put into the head
    -- @staticfct lib-tde.datastrucuture.linkedList.setHead
    -- @usage -- update the value of head to value
    -- linkedList.setHead("tde") -- updates list.head.value
    list.setHead = function(value)
        list.head.value = value
    end

    --- Update the value of the next object in the list (create on if it doesn't exist yet)
    -- @tparam object value The value to put into next
    -- @staticfct lib-tde.datastrucuture.linkedList.setNext
    -- @usage -- update the value of next to value
    -- linkedList.setNext("tde") -- updates list.head.next.value
    list.setNext = function(value)
        if list.head.next == nil then
            list.head.next = {
                previous = list.head,
                next = nil,
                value = value
            }
        end
        list.head.next.value = value
    end

    --- Update the value of the previous object in the list (create on if it doesn't exist yet)
    -- @tparam object value The value to put into previous
    -- @staticfct lib-tde.datastrucuture.linkedList.setPrevious
    -- @usage -- update the value of previous to value
    -- linkedList.setPrevious("tde") -- updates list.head.previous.value
    list.setPrevious = function(value)
        if list.head.previous == nil then
            list.head.previous = {
                previous = nil,
                next = list.head,
                value = value
            }
        end
        list.head.previous.value = value
    end

    --- Move the current pointer to the next value
    -- @staticfct lib-tde.datastrucuture.linkedList.next
    -- @usage -- Move head to the value of next
    -- linkedList.next() -- list.head is now list.head.next
    list.next = function()
        if list.head.next then
            list.head.next.previous = list.head
            list.head = list.head.next
        end
    end

    --- Move the current pointer to the previous value
    -- @staticfct lib-tde.datastrucuture.linkedList.previous
    -- @usage -- Move head to the value of previous
    -- linkedList.previous() -- list.head is now list.head.previous
    list.previous = function()
        if list.head.previous then
            list.head.previous.next = list.head
            list.head = list.head.previous
        end
    end

    --- Insert a new item in between list.head and list.head.next
    -- @tparam object value The value to put between head and next
    -- @staticfct lib-tde.datastrucuture.linkedList.insertNext
    -- @usage -- Insert a new item with value "tde" between list.head and list.head.next
    -- linkedList.insertNext("tde") -- updates list.head.next.value -> goes to list.head.next.next.value and list.head.next.value = "tde"
    list.insertNext = function(value)
        local oldNext = list.head.next
        list.head.next = {
            previous = list.head,
            next = oldNext,
            value = value
        }
    end

    --- Insert a new item in between list.head and list.head.previous
    -- @tparam object value The value to put between head and previous
    -- @staticfct lib-tde.datastrucuture.linkedList.insertPrevious
    -- @usage -- Insert a new item with value "tde" between list.head and list.head.previous
    -- linkedList.insertPrevious("tde") -- updates list.head.previous.value -> goes to list.head.previous.previous.value and list.head.previous.value = "tde"
    list.insertPrevious = function(value)
        local oldPrevious = list.head.previous
        list.head.previous = {
            next = list.head,
            previous = oldPrevious,
            value = value
        }
    end

    --- Remove the next value and replace it by list.head.next.next
    -- @staticfct lib-tde.datastrucuture.linkedList.removeNext
    -- @usage -- Remove the entry associated with list.head.next
    -- linkedList.removeNext() -- list.head.next becomes list.head.next.next
    list.removeNext = function()
        list.head.next = list.head.next.next
    end

    --- Remove the previous value and replace it by list.head.previous.previous
    -- @staticfct lib-tde.datastrucuture.linkedList.removePrevious
    -- @usage -- Remove the entry associated with list.head.previous
    -- linkedList.removePrevious() -- list.head.previous becomes list.head.previous.previous
    list.removePrevious = function()
        list.head.previous = list.head.previous.previous
    end

    return list
end

return genList
