_G.awful = {
    spawn = {
        easy_async = function(cmd, callback)
            local handle = assert(io.popen(cmd, "r"))
            local commandOutput = assert(handle:read("*a"))
            local returnTable = {handle:close()}

            callback(commandOutput, "", "", returnTable[3])
        end
    }
}