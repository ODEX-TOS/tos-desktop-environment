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
---------------------------------------------------------------------------
-- This module can change colors in an svg file
--
-- The working principle behind this is to make a copy of the svg file and override all matches of color to replace, with a new color
--
--    lib-tde.function.svg.colorize("/path/to/file.svg". "#ffffff", "#000000") -- returns /tmp/tde.svg.XXXXXX/file.svg.YYYYYY
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.svg
---------------------------------------------------------------------------

local filehandle = require("lib-tde.file")
local signals = require("lib-tde.signals")


local tmp_dir = filehandle.mktempdir("/tmp/tde.svg.XXXXXX")
filehandle.dir_create(tmp_dir)

signals.connect_exit(function()
    filehandle.rm(tmp_dir)
end)


local colorized_cache = {}

--- Modify a given color inside an svg file to another color
-- @tparam string svg The path to the svg file
-- @tparam string color_to_replace The color to search for in the given svg and replace it
-- @tparam string substitute The color to replace `color_to_replace` with
-- @staticfct colorize
-- @usage local new_svg = lib-tde.function.colorize("/path/to/file.svg", "#FF00FF", "#00FF00")
local function colorize(svg, color_to_replace, substitute)
    if svg == nil then
        return ""
    end

    if color_to_replace == nil then
        return ""
    end

    if substitute == nil then
        return ""
    end

    if color_to_replace == substitute then
        return svg
    end

    -- In case we already computed this specific svg file with the computed endresult
    if colorized_cache[svg .. color_to_replace .. substitute] ~= nil then
        return colorized_cache[svg .. color_to_replace .. substitute]
    end

    local new_file_path = filehandle.mktemp(tmp_dir .. '/' .. filehandle.basename(svg) .. ".XXXXXX")

    if filehandle.exists(new_file_path) then
        filehandle.rm(new_file_path)
    end

    -- make sure we have a copy of the svg file, that hasn't been modified yet
    filehandle.copy_file(svg, new_file_path)

    -- now we do a search and replace on the color_to_replace in the freshly generated svg file
    local data = filehandle.string(new_file_path)
    data = string.gsub(data, color_to_replace, substitute)
    filehandle.overwrite(new_file_path, data)

    colorized_cache[svg .. color_to_replace .. substitute] = new_file_path

    -- the new modified svg file
    return new_file_path
end


return {
    colorize = colorize
}