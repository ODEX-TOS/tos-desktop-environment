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
local sound = require("tde.lib-tde.sound")
local exists = require("tde.lib-tde.file").exists

function test_exists_lib_tde_sound()
    assert(sound.play_sound, "Make sure the sound 'play_sound' api exists")
    assert(type(sound.play_sound) == "function", "Sound 'play_sound' api is wrong, should be a function")

    assert(sound.timer_sound, "Make sure the sound 'timer_sound' api exists")
    assert(type(sound.timer_sound) == "function", "Sound 'timer_sound' api is wrong, should be a function")
end

function test_sound_pop_wav_file_exists()
    assert(exists(os.getenv("PWD") .. "/tde/sound/audio-pop.wav"), "Make sure the sound file exists")
end

function test_sound_alarm_wav_file_exists()
    assert(exists(os.getenv("PWD") .. "/tde/sound/alarm.wav"), "Make sure the sound file exists")
end
