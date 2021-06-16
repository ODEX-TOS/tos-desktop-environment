--DOC_GEN_IMAGE
--DOC_NO_USAGE
local parent    = ... --DOC_HIDE
local wibox     = require( "wibox"     ) --DOC_HIDE
local beautiful = require( "beautiful" ) --DOC_HIDE

    local my_imagebox = wibox.widget.imagebox(beautiful.awesome_icon, false)

parent:add(my_imagebox) --DOC_HIDE

--DOC_HIDE vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
