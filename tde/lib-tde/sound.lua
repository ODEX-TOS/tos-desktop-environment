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
local mode = general["audio_change_sound"] or "1"
local spawn = require("awful").spawn

local function play_sound(bAlwaysPlay)
  local shouldPlay = bAlwaysPlay or (mode == "1" and not _G.save_state.hardware_only_volume)
  if shouldPlay then
    print("Playing audio-pop sound")
    local pid, _ = spawn("paplay /etc/xdg/tde/sound/audio-pop.wav", false)
    return pid
  end
  return -1
end

local function timer_sound(bAlwaysPlay)
  local shouldPlay = bAlwaysPlay or (mode == "1" and not _G.save_state.hardware_only_volume)
  if shouldPlay then
    print("Playing audio-pop sound")
    local pid, _ = spawn("paplay /etc/xdg/tde/sound/alarm.wav", false)
    return pid
  end
  return -1
end

return {
  play_sound = play_sound,
  timer_sound = timer_sound
}
