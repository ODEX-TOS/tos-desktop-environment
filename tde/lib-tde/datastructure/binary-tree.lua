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
---------------------------------------------------------------------------
-- Lua implementation of a Binary Search Tree
--
-- This binary Tree is not the most efficient implementation in terms of insertion or removal
--
-- Time complexity:
--
-- * `Lookup element`    O(log(n))
-- * `Insert element`    O(n)
-- * `Remove element`    O(n)
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.datastructure.binary-tree
---------------------------------------------------------------------------

--- Create a new Binary Search Tree (BST)
-- @treturn table A table containing the BST methods
-- @staticfct lib-tde.datastrucuture.binary-tree
-- @usage -- This will create a new empty binary tree
-- lib-tde.datastrucuture.binarytree()
return function()
    local Node = {}

    Node.__index = Node

    function Node:new(data)
        -- luacheck: ignore 412
        local self = {}

        self._data = data
        self.left = nil
        self.right = nil

        setmetatable(self, Node)
        return self
    end

    function Node:data()
        return self._data
    end

    local _tree = {}

    local function contains(node, data)
        if node:data() == data then
            return true
        elseif data < node:data() then
            if node.left ~= nil then
                return contains(node.left, data)
            end
        else
            if node.right ~= nil then
                return contains(node.right, data)
            end
        end

        return false
    end

    --- Check if an element is present in the binary tree
    -- @tparam object data The data to look for in the tree
    -- @staticfct lib-tde.datastrucuture.binary-tree.contains
    -- @usage -- Check if "tde" exists (in O(log(n)) time)
    -- tree.contains("tde")
    local function _contains(data)
        if _tree._root == nil then
            return false
        end

        return contains(_tree._root, data)
    end

    local function insert(node, data)
        if data >= node:data() then
            if node.right == nil then
                local nodeNew = Node:new(data)
                node.right = nodeNew
            else
                node.right = insert(node.right, data)
            end
        else
            if node.left == nil then
                local nodeNew = Node:new(data)
                node.left = nodeNew
            else
                node.left = insert(node.left, data)
            end
        end

        return node
    end

    --- Insert an element into the binary tree, not that insertion can be rather expensive
    -- @tparam object data The data to insert
    -- @staticfct lib-tde.datastrucuture.binary-tree.insert
    -- @usage -- Insert "tde" into the tree
    -- tree.insert("tde")
    local function _insert(data)
        if _tree._root == nil then
            local node = Node:new(data)
            _tree._root = node
            return
        end

        _tree._root = insert(_tree._root, data)
    end

    local function remove(node, data)
        if data > node:data() then
            if node.right == nil then
                return node, nil
            else
                node.right = remove(node.right, data)
            end
        elseif data < node:data() then
            if node.left == nil then
                return node, nil
            else
                node.left = remove(node.left, data)
            end
        else
            if node.left == nil and node.right == nil then
                return nil, data
            elseif node.left == nil then
                node = node.right
            elseif node.right == nil then
                node = node.left
            else
                node._data = node.right:data()
                node.right = remove(node.right, node:data())
            end
        end

        return node, data
    end

    --- Remove an element from the tree
    -- @tparam object data The data to remove from the tree
    -- @staticfct lib-tde.datastrucuture.binary-tree.remove
    -- @usage -- Remove tde from the tree
    -- tree.remove("tde")
    local function _remove(data)
        if _tree._root == nil then
            return nil
        end
        local popped
        _tree._root, popped = remove(_tree._root, data)

        return popped
    end

    return {
        remove = _remove,
        insert = _insert,
        contains = _contains
    }
end
