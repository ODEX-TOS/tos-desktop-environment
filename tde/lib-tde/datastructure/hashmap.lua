---------------------------------------------------------------------------
-- Crude implementation of a hashmap
--
-- Lua by default already ships a hasmap (called a table)
-- This file is a wrapper for lua's hashmap, intended for people who come from object oriented languages
-- This api provides easy to use functions with which most people are familiar
--
-- Time complexity:
--
-- * `Lookup element`    O(n) (worst case) on average O(1)
-- * `Insert element`    O(n) (worst case) on average O(1)
-- * `Remove element`    O(n) (worst case) on average O(1)
-- * `update element`    O(n) (worst case) on average O(1)
--
-- Usually the complexity is O(1) unless hash collisions happen then it could be O(x) with a max of O(n)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.datastructure.hashmap
---------------------------------------------------------------------------

--- Create a new hashmap
-- @treturn table A table containing the hashmap methods
-- @staticfct lib-tde.datastrucuture.hashmap
-- @usage -- This will create a new empty hashmap
-- lib-tde.datastrucuture.hashmap()
return function()
    local _data = {}

    --- Add a key value pair to the hashmap
    -- @tparam string key The key used to identify the value
    -- @tparam object value Any possible object that can be hold in the hashmap (string, number, table, etc)
    -- @staticfct lib-tde.datastrucuture.hashmap.add
    -- @usage -- Add the string hello to the key tde
    -- hashmap.add("tde", "hello")
    local function _add(key, value)
        _data[key] = value
    end

    --- Delete a key from the hashmap
    -- @tparam string key The key used to identify the value
    -- @staticfct lib-tde.datastrucuture.hashmap.delete
    -- @usage -- Remove the key tde from the hashmap in case it exists
    -- hashmap.delete("tde")
    local function _delete(key)
        _data[key] = nil
    end

    --- Get a key from the hashmap
    -- @tparam string key The key used to identify the value
    -- @staticfct lib-tde.datastrucuture.hashmap.get
    -- @usage -- Return the value of the key, if it doesn't exist return nil
    -- hashmap.get("tde") -- returns "hello"
    local function _get(key)
        return _data[key]
    end

    return {
        add = _add,
        delete = _delete,
        get = _get
    }
end
