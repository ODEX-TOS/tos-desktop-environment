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
