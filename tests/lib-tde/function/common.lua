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

function test_function_sleep_exists()
    assert(common.sleep)
    assert(type(common.sleep) == "function")
end

function test_function_num_to_si_prefix_fault()
    assert(common.num_to_si_prefix() == nil)
    assert(common.num_to_si_prefix("") == 0)
    assert(common.num_to_si_prefix("abc") == 0)
end

function test_function_num_to_si_prefix_corrrect_si_unites_kilo()
    assert(common.num_to_si_prefix(1000) == "1.0k")
    assert(common.num_to_si_prefix(2000) == "2.0k")
    assert(common.num_to_si_prefix(5000) == "5.0k")
    assert(common.num_to_si_prefix(5500) == "5.5k")
end

function test_function_num_to_si_prefix_corrrect_si_unites_mega()
    assert(common.num_to_si_prefix(1000000) == "1.0M")
    assert(common.num_to_si_prefix(2000000) == "2.0M")
    assert(common.num_to_si_prefix(5000000) == "5.0M")
    assert(common.num_to_si_prefix(5500000) == "5.5M")
end

function test_function_num_to_si_prefix_corrrect_si_unites_giga()
    assert(common.num_to_si_prefix(1000000000) == "1.0G")
    assert(common.num_to_si_prefix(2000000000) == "2.0G")
    assert(common.num_to_si_prefix(5000000000) == "5.0G")
    assert(common.num_to_si_prefix(5500000000) == "5.5G")
end

function test_function_num_to_si_prefix_corrrect_si_unites_terra()
    assert(common.num_to_si_prefix(1000000000000) == "1.0T")
    assert(common.num_to_si_prefix(2000000000000) == "2.0T")
    assert(common.num_to_si_prefix(5000000000000) == "5.0T")
    assert(common.num_to_si_prefix(5500000000000) == "5.5T")
end

function test_function_num_to_si_prefix_corrrect_si_unites_petta()
    assert(common.num_to_si_prefix(1000000000000000) == "1.0P")
    assert(common.num_to_si_prefix(2000000000000000) == "2.0P")
    assert(common.num_to_si_prefix(5000000000000000) == "5.0P")
    assert(common.num_to_si_prefix(5500000000000000) == "5.5P")
end

function test_function_num_to_si_prefix_corrrect_si_unites_offset()
    assert(common.num_to_si_prefix(8700) == "8.7k")
    assert(common.num_to_si_prefix(8700, 1) == "8.7M")
    assert(common.num_to_si_prefix(8700, 2) == "8.7G")
    assert(common.num_to_si_prefix(8700, 3) == "8.7T")
    assert(common.num_to_si_prefix(8700, 4) == "8.7P")
end

function test_function_bytes_to_grandness_fault()
    assert(common.bytes_to_grandness() == nil)
    assert(common.bytes_to_grandness("") == "0B")
    assert(common.bytes_to_grandness("abc") == "0B")
end

function test_function_bytes_to_grandness_corrrect_si_unites_kilo()
    assert(common.bytes_to_grandness(1000) == "1.0kB")
    assert(common.bytes_to_grandness(2000) == "2.0kB")
    assert(common.bytes_to_grandness(5000) == "5.0kB")
    assert(common.bytes_to_grandness(5500) == "5.5kB")
end

function test_function_bytes_to_grandness_corrrect_si_unites_mega()
    assert(common.bytes_to_grandness(1000000) == "1.0MB")
    assert(common.bytes_to_grandness(2000000) == "2.0MB")
    assert(common.bytes_to_grandness(5000000) == "5.0MB")
    assert(common.bytes_to_grandness(5500000) == "5.5MB")
end

function test_function_bytes_to_grandness_corrrect_si_unites_giga()
    assert(common.bytes_to_grandness(1000000000) == "1.0GB")
    assert(common.bytes_to_grandness(2000000000) == "2.0GB")
    assert(common.bytes_to_grandness(5000000000) == "5.0GB")
    assert(common.bytes_to_grandness(5500000000) == "5.5GB")
end

function test_function_bytes_to_grandness_corrrect_si_unites_terra()
    assert(common.bytes_to_grandness(1000000000000) == "1.0TB")
    assert(common.bytes_to_grandness(2000000000000) == "2.0TB")
    assert(common.bytes_to_grandness(5000000000000) == "5.0TB")
    assert(common.bytes_to_grandness(5500000000000) == "5.5TB")
end

function test_function_bytes_to_grandness_corrrect_si_unites_petta()
    assert(common.bytes_to_grandness(1000000000000000) == "1.0PB")
    assert(common.bytes_to_grandness(2000000000000000) == "2.0PB")
    assert(common.bytes_to_grandness(5000000000000000) == "5.0PB")
    assert(common.bytes_to_grandness(5500000000000000) == "5.5PB")
end

function test_function_bytes_to_grandness_corrrect_si_unites_offset()
    assert(common.bytes_to_grandness(8700) == "8.7kB")
    assert(common.bytes_to_grandness(8700, 1) == "8.7MB")
    assert(common.bytes_to_grandness(8700, 2) == "8.7GB")
    assert(common.bytes_to_grandness(8700, 3) == "8.7TB")
    assert(common.bytes_to_grandness(8700, 4) == "8.7PB")
end
