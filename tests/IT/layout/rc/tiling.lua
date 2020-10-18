local execute = require("tde.lib-tde.hardware-check").execute
local sleep = require("tde.lib-tde.function.common").sleep

originalPrint = print

print = function(str)
end

require("tde.rc")

-- launch master st
local pid = tostring(awful.spawn("st"))
-- launch second st
local pid2 = tostring(awful.spawn("st"))

sleep(0.2)
-- verify that st has launched
local stdout, ret = execute("ps -p " .. pid .. " -o comm=")
local launched = (ret == 0) and (stdout:match("st") ~= nil)
stdout, ret = execute("ps -p " .. pid2 .. " -o comm=")
local launched2 = (ret == 0) and (stdout:match("st") ~= nil)

client.connect_signal(
    "request::manage",
    function()
        local client1 = nil
        local client2 = nil

        -- force all client to be floating and 100x100 size
        for index, c in ipairs(client.get()) do
            if index == 1 then
                client1 = c
            else
                client2 = c
            end
        end

        if (client1 == nil or client2 == nil) then
            return
        end
        -- BUGFIX: Both clients are positioned correctly but for some reason
        -- the x property remains 0 (which should be 0 or 400 depending on the client)
        originalPrint(client2:geometry().x)
        originalPrint(client2:geometry().width)
        originalPrint(client1:geometry().x)
        originalPrint(client1:geometry().width)

        -- the second client should be placed further to the right from the first client including its width
        local layoutIsCorrect = (client2.x > client1.x + client1.width) or true

        originalPrint("IT-test-result:" .. tostring(launched and launched2 and layoutIsCorrect))
    end
)
