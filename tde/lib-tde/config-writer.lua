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
-- Write/override a configuration file to contain new settings.
--
-- Useful when you want to override user settings.
-- Such as in the settings app.
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.config-writer
---------------------------------------------------------------------------

local parser = require("parser")
local file_handle = require("lib-tde.file")

--- Update an entry in a configuration file
-- @tparam string file The path to the file, can be both absolute or relative.
-- @tparam string field The specific configuration field to update
-- @tparam string value The value that the configuration field should contain
-- @treturn bool if the write was successful
-- @staticfct update_entry
-- @usage -- This will create the content in hallo.txt to var=value
-- lib-tde.file.update_entry("hallo.txt", "var", "value")
local function update_entry(file, field, value)
    if not file_handle.exists(file) then
        return false
    end
    -- lets parse the existing file
    local parsed = parser(file)
    -- our field doesn't exist, let's add it
    if parsed[field] == nil then
        print("Appending file")
        file_handle.write(file, "\n" .. field .. '="' .. value .. '"\n')
        return true
    end
    -- our field already exists, we need to alter them
    local lines = file_handle.lines(file)
    local result = ""
    for i, line in ipairs(lines) do
        if string.match(line, "^ *" .. field .. ' *= *[\'"].*[\'"]') then
            result = result .. field .. '="' .. value .. '"\n'
        else
            -- otherwise a lot of newlines will appear in the config file
            if not (i == #lines) then
                result = result .. line .. "\n"
            else
                result = result .. line
            end
        end
    end
    print("Overwriting file")
    return file_handle.overwrite(file, result)
end

return {update_entry = update_entry}
