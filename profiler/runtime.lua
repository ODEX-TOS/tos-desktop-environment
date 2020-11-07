local profile = require("profiler.profile")
local delayed_timer = require("lib-tde.function.delayed-timer")
local filehandle = require("lib-tde.file")

originalPrint = print
print = function(str)
end
-- start profiling
if os.getenv("REALTIME") == "1" then
    profile.setclock(require("socket").gettime)
end
profile.start()
require("tde.rc")

delayed_timer(
    1000,
    function()
        originalPrint("Stopping profiler")
        profile.stop()
        local res = profile.report(tonumber(os.getenv("FUNCTIONS_AMOUNT")) or 1000)
        if not (os.getenv("OUTPUT") == "") then
            filehandle.overwrite(os.getenv("OUTPUT"), res)
        end
        originalPrint(res)
    end,
    tonumber(os.getenv("TOTAL_TIME")),
    true
)
