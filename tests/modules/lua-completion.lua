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
require("tde.module.lua-completion")

completion_table = {
    a = 'hello',
    b = 'world'
}

function __return_input(input)
    return input
end


function test_lua_completion_api()
    assert(get_completion ~= nil, "The global get_completion function is needed to be exposed to the tde-client")
    assert(type(get_completion) == "function", "The global get_completion function should be a function but is: " .. type(get_completion))
end

function test_lua_completion_string()
    local res = get_completion(completion_table, 'completion_table')
    local res2 = get_completion('completion_table')
    assert(res == res2, "get_completion doesn't support string and table representation\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_table()
    -- depending on the hash function they can be flipped
    local str=[[completion_table.a
completion_table.b
]]
    -- depending on the hash function they can be flipped
    local str2=[[completion_table.b
completion_table.a
]]

    local res = get_completion('completion_table')
    assert(res == str or res == str2, "get_completion Invalid generated completion\n Got: " .. tostring(res) .. '\nBut expected: ' .. str)
end

function test_lua_completion_global()
    local res = get_completion(_G, '_G')
    local res2 = get_completion(_G)
    assert(res == res2, "get_completion global(_G) completion\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_empty_is_global()
    local res = get_completion(_G, '_G')
    local res2 = get_completion()
    assert(res == res2, "get_completion global(_G) completion\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_empty_is_prefix()
    local res = get_completion(_G, '_G')
    local res2 = get_completion()
    assert(res == res2, "get_completion global(_G) completion\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_function_opening_brace()
    local res = get_completion('__return_input(')
    local res2 = get_completion('__return_input')
    assert(res == res2, "Getting autocomplete for an unfinished function is not working\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end


function test_lua_completion_function_opening_brace_with_half_string_param()
    local res = get_completion('__return_input("string')
    local res2 = get_completion('__return_input')
    assert(res == res2, "Getting autocomplete for an unfinished function is not working\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_function_opening_brace_with_a_full_string_param()
    local res = get_completion('__return_input("string"')
    local res2 = get_completion('__return_input')
    assert(res == res2, "Getting autocomplete for an unfinished function is not working\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_function_result()
    local res = get_completion('__return_input("completion_table")')
    local res2 = get_completion(__return_input(completion_table), 'completion_table')
    assert(res == res2, "Getting autocomplete for an unfinished function is not working\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_function_nested_calls()
    local res = get_completion('__return_input(__return_input(completion_table)')
    local res2 = get_completion(__return_input)
    assert(res == res2, "Getting autocomplete for an unfinished function is not working\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end

function test_lua_completion_ending_in_dot()
    local res = get_completion(_G, '_G')
    local res2 = get_completion(_G, '_G.')
    assert(res == res2, "Ending in . doesn't autocomplete correctly\n Got: " .. tostring(res2) .. '\nBut expected: ' .. tostring(res))
end
