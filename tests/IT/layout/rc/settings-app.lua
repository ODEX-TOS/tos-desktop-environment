originalPrint = print

print = function(str)
end

require("tde.rc")

local hasSettingsApp = root.elements.settings ~= nil

assert(hasSettingsApp)

-- open settings app as a visual queue

root.elements.settings.enable_view_by_index(1, awful.screen.focused())

originalPrint("Settings app exists")

originalPrint("IT-test-result:" .. tostring(hasSettingsApp))
