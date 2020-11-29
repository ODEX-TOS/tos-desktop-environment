---------------------------------------------------------------------------
-- Lua wrapper around imagemagic.
--
-- This module exposes the imagemagic api. However it is far from complete
-- If some functionality is missing please create a ticket in github or merge a PR
-- Imagemagic is extensive and this module only implements what we use in TDE
--
-- Some images that the user provide are way to large and consume to much resources
-- This can be solved by creating a "thumbnail" of the image, the syntax looks as followed
--
--    -- scale the image to 300x200 pixels and store it in out.png
--    lib-tde.imagemagic.scale("file.png", 300, 200, "out.png", function()
--        print("Finished scalling image")
--    end)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.imagemagic
---------------------------------------------------------------------------
local hardware = require("lib-tde.hardware-check")

local is_installed = hardware.has_package_installed("imagemagick")

local LOG_ERROR = "\27[0;31m[ ERROR "

local function check()
    if not is_installed then
        print("Cannot use imagemagic api, it is not installed!", LOG_ERROR)
    end
    return not is_installed
end

--- Scale an image to a specific size
-- @tparam input string The path to the original image
-- @tparam width number The width of the scaled image in pixels
-- @tparam height number The height of the scaled image in pixels
-- @tparam output string The path where you want to save the scaled image to
-- @tparam callback function The function to trigger when the image is scalled

-- @staticfct scale
-- @usage -- This true
--    lib-tde.imagemagic.scale("file.png", 300, 200, "out.png", function()
--        print("Finished scalling image")
--    end)
local function scale(input, width, height, output, callback)
    -- perform sanity check to make sure the rest works
    if check() then
        return
    end
    local cmd = "convert " .. input .. " -resize " .. width .. "x" .. height .. " " .. output
    awful.spawn.easy_async_with_shell(
        cmd,
        function()
            print("Finished converting image " .. input .. " to " .. width .. "x" .. height)
            callback()
        end
    )
end

return {
    scale = scale
}
