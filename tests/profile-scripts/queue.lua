-- This profile shoud run in O(n) times
local list = require("lib-tde.datastructure.queue")()
for i = 1, 100000 do
    list.push(i)
end
assert(list.size() == 100000)
for _ = 1, 99999 do
    list.pop()
end
assert(list.size() == 1)
