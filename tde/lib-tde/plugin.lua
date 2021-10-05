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
-- This module exposes helper functions for using inside of your plugin
--
-- @author Tom Meyers
-- @copyright 2021 Tom Meyers
-- @tdemod lib-tde.plugin
---------------------------------------------------------------------------
local filehandle = require("lib-tde.file")
local logger = require("lib-tde.logger")

--- Return the path to the root directory of your plugin
-- Run this only from your init.lua file
-- @staticfct path
-- @usage -- For example this will return '/home/$USER/.config/tde/<plugin_name>/'
-- require('lib-tde.plugin').path()
local function path()
    local str = debug.getinfo(2, "S").source:sub(2)
    local subdir =  str:match("(.*/)")

    local valid_parents = {
        "/etc/tde/plugins",
        os.getenv("HOME") .. "/.config/tde/"
    }
    -- the above returns either the root dir of the application or a subdir (When called from outside of init.lua)
    for _, parent in ipairs(valid_parents) do
        if parent == filehandle.dirname(subdir) then
            return subdir
        end
    end

    -- If the for above didn't return this means we are in a subdir of the plugin
    -- Let's return the parent dir then
    for _, parent in ipairs(valid_parents) do
        if string.find(subdir, "^" .. parent) ~= nil then
            return subdir:match("(" .. parent .. "[^/]*)/") .. '/'
        end
    end

    -- malformed subdir, make sure the plugin devs can see it
    print("Couldn't extract plugin root dir from location: " .. (tostring(subdir) or ""), logger.error )
    return subdir
 end

return {
    path = path
}