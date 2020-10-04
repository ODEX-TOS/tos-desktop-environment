-- THIS FILE IS USED TO RUN ALL TESTS

EXPORT_ASSERT_TO_GLOBALS = true
require("tests.luaunit")

require("tests.globals")
require("awful")

-- TESTS TO RUN
require("tests.helper")
require("tests.theme")
-- END OF LIST OF TESTS TO RUN

local lu = LuaUnit.new()
if not (os.getenv("RUNNER") == nil) then
    lu:setOutputType(os.getenv("RUNNER"), os.getenv("FILE"))
else
    lu:setOutputType("text")
end
os.exit(lu:runSuite())
