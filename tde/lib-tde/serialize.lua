---------------------------------------------------------------------------
-- Serialize lua objects (tables) into a string and back
--
-- You can easily convert lua objects into a serialized representation
-- This is usefull for storing and restoring lua objects
--
--    serialize({1,2,3, {hello="world"}}) -- becomes "[1,2,3, {hello='world'}]" (string)
--    deserialize("[1,2,3, {hello='world'}]") -- becomes {1,2,3, {hello="world"}} (table)
--
-- You can also save this data to a file
--   serialize_to_file("file.json", {1,2,3}) -- serialize the data and send it to the file
--   deserialize_from_file("file.json") -- returns {1,2,3}
--
-- This module tries to improve reusage of know variables throughout the tde infrastructure.
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.serialize
---------------------------------------------------------------------------

local json = require("cjson")
local filehandle = require("lib-tde.file")

--- Serialize tables into a string representation
-- @tparam table tbl the table to serialize
-- @return string The serialized representation of the lua object
-- @staticfct serialize
-- @usage -- returns "[1,2,3,4, {hello='world'}]"
-- lib-tde.serialize.serialize({1,2,3,4, {hello='world'}})
local function serialize(tbl)
    return json.encode(tbl)
end

--- Deserialize a string into a tables
-- @tparam string str The string to deserialize into lua tables
-- @return table The deserialized lua table
-- @staticfct deserialize
-- @usage -- returns {1,2,3,4, {hello='world'}}
-- lib-tde.serialize.deserialize("[1,2,3,4, {hello='world'}]")
local function deserialize(str)
    return json.decode(str)
end

--- Serialize table and save it to a file
-- @tparam table tbl the table to serialize
-- @staticfct serialize_to_file
-- @usage -- saves to file
-- lib-tde.serialize.serialize_to_file("file.json", {1,2,3,4, {hello='world'}})
local function serialize_to_file(file, str)
    local serialized = serialize(str)
    filehandle.overwrite(file, serialized)
end

--- Deserialize data found in a file
-- @tparam string file The path to the file to deserialize
-- @return table The deserialized lua table
-- @staticfct deserialize_from_file
-- @usage -- Deserializes the content found in the file to lua tables
-- local object = lib-tde.serialize.deserialize_from_file("file.json")
local function deserialize_from_file(file)
    local str = filehandle.string(file)
    return deserialize(str)
end

return {
    serialize = serialize,
    deserialize = deserialize,
    serialize_to_file = serialize_to_file,
    deserialize_from_file = deserialize_from_file
}
