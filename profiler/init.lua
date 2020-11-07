local profile_runner = require("profiler.isolation_runner")
local filehandle = require("lib-tde.file")

local function profile_tde()
    local res, out = profile_runner.run_rc_config_in_xephyr(os.getenv("PWD") .. "/profiler/runtime.lua")
    print(out)
end

local function profile_file()
    local profile = require("profiler.profile")
    if os.getenv("REALTIME") == "1" then
        profile.setclock(require("socket").gettime)
    end
    profile.start()
    require(os.getenv("FILE"):gsub(".lua", ""):gsub("/", "."))
    profile.stop()
    local res = profile.report(tonumber(os.getenv("FUNCTIONS_AMOUNT")) or 1000)
    if not (os.getenv("OUTPUT") == "") then
        filehandle.overwrite(os.getenv("OUTPUT"), res)
    end
    print(res)
end

if os.getenv("FILE") == "" then
    profile_tde()
else
    profile_file()
end
