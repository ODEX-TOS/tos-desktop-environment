
-- Including the below require will resolve the error
--local wibox = require("wibox")


-- generate a text widget that acts like the header
header = wibox.widget {
    text   = "Error",
    font   = 'SFNS Display Regular 14',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

return header
