local binarytree = require("tde.lib-tde.datastructure.binary-tree")

function test_binary_tree_basics_string()
    local tree = binarytree()
    tree.insert("hello")
    tree.insert("hi")
    tree.insert("bob")

    assert(tree.contains("hello"))
    assert(tree.contains("hi"))
    assert(tree.contains("bob"))

    assert(not tree.contains("eve"))
end

function test_binary_tree_basics_number()
    local tree = binarytree()
    tree.insert(10)
    tree.insert(20)
    tree.insert(30)

    assert(tree.contains(10))
    assert(tree.contains(20))
    assert(tree.contains(30))

    assert(not tree.contains(100))
end

function test_binary_tree_basics_removal()
    local tree = binarytree()

    tree.insert(10)
    tree.insert(20)
    tree.insert(30)

    assert(tree.contains(10))
    assert(tree.contains(20))
    assert(tree.contains(30))

    assert(tree.remove(10) == 10)
    assert(not tree.contains(10))
end

function test_binary_tree_massive()
    local tree = binarytree()

    for i = 1, 1000 do
        tree.insert(i)
    end

    for i = 1, 1000 do
        assert(tree.contains(i))
    end
end
