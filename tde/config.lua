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
-- This file holds general configuration parameters and functions you can use
local HOME = os.getenv("HOME")
local filesystem = require("gears.filesystem")
local file_exists = require("lib-tde.file").exists

-- We add *_startup_delay to most polls
-- to separate the runtime
-- Otherwise all polls will run at the same time creating a peak of cpu usage
-- By spreading them out using delays we get lower cpu usage

local config = {
    package_timeout = 180, -- how frequently we want to check if there are new updates in seconds
    battery_timeout = 20, -- How frequently we want to check our battery status in seconds
    player_reaction_time = 0.01, -- The time for the music player to respond to our play/pause action
    player_update = 5, -- Timeout to check if a new song is playing
    bluetooth_poll = 5, -- how often do we check if bluetooth is active/disabled
    network_poll = 5, -- how often we should try to detect the ssid name
    network_startup_delay = 1,
    harddisk_poll = 5, -- how often do we check how full the harddisk is
    harddisk_startup_delay = 3,
    temp_poll = 5, -- how often do we check the current temperature
    temp_startup_delay = 5,
    ram_poll = 5, -- how often do we check the current ram usage
    ram_startup_delay = 7,
    weather_poll = 1200, -- how often we check the weather status
    cpu_poll = 5, -- how often do we check the current cpu status
    cpu_startup_delay = 9,
    colors_config = HOME .. "/.config/tos/colors.conf",
    icons_config = HOME .. "/.config/tos/icons.conf",
    getComptonFile = function()
        local userfile = HOME .. "/.config/picom.conf"
        if (file_exists(userfile)) then
            return userfile
        end
        return filesystem.get_configuration_dir() .. "/configuration/picom.conf "
    end,
    aboutText = "TOS Linux Alpha Edition\nMIT License\n© Meyers Tom 2019 - " ..
        os.date("%Y") .. "\n\n" .. i18n.translate("Thanks for using our product") .. " ♥"
}

return config
