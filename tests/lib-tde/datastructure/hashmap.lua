local hashmap = require("tde.lib-tde.datastructure.hashmap")

function test_data_structure_hashmap_basic_usage()
    local map = hashmap()
    assert(map.get("test") == nil)
    map.add("test", "hello")
    assert(map.get("test") == "hello")
end

function test_data_structure_hashmap_api_exists()
    local map = hashmap()
    assert(type(map.get) == "function")
    assert(type(map.add) == "function")
    assert(type(map.delete) == "function")
end

function test_data_structure_hashmap_delete_works()
    local map = hashmap()
    assert(map.get("test") == nil)
    map.add("test", "hello")
    assert(map.get("test") == "hello")
    map.delete("test")
    assert(map.get("test") == nil)
end

function test_data_structure_hashmap_add_a_lot_of_keys()
    local map = hashmap()
    for i = 0, 50 do
        map.add(tostring(i), tostring(i) .. " value")
    end
    for i = 0, 50 do
        assert(map.get(tostring(i)) == (tostring(i) .. " value"))
    end
end

function test_data_structure_hashmap_works_with_number_as_key()
    local map = hashmap()
    assert(map.get(1) == nil)
    map.add(1, "hello")
    assert(map.get(1) == "hello")
    map.delete(1)
    assert(map.get(1) == nil)
end

function test_data_structure_hashmap_works_with_negative_number_as_key()
    local map = hashmap()
    assert(map.get(-98) == nil)
    map.add(-98, "hello")
    assert(map.get(-98) == "hello")
    map.delete(-98)
    assert(map.get(-98) == nil)
end
