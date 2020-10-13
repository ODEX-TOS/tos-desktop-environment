local tutorial = require("tutorial")

-- TODO: these tips are global functions defined in tutorial.lua and should be local functions
function test_check_tutorial_functions_exists()
    assert(secondTip)
    assert(thirdTip)
    assert(fourthTip)
    assert(fifthTip)
    assert(sixthTip)
    assert(seventhTip)
    assert(eightTip)
    assert(ninthTip)
    assert(finish)
end

function test_check_tutorial_functions_are_functions()
    assert(type(secondTip) == "function")
    assert(type(thirdTip) == "function")
    assert(type(fourthTip) == "function")
    assert(type(fifthTip) == "function")
    assert(type(sixthTip) == "function")
    assert(type(seventhTip) == "function")
    assert(type(eightTip) == "function")
    assert(type(ninthTip) == "function")
    assert(type(finish) == "function")
end

function test_check_tutorial_file_creation()
    local file_exists = require("tde.lib-tde.file").exists
    local dir_exists = require("tde.lib-tde.file").dir_exists
    local file = os.getenv("HOME") .. "/.cache/tutorial_tos"
    
    -- in a dockerized environment we run as root and that account doesn't have a cache directory yet
    if not dir_exists(os.getenv("HOME") .. "/.cache") then
        os.popen("mkdir" .. os.getenv("HOME") .. "/.cache")
    end

    -- remove that file if it exists
    if file_exists(file) then
        os.remove(file)
    end
    assert(not file_exists(file))
    -- returns true if the tutorial is beeing shown
    assert(require("tde.tutorial"))
    -- should be called internally but no GUI stack exist so we call it from here
    finish()
    assert(file_exists(file))
    -- TODO: On a second try the tutorial should return false to indicate that it is finished
    --assert(not require("tde.tutorial"))

end