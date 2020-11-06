local profile_runner = require("profiler.isolation_runner")

local res, out =
    profile_runner.run_rc_config_in_xephyr(
    os.getenv("PWD") .. "/profiler/runtime.lua",
    tonumber(arg[1]),
    tonumber(arg[2]),
    tonumber(arg[3])
)
print(out)
