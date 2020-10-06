local sound = require("tde.lib-tde.sound")
local exists = require("tde.lib-tde.file").exists

function test_exists_lib_tde_sound()
    assert(sound)
    assert(type(sound) == "function")
end

function test_sound_pop_wav_file_exists()
    assert(exists(os.getenv("PWD") .. "/tde/sound/audio-pop.wav"))
end
