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
-- THIS FILE IS USED TO RUN ALL TESTS

-- this function gets overridden by TDE
local realPrint = print

print = function(data, logtype)
    logtype = logtype or "\27[0;32m[ INFO "
    realPrint(logtype .. " ]\27[0m " .. tostring(data or ""))
end

EXPORT_ASSERT_TO_GLOBALS = true
UNIT_TESTING_ACTIVE = true
require("tests.tde.luaunit")

require("tests.tde.globals")

-- TESTS TO RUN
require("tests.tde.check-important-modules")
require("tests.tde.config")
require("tests.tde.parser")
require("tests.tde.tutorial")
require("tests.tde.theme")
require("tests.tde.configuration")
require("tests.tde.lib-tde")
require("tests.tde.modules")

-- END OF LIST OF TESTS TO RUN

-- So we have to manually put it back in our test runner
print = realPrint
local lu = LuaUnit.new()
if not (os.getenv("RUNNER") == nil) then
    lu:setOutputType(os.getenv("RUNNER"), os.getenv("FILE"))
else
    lu:setOutputType("TEXT")
end

os.exit(lu:runSuite())
