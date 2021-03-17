-- Only allow symbols available in all Lua versions
std = "min"

-- Get rid of "unused argument self"-warnings
self = false

-- The unit tests can use busted
files["spec"].std = "+busted"

-- The default config may set global variables
files["awesomerc.lua"].allow_defined_top = true

-- This file itself
files[".luacheckrc"].ignore = {"111", "112", "131"}

-- ignore file max line length
-- ignore string containing trailing whitespace
-- ignore mutating of global variables
-- ifnore setting global variables
files["**"].ignore = {"631", "613", "112", "122"}

exclude_files = {
    "lib-tde/lib-lua/cjson/util.lua",
    "lib-tde/lib-lua/ltn12.lua",
    "lib-tde/lib-lua/mime.lua",
    "lib-tde/lib-lua/posix/_base.lua",
    "lib-tde/lib-lua/posix/compat.lua",
    "lib-tde/lib-lua/posix/deprecated.lua",
    "lib-tde/lib-lua/posix/init.lua",
    "lib-tde/lib-lua/socket.lua",
    "lib-tde/lib-lua/socket/ftp.lua",
    "lib-tde/lib-lua/socket/http.lua",
    "lib-tde/lib-lua/socket/smtp.lua",
    "lib-tde/lib-lua/socket/tp.lua",
    "lib-tde/lib-lua/socket/url.lua",
    "lib-tde/lib-lua/ssl.lua",
    "lib-tde/lib-lua/ssl/https.lua",
    "tde/lib-tde/lib-lua/cjson/util.lua",
    "tde/lib-tde/lib-lua/ltn12.lua",
    "tde/lib-tde/lib-lua/mime.lua",
    "tde/lib-tde/lib-lua/posix/_base.lua",
    "tde/lib-tde/lib-lua/posix/compat.lua",
    "tde/lib-tde/lib-lua/posix/deprecated.lua",
    "tde/lib-tde/lib-lua/posix/init.lua",
    "tde/lib-tde/lib-lua/socket.lua",
    "tde/lib-tde/lib-lua/socket/ftp.lua",
    "tde/lib-tde/lib-lua/socket/http.lua",
    "tde/lib-tde/lib-lua/socket/smtp.lua",
    "tde/lib-tde/lib-lua/socket/tp.lua",
    "tde/lib-tde/lib-lua/socket/url.lua",
    "tde/lib-tde/lib-lua/ssl.lua",
    "tde/lib-tde/lib-lua/ssl/https.lua",
    -- contains a lot of globals
    "tests/**",
    -- TODO: refactor plugins, then remove this
    --"plugins/**",
}

-- Global objects defined by the C code
read_globals = {
    "awesome",
    "button",
    "dbus",
    "drawable",
    "drawin",
    "key",
    "keygrabber",
    "mousegrabber",
    "selection",
    "tag",
    "window",
    "table.unpack",
    "math.atan2",
    "math.pow",
    "reverse",
    "center",
    "save_state",
    "dont_disturb",
    "clear_desktop_selection",
    "wibox",
    "rawlen"
}

-- screen may not be read-only, because newer luacheck versions complain about
-- screen[1].tags[1].selected = true.
-- The same happens with the following code:
--   local tags = mouse.screen.tags
--   tags[7].index = 4
-- client may not be read-only due to client.focus.
globals = {
    "screen",
    "mouse",
    "root",
    "client",
    "timer",
    -- custom globals defined by tde
    "awful",
    "i18n",
    "general",
    "plugins",
    "tags",
    "keys",
    "floating",
    "backdrop",
    "taglist_occupied",
    "print",
    "echo",
    "desktop_icons",
}

-- Enable cache (uses .luacheckcache relative to this rc file).
cache = true

-- Do not enable colors to make the Travis CI output more readable.
color = true

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
