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
require('module.notifications')
require('module.auto-start')
require('module.exit-screen')
require('module.quake-terminal')
require('module.menu')
require('module.titlebar')
require('module.volume_manager')
require('module.brightness-slider-osd')
require('module.volume-slider-osd')
require('module.info-gather')
require('module.battery-notifier')
require('module.prompt')
require('module.settings')
require('module.backdrop')
require('module.menu')
_G.switcher = require('module.application-switch')

require('module.dev-widget-update')
require('module.plugin-module')
require('module.bootup_configuration')

-- Only activate the break timer if users what it
-- The default implementation of TOS doesn't use it
-- TODO: A signal should activate/deactivate it
if general["break"] == "1" then
    require("module.break-timer")
end

if not (general["disable_desktop"] == "1") then
    if IsreleaseMode then
        require("module.installer")
    end

    require("module.desktop")
end

if IsreleaseMode then
    require("tutorial")

    require("module.dev-widget-update")

    require("module.lua-completion")
end


require("module.wallpaper-changer")
require("module.screen_swipe")
