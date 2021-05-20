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
-- Lua Implementation of a set
--
-- This module describes the api usage of a set (List with only unique elements)
-- You can add items to the set or remove them
--
--    local set = require("lib-tde.datastructure.set")
--    local list = set()
--    list.add("first")
--    list.add("second")
--    list.remove("first") -- returns true, to indicate that it exists
--    list.add("second") -- returns false, to indicate it already exists
--
--    list.to_list() -- Returns a plain lua list with all elements
--    list.to_ordered_list() -- returns a plain lua list with all elements, ordered in the way you put them in
--
-- Time complexity:
--
-- * `Insert element`    O(1)
-- * `Remove element`    O(1)
-- * `To List`           O(1)
-- * `To Ordered List`   O(1)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.datastructure.set
-- @supermodule table
---------------------------------------------------------------------------

--- Create a new Set (List with only unique values)
-- @treturn table An empty set
-- @staticfct lib-tde.datastrucuture.set
-- @usage -- This will create a new set
-- lib-tde.datastrucuture.set()
return function()
    local _set = {}
    -- a list representation of the current set
    local _list = {}
    local _index = 0


    --- Add an element to the set, if it was successfully added return true (didn't exist yet)
    -- @tparam object value The value to put into the set
    -- @staticfct lib-tde.datastrucuture.set.add
    -- @return boolean Returns true if a new element was inserted, false if it already exists
    -- @usage -- Add the string 'tde' to the set
    --   set.add("tde")
    local function _add(value)
        if _set[value] ~= nil then
            return false
        end
        _index = _index + 1
        _set[value] = _index
        table.insert(_list, value)
        return true
    end

    --- Remove an element from the set, if it was successfully removed return true
    -- @tparam object value The value to remove from the set
    -- @staticfct lib-tde.datastrucuture.set.remove
    -- @return boolean Returns true if the element was removed, false if it didn't exist
    -- @usage -- Remove the string 'tde' from the set
    --   set.remove("tde")
    local function _remove(value)
        if _set[value] ~= nil then
            table.remove(_list, _set[value])
            _set[value] = nil
            _index = _index - 1
            return true
        end
        return false
    end

    --- Convert the set to a regular lua list, in the order that you added the elements
    -- @staticfct lib-tde.datastrucuture.set.to_ordered_list
    -- @return table A regular lua list with elements in the order that you added them
    -- @usage
    --     local list = set.to_ordered_list()
    local function _to_ordered_list()
        return _list
    end

    --- Convert the set to a regular lua list
    -- @staticfct lib-tde.datastrucuture.set.to_list
    -- @return table A regular lua list
    -- @usage
    --     local list = set.to_list()
    local function _to_list()
        return _to_ordered_list()
    end

    --- Iterate over the set with an iterator (much like ipairs())
    -- @staticfct lib-tde.datastrucuture.set.iterate
    -- @return fun(t: table, i?: integer):integer, any iterator
    -- @return table t
    -- @return integer i
    -- @usage
    --   for index, value in set.iterate() do
    --    print("Index: " .. index)
    --    print("Value: " .. value)
    --   end
    local function _iterate()
        return ipairs(_to_ordered_list())
    end

    --- Check if an element exists in the set
    -- @tparam object value The value to find in the set
    -- @staticfct lib-tde.datastrucuture.set.exists
    -- @return boolean Returns true if the element exists
    -- @usage
    --   set.exists("tde")
    local function _exists(value)
        return _set[value] ~= nil
    end

    return {
        add = _add,
        remove = _remove,
        exists = _exists,
        iterate = _iterate,
        to_list = _to_list,
        to_ordered_list = _to_ordered_list
    }
end