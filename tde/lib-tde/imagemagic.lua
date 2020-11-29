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
-- @usage
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

--- Convert your image to be grayscale
-- @tparam input string The path to the original image
-- @tparam output string The path where you want to save the grayscaled image to
-- @tparam callback function The function to trigger when the image is generated
-- @staticfct grayscale
-- @usage
--    lib-tde.imagemagic.grayscale("file.png", "gray.png", function()
--        print("Finished generating a grayscale image")
--    end)
local function grayscale(input, output, callback)
    -- perform sanity check to make sure the rest works
    if check() then
        return
    end
    local cmd = "convert " .. input .. " -type Grayscale " .. output
    awful.spawn.easy_async_with_shell(
        cmd,
        function()
            print("Finished converting image " .. input .. " to grayscale")
            callback()
        end
    )
end

--- Make a color in an image transparent
-- @tparam input string The path to the original image
-- @tparam output string The path where you want to save the transparent image to
-- @tparam color string The color to make transparent in hex
-- @tparam callback function The function to trigger when the image is made transparent
-- @staticfct transparent
-- @usage
--    lib-tde.imagemagic.transparent("file.png", "out.png", "#FFFFFF", function()
--        print("Finished making the image transparent")
--    end)
local function transparent(input, output, color, callback)
    -- perform sanity check to make sure the rest works
    if check() then
        return
    end
    local cmd = "convert " .. input .. " -fuzz 10% -transparent " .. color .. " " .. output
    awful.spawn.easy_async_with_shell(
        cmd,
        function()
            print("Finished color " .. color .. " to be transparent in " .. input)
            callback()
        end
    )
end

--- Compress an image to save disk space and memory consumption
-- @tparam input string The path to the original image
-- @tparam output string The path where you want to save the compressed image to
-- @tparam rate number The amount of quality to keep in percentage
-- @tparam callback function The function to trigger when the image is compressed
-- @staticfct compress
-- @usage
--    lib-tde.imagemagic.compress("file.png", "out.png", 85, function()
--        print("Finished compressing image")
--    end)
local function compress(input, output, rate, callback)
    -- perform sanity check to make sure the rest works
    if check() then
        return
    end
    local cmd =
        "convert " ..
        input ..
            "-sampling-factor 4:2:0 -strip -quality " .. tostring(rate) .. " -interlace JPEG -colorspace RGB " .. output
    awful.spawn.easy_async_with_shell(
        cmd,
        function()
            print("Finished compressing " .. input)
            callback()
        end
    )
end

--- Convert from one image type to another
-- @tparam input string The path to the original image
-- @tparam output string The path where you want to save the new image to
-- @tparam callback function The function to trigger when the image is converted
-- @staticfct convert
-- @usage
--    lib-tde.imagemagic.convert("file.png", "file.jpg", function()
--        print("Finished converting image")
--    end)
local function convert(input, output, callback)
    -- perform sanity check to make sure the rest works
    if check() then
        return
    end
    local cmd = "convert " .. input .. " " .. output
    awful.spawn.easy_async_with_shell(
        cmd,
        function()
            print("Finished converting from " .. input .. " to " .. output)
            callback()
        end
    )
end

return {
    scale = scale,
    grayscale = grayscale,
    transparent = transparent,
    compress = compress,
    convert = convert
}
