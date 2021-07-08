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
local datetime = require("tde.lib-tde.function.datetime")

function test_break_timer_exists()
    assert(datetime, "The break timer api should exist")
    assert(type(datetime) == "table", "The break timer api should be a table")
end

function test_break_timer_props()
    assert(datetime.numberZeroPadding, "The break timer api should have a numberZeroPadding function")
    assert(type(datetime.numberZeroPadding) == "function", "The numberZeroPadding element should be a function")

    assert(datetime.numberInSecToMS, "The break timer api should have a numberInSecToMS function")
    assert(type(datetime.numberInSecToMS) == "function", "The numberInSecToMS element should be a function")

    assert(datetime.numberInSecToHMS, "The break timer api should have a numberInSecToHMS function")
    assert(type(datetime.numberInSecToHMS) == "function", "The numberInSecToHMS element should be a function")

    assert(datetime.toSeconds, "The break timer api should have a toSeconds function")
    assert(type(datetime.toSeconds) == "function", "The toSeconds element should be a function")

    assert(datetime.current_time_inbetween, "The break timer api should have a current_time_inbetween function")
    assert(
        type(datetime.current_time_inbetween) == "function",
        "The current_time_inbetween element should be a function"
    )

    assert(datetime.unit_test_split, "The break timer api should have a unit_test_split function")
    assert(type(datetime.unit_test_split) == "function", "The unit_test_split element should be a function")
end

function test_break_timer_zero_padding_1()
    assert(
        datetime.numberZeroPadding(1) == "01",
        "Padding the number '1' should give '01'  but got: '" .. datetime.numberZeroPadding(1) .. "'"
    )
    assert(
        datetime.numberZeroPadding(2) == "02",
        "Padding the number '2' should give '02'  but got: '" .. datetime.numberZeroPadding(2) .. "'"
    )
    assert(
        datetime.numberZeroPadding(3) == "03",
        "Padding the number '3' should give '03'  but got: '" .. datetime.numberZeroPadding(3) .. "'"
    )
    assert(
        datetime.numberZeroPadding(4) == "04",
        "Padding the number '4' should give '04'  but got: '" .. datetime.numberZeroPadding(4) .. "'"
    )
    assert(
        datetime.numberZeroPadding(5) == "05",
        "Padding the number '5' should give '05'  but got: '" .. datetime.numberZeroPadding(5) .. "'"
    )
    assert(
        datetime.numberZeroPadding(6) == "06",
        "Padding the number '6' should give '06'  but got: '" .. datetime.numberZeroPadding(6) .. "'"
    )
    assert(
        datetime.numberZeroPadding(7) == "07",
        "Padding the number '7' should give '07'  but got: '" .. datetime.numberZeroPadding(7) .. "'"
    )
    assert(
        datetime.numberZeroPadding(8) == "08",
        "Padding the number '8' should give '08'  but got: '" .. datetime.numberZeroPadding(8) .. "'"
    )
    assert(
        datetime.numberZeroPadding(9) == "09",
        "Padding the number '9' should give '09'  but got: '" .. datetime.numberZeroPadding(9) .. "'"
    )
    assert(
        datetime.numberZeroPadding(10) == "10",
        "Padding the number '10' should give '10'  but got: '" .. datetime.numberZeroPadding(10) .. "'"
    )
end

function test_break_timer_zero_padding_special_cases()
    assert(
        datetime.numberZeroPadding(-1) == "-1",
        "Padding of the negative number '-1' shoud return '-1' but got: '" .. datetime.numberZeroPadding(-1) .. "'"
    )
    assert(
        datetime.numberZeroPadding(-20) == "-20",
        "Padding of the negative number '-20' shoud return '-20' but got: '" .. datetime.numberZeroPadding(-1) .. "'"
    )

    assert(datetime.numberZeroPadding() == "00", "Empty input should result in 00")
    assert(datetime.numberZeroPadding("") == "00", "Empty input should result in 00")
    assert(datetime.numberZeroPadding(nil) == "00", "Empty input should result in 00")
end

function test_break_timer_zero_padding_big_cases()
    assert(
        datetime.numberZeroPadding(10) == "10",
        "Padding the number '10' should give '10'  but got: '" .. datetime.numberZeroPadding(10) .. "'"
    )
    assert(
        datetime.numberZeroPadding(35) == "35",
        "Padding the number '35' should give '35'  but got: '" .. datetime.numberZeroPadding(35) .. "'"
    )
    assert(
        datetime.numberZeroPadding(134) == "134",
        "Padding the number '134' should give '134'  but got: '" .. datetime.numberZeroPadding(134) .. "'"
    )
    assert(
        datetime.numberZeroPadding(60) == "60",
        "Padding the number '60' should give '60'  but got: '" .. datetime.numberZeroPadding(60) .. "'"
    )
end

function test_break_timer_number_sec_to_MS()
    assert(
        datetime.numberInSecToMS(0) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(datetime.numberInSecToMS(0)) .. "'"
    )
    assert(
        datetime.numberInSecToMS(1) == "00:01",
        "The result should be '00:01' but got: '" .. tostring(datetime.numberInSecToMS(1)) .. "'"
    )
    assert(
        datetime.numberInSecToMS(10) == "00:10",
        "The result should be '00:10' but got: '" .. tostring(datetime.numberInSecToMS(10)) .. "'"
    )
    assert(
        datetime.numberInSecToMS(35) == "00:35",
        "The result should be '00:35' but got: '" .. tostring(datetime.numberInSecToMS(35)) .. "'"
    )
    assert(
        datetime.numberInSecToMS(60) == "01:00",
        "The result should be '01:00' but got: '" .. tostring(datetime.numberInSecToMS(60)) .. "'"
    )
    assert(
        datetime.numberInSecToMS(120) == "02:00",
        "The result should be '02:00' but got: '" .. tostring(datetime.numberInSecToMS(120)) .. "'"
    )
    assert(
        datetime.numberInSecToMS(140) == "02:20",
        "The result should be '02:20' but got: '" .. tostring(datetime.numberInSecToMS(140)) .. "'"
    )
end

function test_break_timer_number_sec_to_HMS()
    assert(
        datetime.numberInSecToHMS(0) == "00:00:00",
        "The result should be '00:00:00' but got: '" .. tostring(datetime.numberInSecToHMS(0)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(1) == "00:00:01",
        "The result should be '00:00:01' but got: '" .. tostring(datetime.numberInSecToHMS(1)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(10) == "00:00:10",
        "The result should be '00:00:10' but got: '" .. tostring(datetime.numberInSecToHMS(10)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(35) == "00:00:35",
        "The result should be '00:00:35' but got: '" .. tostring(datetime.numberInSecToHMS(35)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(60) == "00:01:00",
        "The result should be '00:01:00' but got: '" .. tostring(datetime.numberInSecToHMS(60)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(120) == "00:02:00",
        "The result should be '00:02:00' but got: '" .. tostring(datetime.numberInSecToHMS(120)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(140) == "00:02:20",
        "The result should be '00:02:20' but got: '" .. tostring(datetime.numberInSecToHMS(140)) .. "'"
    )

    assert(
        datetime.numberInSecToHMS(3700) == "01:01:40",
        "The result should be '01:01:40' but got: '" .. tostring(datetime.numberInSecToHMS(3700)) .. "'"
    )

    assert(
        datetime.numberInSecToHMS(7200) == "02:00:00",
        "The result should be '02:00:00' but got: '" .. tostring(datetime.numberInSecToHMS(7200)) .. "'"
    )
end

function test_break_timer_number_sec_to_MS_edge_cases()
    assert(
        datetime.numberInSecToMS(-1) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(datetime.numberInSecToMS(-1)) .. "'"
    )
    assert(
        datetime.numberInSecToMS(-100) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(datetime.numberInSecToMS(-100)) .. "'"
    )
    assert(
        datetime.numberInSecToMS("") == "00:00",
        "The result should be '00:00' but got: '" .. tostring(datetime.numberInSecToMS("")) .. "'"
    )
    assert(
        datetime.numberInSecToMS("100") == "00:00",
        "The result should be '00:00' but got: '" .. tostring(datetime.numberInSecToMS("100")) .. "'"
    )
    assert(
        datetime.numberInSecToMS(nil) == "00:00",
        "The result should be '00:00' but got: '" .. tostring(datetime.numberInSecToMS(nil)) .. "'"
    )
end

function test_break_timer_number_sec_to_HMS_edge_cases()
    assert(
        datetime.numberInSecToHMS(-1) == "00:00:00",
        "The result should be '00:00:00' but got: '" .. tostring(datetime.numberInSecToHMS(-1)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(-100) == "00:00:00",
        "The result should be '00:00:00' but got: '" .. tostring(datetime.numberInSecToHMS(-100)) .. "'"
    )
    assert(
        datetime.numberInSecToHMS("") == "00:00:00",
        "The result should be '00:00:00' but got: '" .. tostring(datetime.numberInSecToHMS("")) .. "'"
    )
    assert(
        datetime.numberInSecToHMS("100") == "00:00:00",
        "The result should be '00:00:00' but got: '" .. tostring(datetime.numberInSecToHMS("100")) .. "'"
    )
    assert(
        datetime.numberInSecToHMS(nil) == "00:00:00",
        "The result should be '00:00:00' but got: '" .. tostring(datetime.numberInSecToHMS(nil)) .. "'"
    )
end

function test_break_timer_split()
    assert(datetime.unit_test_split("abc;def", ";")[1] == "abc", "Splitting resulting in the wrong location")
    assert(datetime.unit_test_split("abc;def", ";")[2] == "def", "Splitting resulting in the wrong location")
    assert(datetime.unit_test_split("abc;def", ",")[1] == "abc;def", "Splitting resulting in the wrong location")
    assert(datetime.unit_test_split("", ";")[1] == "", "Splitting on empty lines failed")
    assert(datetime.unit_test_split("abc", "")[1] == "abc", "Splitting resulting in the wrong location")
end

function test_break_timer_split_edge_cases()
    assert(datetime.unit_test_split(123, 123) == nil, "Splitting on number is not allowed")
    assert(datetime.unit_test_split({}, {}) == nil, "Splitting on tables is not allowed")
    assert(datetime.unit_test_split(123, ";") == nil, "Splitting on numbers is not allowed")
    assert(
        datetime.unit_test_split("123", nil)[1] == "123",
        "Result should be '123' but got: " .. tostring(datetime.unit_test_split("123", nil)[1])
    )
end

function test_break_timer_current_time_inbetween()
    assert(
        datetime.current_time_inbetween(
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
        not datetime.current_time_inbetween(
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
        datetime.current_time_inbetween("10:00", "11:00", os.date("*t")) ==
            datetime.current_time_inbetween("10:00", "11:00"),
        "Make sure the break timer gets the correct time"
    )
end

function test_break_timer_current_time_inbetween_edge_cases_1()
    assert(
        not datetime.current_time_inbetween(
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
        not datetime.current_time_inbetween(
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
        not datetime.current_time_inbetween(
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
        not datetime.current_time_inbetween(
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
        not datetime.current_time_inbetween(
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
        not datetime.current_time_inbetween(
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
        datetime.current_time_inbetween(
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
        not datetime.current_time_inbetween(
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
        datetime.current_time_inbetween(
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
        datetime.current_time_inbetween(
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

function test_datetime_to_seconds()
    assert(datetime.toSeconds, 'Make sure the datetime.toSeconds api exists')
    assert(type(datetime.toSeconds) == "function", 'Make sure the datetime.toSeconds api is a function')

end

function test_datetime_to_seconds_from_seconds()
    assert(datetime.toSeconds("1") == 1, "Converting from 1 second to a seconds should remain the same, but got '" .. datetime.toSeconds("1") .. "'")
    assert(datetime.toSeconds("10") == 10, "Converting from 10 second to seconds should remain the same, but got '" .. datetime.toSeconds("10") .. "'")
    assert(datetime.toSeconds("100") == 100, "Converting from 100 second to seconds should remain the same, but got '" .. datetime.toSeconds("100") .. "'")
    assert(datetime.toSeconds("1000") == 1000, "Converting from 1000 second to seconds should remain the same, but got '" .. datetime.toSeconds("1000") .. "'")
    assert(datetime.toSeconds("-1") == 0, "Invalid input '-1' should result in 0 seconds, but got '" .. datetime.toSeconds("-1") .. "'")

end

function test_datetime_to_seconds_with_delimiter()
    assert(datetime.toSeconds("10:10") == 610, "Converting from '10:10' should result in 610 seconds but got '" .. tostring(datetime.toSeconds("10:10") .. "'"))
    assert(datetime.toSeconds("10:10:10") == 36610, "Converting from '10:10:10' should result in 36610 seconds but got '" .. tostring(datetime.toSeconds("10:10:10") .. "'"))
    assert(datetime.toSeconds("10:11:12") == 36672, "Converting from '10:11:12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10:11:12") .. "'"))
    assert(datetime.toSeconds("1:00") == 60, "Converting from '1:00' should result in 60 seconds but got '" .. tostring(datetime.toSeconds("1:00") .. "'"))
    assert(datetime.toSeconds("5:4:3:2") == 446582, "Converting from '5:4:3:2' should result in 446582 seconds but got '" .. tostring(datetime.toSeconds("5:4:3:2") .. "'"))
    assert(datetime.toSeconds("10-10") == 610, "Converting from '10-10' should result in 610 seconds but got '" .. tostring(datetime.toSeconds("10-10") .. "'"))
    assert(datetime.toSeconds("10-10") == 610, "Converting from '10 10' should result in 610 seconds but got '" .. tostring(datetime.toSeconds("10 10") .. "'"))

    assert(datetime.toSeconds("10 11 12") == 36672, "Converting from '10 11 12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10 11 12") .. "'"))
    assert(datetime.toSeconds("10,11-12") == 36672, "Converting from '10,11-12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10,11-12") .. "'"))

end

function test_datetime_to_seconds_with_spaces()
    assert(datetime.toSeconds("1 1 1 1") == 90061, "Converting from '1 1 1 1' should result in 90061 seconds but got '" .. tostring(datetime.toSeconds("1 1 1 1") .. "'"))
    assert(datetime.toSeconds("10 11 12") == 36672, "Converting from '10 11 12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10 11 12") .. "'"))
    assert(datetime.toSeconds("10       11 12") == 36672, "Converting from '10       11 12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10       11 12") .. "'"))
    assert(datetime.toSeconds("10   11 12") == 36672, "Converting from '10   11 12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10   11 12") .. "'"))


    assert(datetime.toSeconds("  10   11 12") == 36672, "Converting from '  10   11 12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("  10   11 12") .. "'"))
end

function test_datetime_to_seconds_with_expressions()
    assert(datetime.toSeconds("1d 1h 1m 1s") == 90061, "Converting from '1d 1h 1m 1s' should result in 90061 seconds but got '" .. tostring(datetime.toSeconds("1d 1h 1m 1s") .. "'"))
    assert(datetime.toSeconds("10h 11m 12") == 36672, "Converting from '10h 11m 12' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10h 11m 12") .. "'"))
    assert(datetime.toSeconds("10h-11m-12s") == 36672, "Converting from '10h-11m-12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10h-11m-12s") .. "'"))
    assert(datetime.toSeconds("11m-10h-12s") == 36672, "Converting from '11m-10h-12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("11m-10h-12s") .. "'"))

    assert(datetime.toSeconds("1d") == 86400, "Converting from '1d' should result in 86400 seconds but got '" .. tostring(datetime.toSeconds("1d") .. "'"))

end

function test_datetime_to_seconds_with_capital_expressions()
    assert(datetime.toSeconds("1D 1H 1M 1S") == 90061, "Converting from '1D 1H 1M 1S' should result in 90061 seconds but got '" .. tostring(datetime.toSeconds("1D 1H 1M 1S") .. "'"))
    assert(datetime.toSeconds("10H 11m 12S") == 36672, "Converting from '10H 11m 12S' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10H 11m 12S") .. "'"))
    assert(datetime.toSeconds("10H-11m-12s") == 36672, "Converting from '10H-11m-12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10H-11m-12s") .. "'"))
    assert(datetime.toSeconds("11M-10h-12S") == 36672, "Converting from '11M-10h-12S' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("11M-10h-12S") .. "'"))


    assert(datetime.toSeconds("1d") == 86400, "Converting from '1d' should result in 86400 seconds but got '" .. tostring(datetime.toSeconds("1d") .. "'"))

end

function test_datetime_to_seconds_invalid_input()
    assert(datetime.toSeconds("-1") == 0, "Invalid input '-1' should result in 0 seconds, but got '" .. datetime.toSeconds("-1") .. "'")
    assert(datetime.toSeconds(nil) == 0, "Invalid input 'nil' should result in 0 seconds, but got '" .. datetime.toSeconds(nil) .. "'")
    assert(datetime.toSeconds({}) == 0, "Invalid input '{}' should result in 0 seconds, but got '" .. datetime.toSeconds({}) .. "'")
    assert(datetime.toSeconds("0") == 0, "Invalid input '0' should result in 0 seconds, but got '" .. datetime.toSeconds("0") .. "'")
    assert(datetime.toSeconds(-1) == 0, "Invalid input '-1' should result in 0 seconds, but got '" .. datetime.toSeconds(-1) .. "'")
    assert(datetime.toSeconds(true) == 0, "Invalid input 'true' should result in 0 seconds, but got '" .. datetime.toSeconds(true) .. "'")
    assert(datetime.toSeconds("hello world") == 0, "Invalid input 'hello world' should result in 0 seconds, but got '" .. datetime.toSeconds("hello world") .. "'")
end

function test_datetime_to_seconds_with_delimiter_and_expressions()
    assert(datetime.toSeconds("10h-11m-12s") == 36672, "Converting from '10h-11m-12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10h-11m-12s") .. "'"))
    assert(datetime.toSeconds("11m-10h-12s") == 36672, "Converting from '11m-10h-12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("11m-10h-12s") .. "'"))
    assert(datetime.toSeconds("11m,10h,12s") == 36672, "Converting from '11m,10h,12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("11m,10h,12s") .. "'"))
    assert(datetime.toSeconds("11m 10h 12s") == 36672, "Converting from '11m 10h 12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("11m 10h 12s") .. "'"))
    assert(datetime.toSeconds("10h-11-12s") == 36672, "Converting from '10h-11-12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10h-11-12s") .. "'"))
    assert(datetime.toSeconds("10h.11.12s") == 36672, "Converting from '10h.11.12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10h.11.12s") .. "'"))
    assert(datetime.toSeconds("10h,11,12s") == 36672, "Converting from '10h,11,12s' should result in 36672 seconds but got '" .. tostring(datetime.toSeconds("10h,11,12s") .. "'"))
end

function test_datetime_to_seconds_large_values()
    assert(datetime.toSeconds("1y 1W 1D 1H 1m 1S") == 32144461, "Converting from '1y 1W 1D 1H 1m 1S' should result in 32144461 seconds but got '" .. tostring(datetime.toSeconds("1y 1W 1D 1H 1m 1S") .. "'"))
    assert(datetime.toSeconds("1Y 1W 1D 1H 1m 1S") == 32144461, "Converting from '1Y 1W 1D 1H 1m 1S' should result in 32144461 seconds but got '" .. tostring(datetime.toSeconds("1Y 1W 1D 1H 1m 1S") .. "'"))

    assert(datetime.toSeconds("1Y") == 31449600, "Converting from '1Y' should result in 31449600 seconds but got '" .. tostring(datetime.toSeconds("1Y") .. "'"))
    assert(datetime.toSeconds("1W") == 604800, "Converting from '1W' should result in 604800 seconds but got '" .. tostring(datetime.toSeconds("1W") .. "'"))
    assert(datetime.toSeconds("1D") == 86400, "Converting from '1D' should result in 86400 seconds but got '" .. tostring(datetime.toSeconds("1D") .. "'"))
    assert(datetime.toSeconds("1H") == 3600, "Converting from '1H' should result in 3600 seconds but got '" .. tostring(datetime.toSeconds("1H") .. "'"))
    assert(datetime.toSeconds("1M") == 60, "Converting from '1M' should result in 60 seconds but got '" .. tostring(datetime.toSeconds("1M") .. "'"))
    assert(datetime.toSeconds("1s") == 1, "Converting from '1s' should result in 1 seconds but got '" .. tostring(datetime.toSeconds("1s") .. "'"))

    assert(datetime.toSeconds("10Y") == 314496000, "Converting from '10Y' should result in 314496000 seconds but got '" .. tostring(datetime.toSeconds("10Y") .. "'"))
    assert(datetime.toSeconds("100Y") == 3144960000, "Converting from '10Y' should result in 3144960000 seconds but got '" .. tostring(datetime.toSeconds("10Y") .. "'"))
    assert(datetime.toSeconds("1000Y") == 31449600000, "Converting from '10Y' should result in 31449600000 seconds but got '" .. tostring(datetime.toSeconds("10Y") .. "'"))

end

function test_break_timer_api_unit_tested()
    local amount = 6
    local result = tablelength(datetime)
    assert(
        result == amount,
        "You didn't test all break-timer api endpoints, please add them then update the amount to: " .. result
    )
end
