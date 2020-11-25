local tutorial = require("tutorial")

-- TODO: these tips are global functions defined in tutorial.lua and should be local functions
function test_check_tutorial_functions_exists()
    assert(tutorial.secondTip)
    assert(tutorial.thirdTip)
    assert(tutorial.fourthTip)
    assert(tutorial.fifthTip)
    assert(tutorial.sixthTip)
    assert(tutorial.seventhTip)
    assert(tutorial.eightTip)
    assert(tutorial.ninthTip)
    assert(tutorial.finish)
end

function test_check_tutorial_functions_are_functions()
    assert(type(tutorial.secondTip) == "function")
    assert(type(tutorial.thirdTip) == "function")
    assert(type(tutorial.fourthTip) == "function")
    assert(type(tutorial.fifthTip) == "function")
    assert(type(tutorial.sixthTip) == "function")
    assert(type(tutorial.seventhTip) == "function")
    assert(type(tutorial.eightTip) == "function")
    assert(type(tutorial.ninthTip) == "function")
    assert(type(tutorial.finish) == "function")
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
    local func = require("tde.tutorial")
    assert(func["status"])
    -- should be called internally but no GUI stack exist so we call it from here
    func.finish()
    assert(file_exists(file))
    -- TODO: On a second try the tutorial should return false to indicate that it is finished
    --assert(not require("tde.tutorial"))
end
