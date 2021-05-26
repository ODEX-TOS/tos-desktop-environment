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

-- A simple code completion printer
-- If given a table it returns all indices back
-- If given a string it is interpreted
-- If nothing is supplied we treath it as _G
-- luacheck: ignore 121
function get_completion(object, start)
    start = start or '_G'
    if type(object) == "string" then
        local func = load("__comp_result=" .. object)
        local status, _ = pcall(func)
        if not status then
            return
        end
        return get_completion(_G.__comp_result, object)
    elseif type(object) == "table" then
        local result = ""
        for key, _ in pairs(object) do
            result = result .. start .. '.' .. key .. '\n'
        end
        return result
    else
        return get_completion(_G, '_G')
    end
end