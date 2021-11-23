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
local quicksort = require("tde.lib-tde.sort.quicksort")
local radixsort = require("tde.lib-tde.sort.radixsort")
-- On average mergesort is the fastest
local mergesort = require("tde.lib-tde.sort.mergesort")

local data = {}
local expected = {}
for i = 1, 10000 do
    expected[i] = i
end

-- shuffle the data
for _, v in ipairs(expected) do
    local pos = math.random(1, #data + 1)
    table.insert(data, pos, v)
end

local result = mergesort(data)

for index, element in ipairs(result) do
    print(element)
    assert(element == expected[index], "Expected: " .. expected[index] .. " but got " .. element)
end
