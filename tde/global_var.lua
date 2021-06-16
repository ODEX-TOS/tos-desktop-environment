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
os.start_time = os.time()

local hardware = require("lib-tde.hardware-check")
local is_weak = hardware.isWeakHardware()
local beautiful = require("beautiful")

-- general conf is used by sentry (to opt out of it)
general = require("parser")(os.getenv("HOME") .. "/.config/tos/general.conf")

i18n = require("lib-tde.i18n")
i18n.init("en")

-- Setup Sentry error logging --
if not (general["tde_opt_out"] == "0") then
    _G.sentry = require("lib-tde.errors")
else
    print("User opted out of stacktrace analysis")
    print("No information will be send to the tos developers")
end

awful = require("awful")
awful.screen.set_auto_dpi_enabled(true)

plugins = require("parser")(os.getenv("HOME") .. "/.config/tos/plugins.conf")
tags = require("parser")(os.getenv("HOME") .. "/.config/tos/tags.conf")
keys = require("parser")(os.getenv("HOME") .. "/.config/tos/keys.conf")
floating = require("parser")(os.getenv("HOME") .. "/.config/tos/floating.conf")

local bIsIntegrationTest = os.getenv("HOME") == "/tmp/tde"
IsreleaseMode = not bIsIntegrationTest

print("Release mode: " .. tostring(IsreleaseMode))

-- dynamic variables are defined here
-- update the value through this setter, making sure that the animation speed is disabled on weak hardware
_G.update_anim_speed = function(value)
    if general["weak_hardware"] == "1" or is_weak then
        _G.anim_speed = 0
        return
    end
    _G.anim_speed = value
end

_G.update_anim_speed(tonumber(general["animation_speed"] or "0.3"))

-- Theme
beautiful.init(require("theme"))
