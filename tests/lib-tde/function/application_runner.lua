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
function test_application_runner_exists()
    local runner = require("tde.lib-tde.function.application_runner")
    assert(runner)
    assert(type(runner) == "function")
end

function test_application_runner_works()
    local runner = require("tde.lib-tde.function.application_runner")
    -- only runs once
    assert(runner("echo hello"))
    -- doesn't run anymore
    assert(not runner("echo hello"))
    assert(not runner("echo hello"))
end

function test_application_runner_works_2()
    local runner = require("tde.lib-tde.function.application_runner")
    -- only runs once
    assert(runner("printf hello"))
    -- doesn't run anymore
    assert(not runner("printf hello"))
    -- but this is a different command
    assert(runner("echo hello2"))
end

function test_application_runner_invalid_input()
    local runner = require("tde.lib-tde.function.application_runner")
    -- only runs once
    assert(not runner(""))
    assert(not runner(""))
    assert(not runner(123))
    assert(not runner(nil))
end
