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
local file_exists = require("lib-tde.file").exists
local split = require("lib-tde.function.common").split

local function extract(line)
    local splitted = split(line, "=")
    if splitted[1] == nil or splitted[2] == nil then
        return nil
    end
    return splitted[1]:gsub("%s+", ""), splitted[2]:gsub("%s+", ""):gsub('"', ""):gsub("'", ""):gsub("`", "")
end

local function parse_file(file)
    local lines = {}
    for line in io.lines(file) do
        if not (line:sub(1, 1) == "#") then
            line = split(line, "#")[1]
            local data, payload = extract(line)
            if not (data == nil) then
                if type(lines[data]) == "table" then
                    table.insert(lines[data], payload)
                elseif lines[data] == nil then
                    lines[data] = payload
                else
                    lines[data] = {lines[data]}
                    table.insert(lines[data], payload)
                end
            end
        end
    end
    return lines
end

return function(file)
    if not (type(file) == "string") then
        return {}
    end
    print("Parsing file: " .. file)
    if file_exists(file) then
        local result = parse_file(file)
        print("Finished parsing file: " .. file)
        return result
    end
    return {}
end
