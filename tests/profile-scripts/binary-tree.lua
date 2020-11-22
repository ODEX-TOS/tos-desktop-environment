local tree = require("tde.lib-tde.datastructure.binary-tree")()

for i = 1, 1000 do
    tree.insert(i)
end

for i = 1, 1000 do
    assert(tree.contains(i))
end
