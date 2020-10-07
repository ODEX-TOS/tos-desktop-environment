

local ran_before = {}

-- if the command starts with a ""
local function run_once(cmd)
    if cmd == "" then
        return false
    end
    if not (type(cmd) == "string") then
        return false
    end
    if not (ran_before[cmd] == nil) then
        return false
    end
    ran_before[cmd] = true
    local findme = cmd
    local firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end
    print("Executing: " .. " " .. cmd)
    if findme == "sh" or findme == "bash" then
        awful.spawn.easy_async_with_shell(
            string.format("%s", cmd),
            function(stdout)
                print(stdout)
            end
        )
    else
        awful.spawn.easy_async_with_shell(
            string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd),
            function(stdout)
                print(stdout)
            end
        )
    end
    return true
end

return run_once
