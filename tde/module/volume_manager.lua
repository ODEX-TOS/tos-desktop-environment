local signals = require("lib-tde.signals")
local sound = require("lib-tde.sound")

local pop_counter = 1
local startup = true

signals.connect_volume(
    function(value)
        if pop_counter == 0 then
            sound()
            awful.spawn("amixer -D pulse sset Master " .. tostring(value) .. "%")
        end
        pop_counter = pop_counter + 1
        if pop_counter == 3 then
            pop_counter = 0
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
                if not startup then
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
