local profile = require("profiler.profile")
local delayed_timer = require("lib-tde.function.delayed-timer")
local filehandle = require("lib-tde.file")

originalPrint = print
print = function(str)
end
-- start profiling
profile.start()
require("tde.rc")

delayed_timer(
    1000,
    function()
        originalPrint("Starting profiler")
    end,
    tonumber(os.getenv("STARTTIME")),
    true
)

delayed_timer(
    1000,
    function()
        originalPrint("Stopping profiler")
        profile.stop()
        local res = profile.report(tonumber(os.getenv("FUNCTIONS")))
        filehandle.overwrite(os.getenv("PWD") .. "/profiler.results", res)
        originalPrint(res)
    end,
    tonumber(os.getenv("ENDTIME")),
    true
)
