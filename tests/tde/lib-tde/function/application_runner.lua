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
function Test_application_runner_exists()
    local runner = require("tde.lib-tde.function.application_runner")
    assert(runner, "Make sure the application runner exists")
    assert(type(runner) == "function", "Make sure the application runner is a function")
end

function Test_application_runner_works()
    local runner = require("tde.lib-tde.function.application_runner")
    -- only runs once
    assert(runner("echo hello"), "First time running 'echo hello' and it skipped it")
    -- doesn't run anymore
    assert(not runner("echo hello"), "Second time running 'echo hello' and it still ran it")
    assert(not runner("echo hello"), "Third time running 'echo hello' and it still ran it")
end

function Test_application_runner_works_2()
    local runner = require("tde.lib-tde.function.application_runner")
    -- only runs once
    assert(runner("printf hello"), "First time running 'printf hello' and it skipped it")
    -- doesn't run anymore
    assert(not runner("printf hello"), "Second time running 'printf hello' and it ran it")
    -- but this is a different command
    assert(runner("echo hello2"), "First time running 'echo hello2' and it skipped it")
end

function Test_application_runner_invalid_input()
    local runner = require("tde.lib-tde.function.application_runner")
    -- only runs once
    assert(not runner(""), "Running an empty command is not allowed")
    assert(not runner(""), "Running an empty command is not allowed")
    assert(not runner(123), "Running an command should be a string not a number")
    assert(not runner(nil), "Running an empty command should be a string not nil")
end
