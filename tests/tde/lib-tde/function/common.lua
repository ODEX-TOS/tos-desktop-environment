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
    assert(common.split("abc;def", ";")[1] == "abc", "Splitting text was wrong")
    assert(common.split("abc;def", ";")[2] == "def", "Splitting text was wrong")
    assert(common.split("abc;def", ",")[1] == "abc;def", "Splitting text was wrong")
    assert(common.split("", ";")[1] == "", "Splitting text was wrong")
    assert(common.split("abc", "")[1] == "abc", "Splitting text was wrong")
end

function test_function_split_edge_cases()
    assert(common.split(123, 123) == nil, "Splitting on numbers is not allowed")
    assert(common.split({}, {}) == nil, "Splitting on tables is not allowed")
    assert(common.split(123, ";") == nil, "Splitting on a number is not allowed")
    assert(common.split("123", nil)[1] == "123", "Splitting text was wrong")
end

function test_function_sleep_exists()
    assert(common.sleep, "Sleep function doesn't exist")
    assert(type(common.sleep) == "function", "Sleep is not a function")
end

function test_function_num_to_si_prefix_fault()
    assert(common.num_to_si_prefix() == nil, "num_to_si_prefix should take a number as an argument")
    assert(common.num_to_si_prefix("") == 0, "num_to_si_prefix should take a number as an argument")
    assert(common.num_to_si_prefix("abc") == 0, "num_to_si_prefix should take a number as an argument")
end

function test_function_num_to_si_prefix_corrrect_si_unites_kilo()
    assert(common.num_to_si_prefix(1000) == "1.0k", "Result should return a number in the kilo range")
    assert(common.num_to_si_prefix(2000) == "2.0k", "Result should return a number in the kilo range")
    assert(common.num_to_si_prefix(5000) == "5.0k", "Result should return a number in the kilo range")
    assert(common.num_to_si_prefix(5500) == "5.5k", "Result should return a number in the kilo range")
end

function test_function_num_to_si_prefix_corrrect_si_unites_mega()
    assert(common.num_to_si_prefix(1000000) == "1.0M", "Result should return a number in the mega range")
    assert(common.num_to_si_prefix(2000000) == "2.0M", "Result should return a number in the mega range")
    assert(common.num_to_si_prefix(5000000) == "5.0M", "Result should return a number in the mega range")
    assert(common.num_to_si_prefix(5500000) == "5.5M", "Result should return a number in the mega range")
end

function test_function_num_to_si_prefix_corrrect_si_unites_giga()
    assert(common.num_to_si_prefix(1000000000) == "1.0G", "Result should return a number in the giga range")
    assert(common.num_to_si_prefix(2000000000) == "2.0G", "Result should return a number in the giga range")
    assert(common.num_to_si_prefix(5000000000) == "5.0G", "Result should return a number in the giga range")
    assert(common.num_to_si_prefix(5500000000) == "5.5G", "Result should return a number in the giga range")
end

function test_function_num_to_si_prefix_corrrect_si_unites_terra()
    assert(common.num_to_si_prefix(1000000000000) == "1.0T", "Result should return a number in the terra range")
    assert(common.num_to_si_prefix(2000000000000) == "2.0T", "Result should return a number in the terra range")
    assert(common.num_to_si_prefix(5000000000000) == "5.0T", "Result should return a number in the terra range")
    assert(common.num_to_si_prefix(5500000000000) == "5.5T", "Result should return a number in the terra range")
end

function test_function_num_to_si_prefix_corrrect_si_unites_petta()
    assert(common.num_to_si_prefix(1000000000000000) == "1.0P", "Result should return a number in the peta range")
    assert(common.num_to_si_prefix(2000000000000000) == "2.0P", "Result should return a number in the peta range")
    assert(common.num_to_si_prefix(5000000000000000) == "5.0P", "Result should return a number in the peta range")
    assert(common.num_to_si_prefix(5500000000000000) == "5.5P", "Result should return a number in the peta range")
end

function test_function_num_to_si_prefix_corrrect_si_unites_offset()
    assert(common.num_to_si_prefix(8700) == "8.7k", "Result should be in the kilo range")
    assert(common.num_to_si_prefix(8700, 1) == "8.7M", "Result should be in the mega range")
    assert(common.num_to_si_prefix(8700, 2) == "8.7G", "Result should be in the giga range")
    assert(common.num_to_si_prefix(8700, 3) == "8.7T", "Result should be in the terra range")
    assert(common.num_to_si_prefix(8700, 4) == "8.7P", "Result should be in the petta range")
end

function test_function_bytes_to_grandness_fault()
    assert(common.bytes_to_grandness() == nil, "bytes_to_grandness should take a number as an argument")
    assert(common.bytes_to_grandness("") == "0B", "bytes_to_grandness should take a number as an argument")
    assert(common.bytes_to_grandness("abc") == "0B", "bytes_to_grandness should take a number as an argument")
end

function test_function_bytes_to_grandness_corrrect_si_unites_kilo()
    assert(common.bytes_to_grandness(1000) == "1.0kB", "Result should be in the kilobyte range")
    assert(common.bytes_to_grandness(2000) == "2.0kB", "Result should be in the kilobyte range")
    assert(common.bytes_to_grandness(5000) == "5.0kB", "Result should be in the kilobyte range")
    assert(common.bytes_to_grandness(5500) == "5.5kB", "Result should be in the kilobyte range")
end

function test_function_bytes_to_grandness_corrrect_si_unites_mega()
    assert(common.bytes_to_grandness(1000000) == "1.0MB", "Result should be in the megabyte range")
    assert(common.bytes_to_grandness(2000000) == "2.0MB", "Result should be in the megabyte range")
    assert(common.bytes_to_grandness(5000000) == "5.0MB", "Result should be in the megabyte range")
    assert(common.bytes_to_grandness(5500000) == "5.5MB", "Result should be in the megabyte range")
end

function test_function_bytes_to_grandness_corrrect_si_unites_giga()
    assert(common.bytes_to_grandness(1000000000) == "1.0GB", "Result should be in the gigabyte range")
    assert(common.bytes_to_grandness(2000000000) == "2.0GB", "Result should be in the gigabyte range")
    assert(common.bytes_to_grandness(5000000000) == "5.0GB", "Result should be in the gigabyte range")
    assert(common.bytes_to_grandness(5500000000) == "5.5GB", "Result should be in the gigabyte range")
end

function test_function_bytes_to_grandness_corrrect_si_unites_terra()
    assert(common.bytes_to_grandness(1000000000000) == "1.0TB", "Result should be in the terrabyte range")
    assert(common.bytes_to_grandness(2000000000000) == "2.0TB", "Result should be in the terrabyte range")
    assert(common.bytes_to_grandness(5000000000000) == "5.0TB", "Result should be in the terrabyte range")
    assert(common.bytes_to_grandness(5500000000000) == "5.5TB", "Result should be in the terrabyte range")
end

function test_function_bytes_to_grandness_corrrect_si_unites_petta()
    assert(common.bytes_to_grandness(1000000000000000) == "1.0PB", "Result should be in the petabyte range")
    assert(common.bytes_to_grandness(2000000000000000) == "2.0PB", "Result should be in the petabyte range")
    assert(common.bytes_to_grandness(5000000000000000) == "5.0PB", "Result should be in the petabyte range")
    assert(common.bytes_to_grandness(5500000000000000) == "5.5PB", "Result should be in the petabyte range")
end

function test_function_bytes_to_grandness_corrrect_si_unites_offset()
    assert(common.bytes_to_grandness(8700) == "8.7kB", "Result should be in the kilobyte range")
    assert(common.bytes_to_grandness(8700, 1) == "8.7MB", "Result should be in the megabyte range")
    assert(common.bytes_to_grandness(8700, 2) == "8.7GB", "Result should be in the gigabyte range")
    assert(common.bytes_to_grandness(8700, 3) == "8.7TB", "Result should be in the terrabyte range")
    assert(common.bytes_to_grandness(8700, 4) == "8.7PB", "Result should be in the petabyte range")
end

function test_function_num_to_str()
    assert(common.num_to_str(12.123) == "12.12", "Got: " .. common.num_to_str(12.123))
    assert(common.num_to_str(12.1234) == "12.12", "Got: " .. common.num_to_str(12.1234))
    assert(common.num_to_str(12.1234, 3) == "12.123", "Got: " .. common.num_to_str(12.1234, 3))
end

function test_function_num_to_str_high_precision()
    assert(common.num_to_str(12.123, 5) == "12.12300", "Got: " .. common.num_to_str(12.123, 5))
end

function test_function_num_to_str_wierd_inputs()
    assert(common.num_to_str("12") == "12", "Got: " .. common.num_to_str("12"))
    assert(common.num_to_str(nil) == "nil", "Got: " .. common.num_to_str(nil))
end

function test_common_function_screen_exists()
    assert(type(common.focused_screen) == "function", "the focussed screen api needs to exist and be a function")
end

function test_imagemagic_api_unit_tested()
    local amount = 4
    local result = tablelength(common)
    assert(
        result == amount,
        "You didn't test all common api endpoints, please add them then update the amount to: " .. result
    )
end
