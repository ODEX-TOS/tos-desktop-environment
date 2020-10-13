local common = require("tde.lib-tde.function.common")

function test_function_split()
    assert(common.split("abc;def", ";")[1] == "abc")
    assert(common.split("abc;def", ";")[2] == "def")
    assert(common.split("abc;def", ",")[1] == "abc;def")
    assert(common.split("", ";")[1] == "")
    assert(common.split("abc", "")[1] == "abc")
end

function test_function_split_edge_cases()
    assert(common.split(123, 123) == nil)
    assert(common.split({}, {}) == nil)
    assert(common.split(123, ";") == nil)
    assert(common.split("123", nil)[1] == "123")
end