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
local signals = require("lib-tde.signals")
local sound = require("lib-tde.sound")
local time = require("socket").gettime
local volume = require("lib-tde.volume")

local startup = true
local prev_time = 0
local boot_time = time()
local deltaTime = 0.1

signals.connect_volume(
    function(value)
        -- we set prev_time initially to a higher value so we don't hear a pop sound when starting up the DE
        if prev_time == 0 then
            prev_time = time() + 1
        end
        if prev_time < (time() - deltaTime) then
            sound()
            volume.set_volume(value)
            prev_time = time()
        end
    end
)

signals.connect_volume_update(
    function()
        volume.get_volume(
            function(volume_level, muted)

                -- if the sound system is down then default to a volume of 0
                signals.emit_volume(volume_level)
                signals.emit_volume_is_muted(muted)
                if not startup and time() > (boot_time + 5) then
                    if _G.toggleVolOSD ~= nil then
                        _G.toggleVolOSD(true)
                    end
                    if _G.UpdateVolOSD ~= nil then
                        _G.UpdateVolOSD()
                    end
                else
                    startup = false
                end
            end
        )
    end
)

-- request a volume update on startup
signals.emit_volume_update()
