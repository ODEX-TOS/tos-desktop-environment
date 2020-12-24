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
local naughty = require("naughty")

local function finish()
    local HOME = os.getenv("HOME")
    local FILE = HOME .. "/.cache/tutorial_tos"
    io.open(FILE, "w"):write("tutorial is complete"):close()
end

local function ninthTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate(
                "Nice all you need to do now is start the installer, open a terminal (mod+Enter) and type in 'tos c'. Good luck on your journey"
            ),
            timeout = 0,
            position = "top_left"
        }
    ):connect_signal("destroyed", finish)
end

local function eightTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate("For the help menu use mod+f1."),
            timeout = 0,
            position = "top_left"
        }
    ):connect_signal("destroyed", ninthTip)
end

local function seventhTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate("To go to a new workspace try mod+2, launch a program and switch back with mod+1"),
            timeout = 0,
            position = "top_left"
        }
    ):connect_signal("destroyed", eightTip)
end

local function sixthTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate("Click on the gear logo (top left) to access general settings."),
            timeout = 0,
            position = "top_left"
        }
    ):connect_signal("destroyed", seventhTip)
end

local function fifthTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate("To launch applications use mod+d. Try to start a few and kill them."),
            timeout = 0,
            position = "top_right"
        }
    ):connect_signal("destroyed", sixthTip)
end

local function fourthTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate("To kill a program use mod+q"),
            timeout = 0,
            position = "top_right"
        }
    ):connect_signal("destroyed", fifthTip)
end

local function thirdTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate(
                "Try to open a few terminals and see what happens. mod+Enter to open a terminal (windows key) Now click on the icon in the bottom right corner a few times"
            ),
            timeout = 0,
            position = "bottom_left"
        }
    ):connect_signal("destroyed", fourthTip)
end

local function secondTip()
    naughty.notify(
        {
            app_name = "TOS tutorial!",
            title = "TOS tutorial!",
            message = i18n.translate("This sets the staking layout of your windows. Notice the pattern."),
            timeout = 0,
            position = "bottom_left"
        }
    ):connect_signal("destroyed", thirdTip)
end

local func = {
    secondTip = secondTip,
    thirdTip = thirdTip,
    fourthTip = fourthTip,
    fifthTip = fifthTip,
    sixthTip = sixthTip,
    seventhTip = seventhTip,
    eightTip = eightTip,
    ninthTip = ninthTip,
    finish = finish
}

local HOME = os.getenv("HOME")
local FILE = HOME .. "/.cache/tutorial_tos"
if require("lib-tde.file").exists(FILE) then
    print("Tutorial has already been shown")
    func["status"] = false
    return func
end

print("Showing tutorial")
require("gears").timer.start_new(
    3,
    function()
        naughty.notify(
            {
                app_name = "TOS tutorial!",
                title = "TOS tutorial!",
                message = i18n.translate("All the icons on the bottom represent workspaces"),
                timeout = 0,
                position = "top_left"
            }
        ):connect_signal("destroyed", secondTip)
    end
)

func["status"] = true
return func
