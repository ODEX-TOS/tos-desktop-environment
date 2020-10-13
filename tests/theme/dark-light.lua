-- create a file with some data
local function create_file(location, value)
    file = io.open(location, "w")
    file:write(value)
    file:close()
end

-- WARNING: Be carefull with this function
-- It removes files for the filesystem
local function rm_file(location)
    os.remove(location)
end

function test_dark_light()
    assert(type(require("tde.theme.icons.dark-light")) == "function")
end

function test_dark_light_light()
    local darkLight = require("tde.theme.icons.dark-light")
    
    local light = "test.svg"
    local dark = "test.dark.svg"
    create_file(light, "")
    create_file(dark, "")

    -- a dark theme uses light background icons
    local result = darkLight(light, "dark")
    rm_file(light)
    rm_file(dark)
    assert(result == light)

    rm_file(light)
    rm_file(dark)
end

function test_dark_light_default_is_light()
    local darkLight = require("tde.theme.icons.dark-light")
    
    local light = "test.svg"
    local dark = "test.dark.svg"
    create_file(light, "")
    create_file(dark, "")

    -- a dark theme uses light background icons
    local result = darkLight(light)
    rm_file(light)
    rm_file(dark)

    assert(result == light)

end

function test_dark_light_dark()
    local darkLight = require("tde.theme.icons.dark-light")
    
    local light = "test.svg"
    local dark = "test.dark.svg"
    create_file(light, "")
    create_file(dark, "")
    -- a light theme uses dark background icons
    local result = darkLight(light, "light")
    rm_file(light)
    rm_file(dark)
    assert(result == dark)

    rm_file(light)
    rm_file(dark)

end