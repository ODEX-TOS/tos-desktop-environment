local quicksort = require("tde.lib-tde.sort.quicksort")

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

local result = quicksort(data)

for index, element in ipairs(result) do
    assert(element == expected[index], "Expected: " .. expected[index] .. " but got " .. element)
end
