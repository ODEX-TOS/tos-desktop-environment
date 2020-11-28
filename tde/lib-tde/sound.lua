local mode = general["audio_change_sound"] or "1"
local spawn = require("awful").spawn

local function play_sound()
  if mode == "1" then
    print("Playing audio-pop sound")
    spawn("paplay /etc/xdg/tde/sound/audio-pop.wav")
  end
end

return play_sound
