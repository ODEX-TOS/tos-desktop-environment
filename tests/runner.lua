-- THIS FILE IS USED TO RUN ALL TESTS

-- this function gets overridden by TDE
local realPrint = print

EXPORT_ASSERT_TO_GLOBALS = true
require("tests.luaunit")

require("tests.globals")

-- TESTS TO RUN
require("tests.check-important-modules")
require("tests.config")
require("tests.parser")
require("tests.tutorial")
require("tests.lib-tde")
require("tests.theme")
require("tests.configuration")
-- END OF LIST OF TESTS TO RUN

-- So we have to manually put it back in our test runner
print = realPrint

local lu = LuaUnit.new()
if not (os.getenv("RUNNER") == nil) then
    lu:setOutputType(os.getenv("RUNNER"), os.getenv("FILE"))
else
    lu:setOutputType("text")
end
os.exit(lu:runSuite())
