local hardware = require("tde.lib-tde.hardware-check")

function Test_IT_run_application_startup()
    -- make sure we have the correct dependencies before running the intergation test
    assert(hardware.has_package_installed("xorg-server-xephyr"))
    assert(hardware.has_package_installed("awesome-tos"))
    assert(hardware.has_package_installed("bash"))

    -- this is the command to launch TDE
    local DISPLAY = ":2"
    local ENV = "XDG_CURRENT_DESKTOP=TDE TDE_ENV=develop DISPLAY=" .. DISPLAY
    local launchCMD = "awesome --config " .. os.getenv("PWD") .. "/tde/rc.lua"
    local xephyrCommand = "Xephyr -br -ac -noreset -screen 700x700 " .. DISPLAY .. " &"
    local command = "timeout 7 bash -c '(" .. xephyrCommand .. "); sleep 1; " .. ENV .. " " .. launchCMD .. "'"
    print(command)
    local _, ret = hardware.execute(command)
    -- timeout command return exit code 124 if the command had to be halted
    -- we give 10 seconds boot time to test crashes
    assert(ret == 124)
end

-- WORK OUT how to interact with the exists window manager (maybe look into awesome-client?)
-- We could invoke known globals to open up menu's etc
-- We still would need a way to make sure the GUI is showing up

-- TODO: test if topbar exists

-- TODO: test if action menu exists

-- TODO: test if control center exists and you can switch between notifications and widgets

-- TODO: test if bottom bar exists

-- TODO: test if we can switch between tags

-- TODO: test compositor

-- TODO: test tiling modes

-- TODO: test floating mode

-- TODO: test if notifications are shown

-- TODO: test common widgets such as time, calendar, notification etc
