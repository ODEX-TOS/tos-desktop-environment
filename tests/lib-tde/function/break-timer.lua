local breakTimer = require("tde.lib-tde.function.datetime")

function test_break_timer_exists()
    assert(breakTimer)
    assert(type(breakTimer) == "table")
end

function test_break_timer_props()
    assert(breakTimer.numberZeroPadding)
    assert(type(breakTimer.numberZeroPadding) == "function")

    assert(breakTimer.numberInSecToMS)
    assert(type(breakTimer.numberInSecToMS) == "function")

    assert(breakTimer.current_time_inbetween)
    assert(type(breakTimer.current_time_inbetween) == "function")

    assert(breakTimer.unit_test_split)
    assert(type(breakTimer.unit_test_split) == "function")
end

function test_break_timer_zero_padding_1()
    assert(breakTimer.numberZeroPadding(1) == "01")
    assert(breakTimer.numberZeroPadding(2) == "02")
    assert(breakTimer.numberZeroPadding(3) == "03")
    assert(breakTimer.numberZeroPadding(4) == "04")
    assert(breakTimer.numberZeroPadding(5) == "05")
    assert(breakTimer.numberZeroPadding(6) == "06")
    assert(breakTimer.numberZeroPadding(7) == "07")
    assert(breakTimer.numberZeroPadding(8) == "08")
    assert(breakTimer.numberZeroPadding(9) == "09")
    assert(breakTimer.numberZeroPadding(10) == "10")
end

function test_break_timer_zero_padding_special_cases()
    assert(breakTimer.numberZeroPadding(-1) == "-1")
    assert(breakTimer.numberZeroPadding(-20) == "-20")

    assert(breakTimer.numberZeroPadding() == "00")
    assert(breakTimer.numberZeroPadding("") == "00")
    assert(breakTimer.numberZeroPadding(nil) == "00")
end

function test_break_timer_zero_padding_big_cases()
    assert(breakTimer.numberZeroPadding(10) == "10")
    assert(breakTimer.numberZeroPadding(35) == "35")
    assert(breakTimer.numberZeroPadding(134) == "134")
    assert(breakTimer.numberZeroPadding(60) == "60")
end

function test_break_timer_number_sec_to_MS()
    assert(breakTimer.numberInSecToMS(0) == "00:00")
    assert(breakTimer.numberInSecToMS(1) == "00:01")
    assert(breakTimer.numberInSecToMS(10) == "00:10")
    assert(breakTimer.numberInSecToMS(35) == "00:35")
    assert(breakTimer.numberInSecToMS(60) == "01:00")
    assert(breakTimer.numberInSecToMS(120) == "02:00")
    assert(breakTimer.numberInSecToMS(140) == "02:20")
end

function test_break_timer_number_sec_to_MS_edge_cases()
    assert(breakTimer.numberInSecToMS(-1) == "00:00")
    assert(breakTimer.numberInSecToMS(-100) == "00:00")
    assert(breakTimer.numberInSecToMS("") == "00:00")
    assert(breakTimer.numberInSecToMS("100") == "00:00")
    assert(breakTimer.numberInSecToMS(nil) == "00:00")
end

function test_break_timer_split()
    assert(breakTimer.unit_test_split("abc;def", ";")[1] == "abc")
    assert(breakTimer.unit_test_split("abc;def", ";")[2] == "def")
    assert(breakTimer.unit_test_split("abc;def", ",")[1] == "abc;def")
    assert(breakTimer.unit_test_split("", ";")[1] == "")
    assert(breakTimer.unit_test_split("abc", "")[1] == "abc")
end

function test_break_timer_split_edge_cases()
    assert(breakTimer.unit_test_split(123, 123) == nil)
    assert(breakTimer.unit_test_split({}, {}) == nil)
    assert(breakTimer.unit_test_split(123, ";") == nil)
    assert(breakTimer.unit_test_split("123", nil)[1] == "123")
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
        )
    )

    assert(
        not breakTimer.current_time_inbetween(
            "10:00",
            "11:00",
            {
                min = 30,
                hour = 11
            }
        )
    )

    assert(
        breakTimer.current_time_inbetween("10:00", "11:00", os.date("*t")) ==
            breakTimer.current_time_inbetween("10:00", "11:00")
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
        )
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
        )
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
        )
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
        )
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
        )
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
        )
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
        )
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
        )
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
        )
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
        )
    )
end
