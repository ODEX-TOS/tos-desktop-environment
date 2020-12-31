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

    assert(tree.contains("hello"), "The tree should contain 'hello'")
    assert(tree.contains("hi"), "The tree should contain 'hi'")
    assert(tree.contains("bob"), "The tree should contain 'bob'")

    assert(not tree.contains("eve"), "The tree shouldn't contain 'eve'")
end

function test_binary_tree_basics_number()
    local tree = binarytree()
    tree.insert(10)
    tree.insert(20)
    tree.insert(30)

    assert(tree.contains(10), "The tree should contain '10'")
    assert(tree.contains(20), "The tree should contain '20'")
    assert(tree.contains(30), "The tree should contain '30'")

    assert(not tree.contains(100), "The tree shouldn't contain '100'")
end

function test_binary_tree_basics_removal()
    local tree = binarytree()

    tree.insert(10)
    tree.insert(20)
    tree.insert(30)

    assert(tree.contains(10), "The tree should contain '10'")
    assert(tree.contains(20), "The tree should contain '20'")
    assert(tree.contains(30), "The tree should contain '30'")

    assert(tree.remove(10) == 10, "The tree couldn't remove the element: '10'")
    assert(not tree.contains(10), "The tree shouldn't contain the element: '10' after removal")
end

function test_binary_tree_massive()
    local tree = binarytree()

    for i = 1, 1000 do
        tree.insert(i)
    end

    for i = 1, 1000 do
        assert(tree.contains(i), "The element: '" .. tostring(i) .. "' should exist")
    end
end

function test_binary_tree_api_unit_tested()
    local tree = binarytree()
    local amount = 3
    local result = tablelength(tree)
    assert(
        result == amount,
        "You didn't test all binary tree api endpoints, please add them then update the amount to: " .. result
    )
end
