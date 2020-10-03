
local wibox = require("wibox")

local cal = wibox.widget {
    date         = os.date('*t'),
    font         = "Iosevka Custom 11",
    spacing      = 10,
    week_numbers = false,
    start_sunday = false,
    widget       = wibox.widget.calendar.month
}

return cal