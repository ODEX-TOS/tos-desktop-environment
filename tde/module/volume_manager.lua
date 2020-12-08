local signals = require("lib-tde.signals")
local sound = require("lib-tde.sound")
local time = require("socket").gettime

local startup = true
local prev_time = 0
local boot_time = time()
local deltaTime = 0.1

signals.connect_volume(
    function(value)
        -- we set prev_time initially to a higer value so we don't hear a pop sound when starting up the DE
        if prev_time == 0 then
            prev_time = time() + 1
        end
        if prev_time < (time() - deltaTime) then
            sound()
            awful.spawn("amixer -D pulse sset Master " .. tostring(value) .. "%")
            prev_time = time()
        end
    end
)

signals.connect_volume_update(
    function()
        awful.spawn.easy_async_with_shell(
            "amixer -D pulse get Master",
            function(out)
                local muted = string.find(out, "off")
                local volume = string.match(out, "(%d?%d?%d)%%")
                signals.emit_volume(tonumber(volume))
                signals.emit_volume_is_muted(muted ~= nil or muted == "off")
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
