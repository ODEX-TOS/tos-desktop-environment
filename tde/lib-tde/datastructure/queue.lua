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
-- Lua Implementation of a queue
--
-- This module describes the api usage of a queue (FIFO)
-- You can push items on the queue and pop them of the queue
--
--    local queue = require("lib-tde.datastructure.queue")
--    local list = queue()
--    list.push("first")
--    list.push("second")
--    list.pop() -- returns "first"
--    list.pop() -- returns "second"
--
--    list.next() -- returns the next element without removing it
--    list.size() -- returns the size of the queue
--
-- Time complexity:
--
-- * `Insert element`    O(1)
-- * `Remove element`    O(1)
-- * `List size`         O(1)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.datastructure.queue
---------------------------------------------------------------------------

local linkedList = require("lib-tde.datastructure.linkedList")

--- Create a new Queue
-- @treturn table An empty queue
-- @staticfct lib-tde.datastrucuture.queue
-- @usage -- This will create a new queue
-- lib-tde.datastrucuture.queue()
local function genList()
    local list = {}

    local _queue = linkedList()
    local _queue_size = 0
    local tail = _queue.head

    --- Add a new object to the queue
    -- @tparam object value The value to put into the queue
    -- @staticfct lib-tde.datastrucuture.queue.push
    -- @usage -- Add the string 'tde' to the queue
    -- queue.push("tde")
    list.push = function(value)
        if _queue_size == 0 then
            _queue.setHead(value)
        else
            tail.next = {
                previous = tail,
                value = value,
                next = {
                    previous = tail.next,
                    value = nil,
                    next = nil
                }
            }
            tail = tail.next
        end
        _queue_size = _queue_size + 1
    end

    --- Remove the next object in the queue and return it
    -- @returns object The object that is next in line in the queue
    -- @staticfct lib-tde.datastrucuture.queue.pop
    -- @usage -- Return 'tde' from the queue
    -- queue.pop()
    list.pop = function()
        if _queue_size < 1 then
            return
        end
        _queue_size = _queue_size - 1
        local poppedValue = _queue.head.value
        _queue.next()
        _queue.removePrevious()
        return poppedValue
    end

    --- This function is like @see pop however it doesn't remove the element from the queue
    -- @returns object The object that is next in line in the queue
    -- @staticfct lib-tde.datastrucuture.queue.next
    -- @usage -- Return 'tde' from the queue
    -- queue.next()
    list.next = function()
        return _queue.head.value
    end

    --- This function returns the amount of elements in the queue
    -- @returns number The amount of objects in the queue
    -- @staticfct lib-tde.datastrucuture.queue.size
    -- @usage -- Return the size of the queue
    -- queue.size()
    list.size = function()
        return _queue_size
    end

    return list
end

return genList
