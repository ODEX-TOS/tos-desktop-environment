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
local tutorial = require("tutorial")

function Test_check_tutorial_functions_exists()
    assert(tutorial.secondTip, "Check that secondTip exists in the tutorial")
    assert(tutorial.thirdTip, "Check that thirdTip exists in the tutorial")
    assert(tutorial.fourthTip, "Check that fourthTip exists in the tutorial")
    assert(tutorial.fifthTip, "Check that fifthTip exists in the tutorial")
    assert(tutorial.sixthTip, "Check that sixthTip exists in the tutorial")
    assert(tutorial.seventhTip, "Check that seventhTip exists in the tutorial")
    assert(tutorial.eightTip, "Check that eightTip exists in the tutorial")
    assert(tutorial.ninthTip, "Check that ninthTip exists in the tutorial")
    assert(tutorial.finish, "Check that finish exists in the tutorial")
end

function Test_check_tutorial_functions_are_functions()
    assert(type(tutorial.secondTip) == "function", "checks that secondTip is a function")
    assert(type(tutorial.thirdTip) == "function", "checks that thirdTip is a function")
    assert(type(tutorial.fourthTip) == "function", "checks that fourthTip is a function")
    assert(type(tutorial.fifthTip) == "function", "checks that fifthTip is a function")
    assert(type(tutorial.sixthTip) == "function", "checks that sixthTip is a function")
    assert(type(tutorial.seventhTip) == "function", "checks that seventhTip is a function")
    assert(type(tutorial.eightTip) == "function", "checks that eightTip is a function")
    assert(type(tutorial.ninthTip) == "function", "checks that ninthTip is a function")
    assert(type(tutorial.finish) == "function", "checks that finish is a function")
end

function Test_check_tutorial_file_creation()
    local filehandle = require("tde.lib-tde.file")
    local file_exists = filehandle.exists
    local dir_create = filehandle.dir_create
    local file = os.getenv("HOME") .. "/.cache/tutorial_tos"

    -- in a dockerized environment we run as root and that account doesn't have a cache directory yet
    dir_create(os.getenv("HOME") .. "/.cache")

    -- remove that file if it exists
    if file_exists(file) then
        filehandle.rm(file)
    end
    assert(not file_exists(file), file .. " should not exist")
    -- returns true if the tutorial is being shown
    local func = require("tde.tutorial")
    assert(func["status"], "tutorial did not run")
    -- should be called internally but no GUI stack exist so we call it from here
    func.finish()
    assert(file_exists(file), "After the tutorial " .. file .. " should exist")
    -- TODO: On a second try the tutorial should return false to indicate that it is finished
    --assert(not require("tde.tutorial"))
end

function Test_tutorial_api_unit_tested()
    local amount = 10
    local result = tablelength(tutorial)
    assert(
        result == amount,
        "You didn't test all tutorial api endpoints, please add them then update the amount to: " .. result
    )
end
