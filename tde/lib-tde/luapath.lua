local exists = require("lib-tde.file").dir_exists

-- Used to enable custom widgets as a plugin mechanism for TDE
package.path = os.getenv("HOME") .. "/.config/tde/?/init.lua;" .. package.path
package.path = os.getenv("HOME") .. "/.config/tde/?.lua;" .. package.path

-- Setup custom lua scripts (libraries)
-- If the user dir exists then use that
-- Otherwise use the system files
if exists(os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-lua") then
    package.path =
        package.path ..
        ";" ..
            os.getenv("HOME") ..
                "/.config/awesome/lib-tde/lib-lua/?/?.lua;" ..
                    os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-lua/?.lua"
end

if exists(os.getenv("HOME") .. "/.config/awesome/lib-tde/translations") then
    package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/awesome/lib-tde/translations/?.lua"
end

package.path = package.path .. ";" .. "/etc/xdg/tde/lib-tde/lib-lua/?/?.lua;" .. "/etc/xdg/tde/lib-tde/lib-lua/?.lua"
package.path = package.path .. ";" .. "/etc/xdg/tde/lib-tde/translations/?.lua"

-- same applies for the c libraries
if exists(os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-so") then
    package.cpath =
        package.cpath ..
        ";" ..
            os.getenv("HOME") ..
                "/.config/awesome/lib-tde/lib-so/?/?.so;" .. os.getenv("HOME") .. "/.config/awesome/lib-tde/lib-so/?.so"
end
package.cpath = package.cpath .. ";" .. "/etc/xdg/tde/lib-tde/lib-so/?/?.so;" .. "/etc/xdg/tde/lib-tde/lib-so/?.so"
