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
