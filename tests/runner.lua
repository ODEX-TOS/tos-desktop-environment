-- THIS FILE IS USED TO RUN ALL TESTS

-- this function gets overridden by TDE
local realPrint = print

print = function(data, logtype)
    if logtype == nil then
        logtype = "\27[0;32m[ INFO "
    end
    realPrint(logtype .. " ]\27[0m " .. data)
end

EXPORT_ASSERT_TO_GLOBALS = true
require("tests.luaunit")

require("tests.globals")

-- TESTS TO RUN
require("tests.check-important-modules")
require("tests.config")
require("tests.parser")
require("tests.tutorial")
require("tests.theme")
require("tests.configuration")
require("tests.lib-tde")

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
