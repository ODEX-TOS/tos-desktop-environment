-- the logger class overrides the print function
local logger = require("tde.helper.logger")

function test_logger_settings()
    assert(logger)
    assert(logger.warn)
    assert(logger.error)
    assert(logger.debug)
    assert(logger.info)
end
