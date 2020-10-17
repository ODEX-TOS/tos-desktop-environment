local execute = require("tde.lib-tde.hardware-check").execute

originalPrint = print

print = function(str)
end

require("tde.rc")

local hasBottomPanel = false
for s in screen do
    if not (s.bottom_panel == nil) then
        hasBottomPanel = true
    end
end

assert(hasBottomPanel)

originalPrint("Bottom panel exists")

originalPrint("IT-test-result:" .. tostring(hasBottomPanel))
