local execute = require("tde.lib-tde.hardware-check").execute

originalPrint = print

print = function(str)
end

require("tde.rc")

local hasTopbar = false
for s in screen do
    if not (s.top_panel == nil) then
        hasTopbar = true
    end
end

originalPrint("IT-test-result:" .. tostring(hasTopbar))

-- we have our results - speed up the tests
