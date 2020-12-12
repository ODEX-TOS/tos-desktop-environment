--[[
--MIT License
--
--Copyright (c) 2019 manilarome
--Copyright (c) 2020 Tom Meyers
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
]]
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
