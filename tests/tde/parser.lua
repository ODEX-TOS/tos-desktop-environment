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
local parser = require("tde.parser")

-- create a file with some data
local function create_file(location, value)
    file = io.open(location, "w")
    file:write(value)
    file:close()
end

-- WARNING: Be careful with this function
-- It removes files for the filesystem
local function rm_file(location)
    os.remove(location)
end

function Test_config_parser_exists()
    assert(parser, "Make sure the config parser exists")
    assert(type(parser) == "function", "Make sure the api of the config parser is correct")
end

function Test_config_parser_works_single_value()
    create_file("test.conf", "value=1")
    local result = parser("test.conf")
    assert(result["value"] == "1", "Parsing 'value' should be 1 but got " .. tostring(result["value"]))
    rm_file("test.conf")
end

function Test_config_parser_works_multi_value()
    create_file("test.conf", "value=1\nvalue=2")
    local result = parser("test.conf")
    assert(result["value"][1] == "1", "Parsing 'value' should be 1 but got " .. tostring(result["value"][1]))
    assert(result["value"][2] == "2", "Parsing second 'value' should be 2 but got " .. tostring(result["value"][2]))
    rm_file("test.conf")
end

function Test_config_parser_works_spacing()
    create_file("test.conf", "value =1\nvalue= 2")
    local result = parser("test.conf")
    assert(result["value"][1] == "1", "Parsing 'value' should be 1 but got " .. tostring(result["value"][1]))
    assert(result["value"][2] == "2", "Parsing second 'value' should be 2 but got " .. tostring(result["value"][2]))
    rm_file("test.conf")
end

function Test_config_parser_works_newlines()
    create_file("test.conf", "value =1\n\nvalue= 2")
    local result = parser("test.conf")
    assert(result["value"][1] == "1", "Parsing 'value' should be 1 but got " .. tostring(result["value"][1]))
    assert(result["value"][2] == "2", "Parsing second 'value' should be 2 but got " .. tostring(result["value"][2]))
    rm_file("test.conf")
end

function Test_config_parser_works_quotes()
    create_file("test.conf", "value = 'abc'")
    local result = parser("test.conf")
    assert(result["value"] == "abc", "Parsing 'value' should be 'abc' but got " .. tostring(result["value"]))
    rm_file("test.conf")
end

function Test_config_parser_works_dubble_quotes()
    create_file("test.conf", 'value = "abc"')
    local result = parser("test.conf")
    assert(result["value"] == "abc", "Parsing 'value' should be 'abc' but got " .. tostring(result["value"]))
    rm_file("test.conf")
end

function Test_config_parser_comments()
    create_file("test.conf", '# this is a comment\nvalue = "abc"')
    local result = parser("test.conf")
    assert(result["value"] == "abc", "Parsing 'value' should be 'abc' but got " .. tostring(result["value"]))
    rm_file("test.conf")
end

function Test_config_parser_comments_behind_values()
    create_file("test.conf", 'value = "abc" # this is a comment')
    local result = parser("test.conf")
    assert(result["value"] == "abc", "Parsing 'value' should be 'abc' but got " .. tostring(result["value"]))
    rm_file("test.conf")
end

function Test_config_parser_single_value_is_no_list_multi_value_is_list()
    create_file("test.conf", 'value = "abc" # this is a comment')
    local result = parser("test.conf")
    assert(type(result["value"]) == "string", "result should be a string but is: " .. type(result["value"]))
    assert(result["value"] == "abc", "Parsing 'value' should be 'abc' but got " .. tostring(result["value"]))
    rm_file("test.conf")

    create_file("test.conf", 'value = "abc" # this is a comment\nvalue = "abc2"')
    result = parser("test.conf")
    assert(type(result["value"]) == "table", "result should be a table")
    assert(result["value"][1] == "abc", "Parsing 'value' should be 'abc' but got " .. tostring(result["value"][1]))
    assert(result["value"][2] == "abc2", "Parsing 'value' should be 'abc' but got " .. tostring(result["value"][2]))
    rm_file("test.conf")
end

function Test_config_parser_edge_cases()
    local result = parser("doesn.exist")
    assert(result, "Parsing a file that doesn't exist should yield an empty table")
    -- check to see if it is empty
    assert(next(result) == nil, "Parsed table is not empty")
end

function Test_config_parser_edge_cases_2()
    local result = parser("")
    assert(result, "Parsing a file that doesn't exist should yield an empty table")
    -- check to see if it is empty
    assert(next(result) == nil, "Parsed table is not empty")
end

function Test_config_parser_edge_cases_3()
    local result = parser(nil)
    assert(result, "Parsing a file that doesn't exist should yield an empty table")
    -- check to see if it is empty
    assert(next(result) == nil, "Parsed table is not empty")
end

function Test_config_parser_edge_cases_4()
    local result = parser(123)
    assert(result, "Parsing a file that doesn't exist should yield an empty table")
    -- check to see if it is empty
    assert(next(result) == nil, "Parsed table is not empty")
end
