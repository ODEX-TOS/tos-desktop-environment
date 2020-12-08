local serialize = require("lib-tde.serialize")

function test_serialize_api()
    assert(type(serialize.deserialize) == "function")
    assert(type(serialize.serialize) == "function")
    assert(type(serialize.serialize_to_file) == "function")
    assert(type(serialize.deserialize_from_file) == "function")
end

function test_serialize_basic_usage()
    local table = {1, 2, 3}
    local result = serialize.serialize(table)
    local deserialized = serialize.deserialize(result)
    assert(serialize.serialize(deserialized) == result)
end

function test_serialize_basic_usage_2()
    local table = {a = "a", b = "b", c = "c"}
    local result = serialize.serialize(table)
    local deserialized = serialize.deserialize(result)
    assert(serialize.serialize(deserialized) == result)
end
