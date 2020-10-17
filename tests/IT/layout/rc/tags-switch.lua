local sleep = require("tde.lib-tde.function.common").sleep

originalPrint = print

print = function(str)
end

require("tde.rc")

local awful = require("awful")
-- this should be the first tag
local tag1 = awful.screen.focused().selected_tag

local isFirstTag = tag1.index == 1
originalPrint("Verifying that we launched to the first tag? " .. tostring(isFirstTag))

awful.tag.viewnext()
originalPrint("Moving a tag to the right")
local tag2 = awful.screen.focused().selected_tag
local isNextTag = tag2.index == tag1.index + 1
originalPrint("Verifying that we move one tag to the right: " .. tostring(isNextTag))

local eightTags = (#awful.screen.focused().tags) == 8
originalPrint("Checking tag size == 8? " .. tostring(eightTags))
-- we are on the second index
local goToTag = 6
for index = 2, goToTag - 1 do
    sleep(0.3)
    awful.tag.viewnext()
    originalPrint("Moving to index: " .. tostring(awful.screen.focused().selected_tag.index))
end

-- we should be on the sixth index (5+1)
local tag = awful.screen.focused().selected_tag
local correctIndexLocation = tag.index == goToTag

originalPrint("IT-test-result:" .. tostring(isFirstTag and isNextTag and eightTags and correctIndexLocation))
