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
local breakTimer = require("tde.lib-tde.function.datetime")

function test_break_timer_exists()
    assert(breakTimer, "The break timer api should exist")
    assert(type(breakTimer) == "table", "The break timer api should be a table")
end

function test_break_timer_props()
    assert(breakTimer.numberZeroPadding, "The break timer api should have a numberZeroPadding function")
    assert(type(breakTimer.numberZeroPadding) == "function", "The numberZeroPadding element should be a function")

    assert(breakTimer.numberInSecToMS, "The break timer api should have a numberInSecToMS function")
    assert(type(breakTimer.numberInSecToMS) == "function", "The numberInSecToMS element should be a function")

    assert(breakTimer.current_time_inbetween, "The break timer api should have a current_time_inbetween function")
    assert(
        type(breakTimer.current_time_inbetween) == "function",
        "The current_time_inbetween element should be a function"
    )

    assert(breakTimer.unit_test_split, "The break timer api should have a unit_test_split function")
    assert(type(breakTimer.unit_test_split) == "function", "The unit_test_split element should be a function")
end

function test_break_timer_zero_padding_1()
    assert(
        breakTimer.numberZeroPadding(1) == "01",
        "Padding the number '1' should give '01'  but got: '" .. breakTimer.numberZeroPadding(1) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(2) == "02",
        "Padding the number '2' should give '02'  but got: '" .. breakTimer.numberZeroPadding(2) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(3) == "03",
        "Padding the number '3' should give '03'  but got: '" .. breakTimer.numberZeroPadding(3) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(4) == "04",
        "Padding the number '4' should give '04'  but got: '" .. breakTimer.numberZeroPadding(4) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(5) == "05",
        "Padding the number '5' should give '05'  but got: '" .. breakTimer.numberZeroPadding(5) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(6) == "06",
        "Padding the number '6' should give '06'  but got: '" .. breakTimer.numberZeroPadding(6) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(7) == "07",
        "Padding the number '7' should give '07'  but got: '" .. breakTimer.numberZeroPadding(7) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(8) == "08",
        "Padding the number '8' should give '08'  but got: '" .. breakTimer.numberZeroPadding(8) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(9) == "09",
        "Padding the number '9' should give '09'  but got: '" .. breakTimer.numberZeroPadding(9) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(10) == "10",
        "Padding the number '10' should give '10'  but got: '" .. breakTimer.numberZeroPadding(10) .. "'"
    )
end

function test_break_timer_zero_padding_special_cases()
    assert(
        breakTimer.numberZeroPadding(-1) == "-1",
        "Padding of the negative number '-1' shoud return '-1' but got: '" .. breakTimer.numberZeroPadding(-1) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(-20) == "-20",
        "Padding of the negative number '-20' shoud return '-20' but got: '" .. breakTimer.numberZeroPadding(-1) .. "'"
    )

    assert(breakTimer.numberZeroPadding() == "00", "Empty input should result in 00")
    assert(breakTimer.numberZeroPadding("") == "00", "Empty input should result in 00")
    assert(breakTimer.numberZeroPadding(nil) == "00", "Empty input should result in 00")
end

function test_break_timer_zero_padding_big_cases()
    assert(
        breakTimer.numberZeroPadding(10) == "10",
        "Padding the number '10' should give '10'  but got: '" .. breakTimer.numberZeroPadding(10) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(35) == "35",
        "Padding the number '35' should give '35'  but got: '" .. breakTimer.numberZeroPadding(35) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(134) == "134",
        "Padding the number '134' should give '134'  but got: '" .. breakTimer.numberZeroPadding(134) .. "'"
    )
    assert(
        breakTimer.numberZeroPadding(60) == "60",
        "Padding the number '60' should give '60'  but got: '" .. breakTimer.numberZeroPadding(60) .. "'"
    )
end

function test_break_timer_number_sec_to_MS()
    assert(
        breakTimer.numberInSecToMS(0) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(breakTimer.numberInSecToMS(0)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(1) == "00:01",
        "The result should be '00:01' but got: '" .. tostring(breakTimer.numberInSecToMS(1)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(10) == "00:10",
        "The result should be '00:10' but got: '" .. tostring(breakTimer.numberInSecToMS(10)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(35) == "00:35",
        "The result should be '00:35' but got: '" .. tostring(breakTimer.numberInSecToMS(35)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(60) == "01:00",
        "The result should be '01:00' but got: '" .. tostring(breakTimer.numberInSecToMS(60)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(120) == "02:00",
        "The result should be '02:00' but got: '" .. tostring(breakTimer.numberInSecToMS(120)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(140) == "02:20",
        "The result should be '02:20' but got: '" .. tostring(breakTimer.numberInSecToMS(140)) .. "'"
    )
end

function test_break_timer_number_sec_to_MS_edge_cases()
    assert(
        breakTimer.numberInSecToMS(-1) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(breakTimer.numberInSecToMS(-1)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(-100) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(breakTimer.numberInSecToMS(-100)) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS("") == "00:00",
        "The result should be '00:00' but got: '" .. tostring(breakTimer.numberInSecToMS("")) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS("100") == "00:00",
        "The result should be '00:00' but got: '" .. tostring(breakTimer.numberInSecToMS("100")) .. "'"
    )
    assert(
        breakTimer.numberInSecToMS(nil) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(breakTimer.numberInSecToMS(nil)) .. "'"
    )
end

function test_break_timer_split()
    assert(breakTimer.unit_test_split("abc;def", ";")[1] == "abc", "Splitting resulting in the wrong location")
    assert(breakTimer.unit_test_split("abc;def", ";")[2] == "def", "Splitting resulting in the wrong location")
    assert(breakTimer.unit_test_split("abc;def", ",")[1] == "abc;def", "Splitting resulting in the wrong location")
    assert(breakTimer.unit_test_split("", ";")[1] == "", "Splitting on empty lines failed")
    assert(breakTimer.unit_test_split("abc", "")[1] == "abc", "Splitting resulting in the wrong location")
end

function test_break_timer_split_edge_cases()
    assert(breakTimer.unit_test_split(123, 123) == nil, "Splitting on number is not allowed")
    assert(breakTimer.unit_test_split({}, {}) == nil, "Splitting on tables is not allowed")
    assert(breakTimer.unit_test_split(123, ";") == nil, "Splitting on numbers is not allowed")
    assert(
        breakTimer.unit_test_split("123", nil)[1] == "123",
        "Result should be '123' but got: " .. tostring(breakTimer.unit_test_split("123", nil)[1])
    )
end

function test_break_timer_current_time_inbetween()
    assert(
        breakTimer.current_time_inbetween(
            "10:00",
            "11:00",
            {
                min = 30,
                hour = 10
            }
        ),
        "The time 10:30 should be inbetween 10:00 and 11:00"
    )

    assert(
        not breakTimer.current_time_inbetween(
            "10:00",
            "11:00",
            {
                min = 30,
                hour = 11
            }
        ),
        "The time 11:30 shouldn't be inbetween 10:00 and 11:00"
    )

    assert(
        breakTimer.current_time_inbetween("10:00", "11:00", os.date("*t")) ==
            breakTimer.current_time_inbetween("10:00", "11:00"),
        "Make sure the break timer gets the correct time"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_1()
    assert(
        not breakTimer.current_time_inbetween(
            100,
            "11:00",
            {
                min = 30,
                hour = 10
            }
        ),
        "The time 10:30 shouldn't be inbetween 100 and 11:00 (100 is invalid)"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_2()
    assert(
        not breakTimer.current_time_inbetween(
            100,
            100,
            {
                min = 30,
                hour = 10
            }
        ),
        "The time 10:30 should be inbetween 100 and 100 (100 is invalid)"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_3()
    assert(
        not breakTimer.current_time_inbetween(
            "10:00",
            100,
            {
                min = 30,
                hour = 10
            }
        ),
        "The time 10:30 shouldn't be inbetween 10:00 and 100 (100 is invalid)"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_4()
    assert(
        not breakTimer.current_time_inbetween(
            "10",
            "11:00",
            {
                min = 30,
                hour = 10
            }
        ),
        "The time 10:30 shouldn't be inbetween 10 and 11:00 (10 is invalid)"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_5()
    assert(
        not breakTimer.current_time_inbetween(
            "10",
            "11:00",
            {
                min = 0,
                hour = 10
            }
        ),
        "The time 10:00 should be inbetween 10 and 21:00 (10 is invalid)"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_6()
    assert(
        not breakTimer.current_time_inbetween(
            "-10:00",
            "11:00",
            {
                min = 30,
                hour = 10
            }
        ),
        "The time 10:30 shouldn't be inbetween -10:00 and 11:00 (-10 is invalid)"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_7()
    assert(
        breakTimer.current_time_inbetween(
            "23:00",
            "24:00",
            {
                min = 59,
                hour = 23
            }
        ),
        "The time 23:59 should be inbetween 23:00 and 24:00"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_8()
    assert(
        not breakTimer.current_time_inbetween(
            "25:00",
            "26:00",
            {
                min = 50,
                hour = 25
            }
        ),
        "The time 25:50 shouldn't be inbetween 25:00 and 26:00"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_9()
    assert(
        breakTimer.current_time_inbetween(
            "00:00",
            "24:00",
            {
                min = 50,
                hour = 18
            }
        ),
        "The time 18:50 should be inbetween 00:00 and 24:00"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_10()
    assert(
        breakTimer.current_time_inbetween(
            "00:00",
            "24:00",
            {
                min = 2,
                hour = 3
            }
        ),
        "The time 3:02 should be inbetween 00:00 and 24:00"
    )
end
