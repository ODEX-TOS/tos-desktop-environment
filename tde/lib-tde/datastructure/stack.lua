---------------------------------------------------------------------------
-- Lua Implementation of a stack
-- This module describes the api usage of a stack (LIFO)
-- You can push items on the stack and pop them of the stack
--
--    local stack = require("lib-tde.datastructure.stack")
--    local list = stack()
--    list.push("first")
--    list.push("second")
--    list.pop() -- returns "first"
--    list.pop() -- returns "second"
--
--    list.next() -- returns the next element without removing it
--    list.size() -- returns the size of the stack
--
-- Time complexity:
--  * Insert element    O(1)
--  * Remove element    O(1)
--  * List size         O(1)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.datastructure.stack
---------------------------------------------------------------------------

--- Create a new Stack
-- @treturn table An empty stack
-- @staticfct lib-tde.datastrucuture.stack
-- @usage -- This will create a new stack
-- lib-tde.datastrucuture.stack()
function genList()
    local list = {}

    local _stack = {}

    --- Add a new object to the stack
    -- @tparam object value The value to put into the stack
    -- @staticfct lib-tde.datastrucuture.stack.push
    -- @usage -- Add the string 'tde' to the stack
    -- stack.push("tde")
    list.push = function(value)
        _stack[#_stack + 1] = value
    end

    --- Remove the next object in the stack and return it
    -- @returns object The object that is next in line in the stack
    -- @staticfct lib-tde.datastrucuture.stack.pop
    -- @usage -- Return 'tde' from the stack
    -- stack.pop()
    list.pop = function()
        local res = _stack[#_stack]
        _stack[#_stack] = nil
        return res
    end

    --- This function is like @see pop however it doesn't remove the element from the stack
    -- @returns object The object that is next in line in the stack
    -- @staticfct lib-tde.datastrucuture.stack.next
    -- @usage -- Return 'tde' from the stack
    -- stack.next()
    list.next = function()
        return _stack[#_stack]
    end

    --- This function returns the amount of elements in the stack
    -- @returns number The amount of objects in the stack
    -- @staticfct lib-tde.datastrucuture.stack.size
    -- @usage -- Return the size of the stack
    -- stack.size()
    list.size = function()
        return #_stack
    end

    return list
end

return genList
