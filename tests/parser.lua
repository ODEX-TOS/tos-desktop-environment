local parser = require("tde.parser")

-- create a file with some data
local function create_file(location, value)
    file = io.open(location, "w")
    file:write(value)
    file:close()
end

-- WARNING: Be carefull with this function
-- It removes files for the filesystem
local function rm_file(location)
    os.remove(location)
end

function test_config_parser_exists()
    assert(parser)
    assert(type(parser) == "function")
end

function test_config_parser_works_single_value()
    create_file("test.conf","value=1")
    local result = parser("test.conf")
    assert(result["value"] == "1")
    rm_file("test.conf")
end

function test_config_parser_works_multi_value()
    create_file("test.conf","value=1\nvalue2=2")
    local result = parser("test.conf")
    assert(result["value"] == "1")
    assert(result["value2"] == "2")
    rm_file("test.conf")
end

function test_config_parser_works_spacing()
    create_file("test.conf","value =1\nvalue2= 2")
    local result = parser("test.conf")
    assert(result["value"] == "1")
    assert(result["value2"] == "2")
    rm_file("test.conf")
end

function test_config_parser_works_newlines()
    create_file("test.conf","value =1\n\nvalue2= 2")
    local result = parser("test.conf")
    assert(result["value"] == "1")
    assert(result["value2"] == "2")
    rm_file("test.conf")
end

function test_config_parser_works_quotes()
    create_file("test.conf","value = 'abc'")
    local result = parser("test.conf")
    assert(result["value"] == "abc")
    rm_file("test.conf")
end

function test_config_parser_works_dubble_quotes()
    create_file("test.conf",'value = "abc"')
    local result = parser("test.conf")
    assert(result["value"] == "abc")
    rm_file("test.conf")
end

function test_config_parser_comments()
    create_file("test.conf",'# this is a comment\nvalue = "abc"')
    local result = parser("test.conf")
    assert(result["value"] == "abc")
    rm_file("test.conf")
end

function test_config_parser_comments_behind_values()
    create_file("test.conf",'value = "abc" # this is a comment')
    local result = parser("test.conf")
    assert(result["value"] == "abc")
    rm_file("test.conf")
end

function test_config_parser_edge_cases()
    local result = parser("doesn.exist")
    assert(result)
    -- check to see if it is empty
    assert(next(result) == nil)
end

function test_config_parser_edge_cases_2()
    local result = parser("")
    assert(result)
    -- check to see if it is empty
    assert(next(result) == nil)
end

function test_config_parser_edge_cases_3()
    local result = parser(nil)
    assert(result)
    -- check to see if it is empty
    assert(next(result) == nil)
end

function test_config_parser_edge_cases_4()
    local result = parser(123)
    assert(result)
    -- check to see if it is empty
    assert(next(result) == nil)
end