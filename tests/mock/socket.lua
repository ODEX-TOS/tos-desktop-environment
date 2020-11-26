return {
    -- returns time in seconds with a resolution of 10000 th of a second
    gettime = function()
        return 89.19192
    end,
    -- emulate udp behaviour
    udp = function()
        return {
            setpeername = function(name, value)
            end,
            getsockname = function()
                return "0.0.0.0"
            end
        }
    end
}
