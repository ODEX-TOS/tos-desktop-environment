-- This file overrides existing global vaiables in TDE with mock implementations

awesome = {
    conffile = os.getenv("PWD"),
    connect_signal = function(location)
        print("Awesome signal connector: " .. location)
    end,
    register_xproperty = function()
    end
}

client = {
    connect_signal = function(location)
        print("Awesome signal connector: " .. location)
    end,
    get = function()
    end
}

screen = {
    connect_signal = function(location)
        print("Awesome signal connector: " .. location)
    end,
    set_index_miss_handler = function()
    end,
    set_newindex_miss_handler = function()
    end,
    primary = {
        dpi = 100
    }
}
mouse = {
    screen = ""
}
