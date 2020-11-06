local profile_runner = require("profiler.isolation_runner")

local function profile_tde()
    local res, out =
        profile_runner.run_rc_config_in_xephyr(
        os.getenv("PWD") .. "/profiler/runtime.lua",
        tonumber(arg[1]),
        tonumber(arg[2]),
        tonumber(arg[3])
    )
    print(out)
end

local function profile_file()
    local profile = require("profiler.profile")
    profile.start()
    require(arg[1]:gsub(".lua", ""):gsub("/", "."))
    profile.stop()
    print(profile.report())
end

if #arg == 1 then
    profile_file()
else
    profile_tde()
end
