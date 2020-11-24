local hashmap = require("tde.lib-tde.datastructure.hashmap")

map = hashmap()

for i = 1, 100000 do
    map.add(i, tostring(i))
end

for i = 1, 100000 do
    map.get(i)
    map.delete(i)
end
