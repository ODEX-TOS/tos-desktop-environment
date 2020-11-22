---------------------------------------------------------------------------
-- Lua implementation of quicksort
--
-- Quicksort is a divide and concore approach to sorting
-- This is a crude implementation that provides decent sorting in most usecases
-- However, it might not be the most optimal sorting algorithm for your case.
-- This module can have the comparision replaced by the user, so that you can also sort tables, numbers, strings etc
--
-- The default comparison function looks as followed:
--
--    function compare(smaller, bigger)
--        return smaller < bigger
--    end
--
-- You can override it using
--
--    quicksort(list, func) -- where func it the new comparison function
--
-- Default usage is as followed:
--
--    local list = {10, 20, 15, 7, 12, 19}
--    local sorted = quicksort(list) -- looks like this: {7, 10, 12, 15, 19, 20}
--
-- Time complexity:
--
-- * `Lookup element`   O(n log(n) ) with worst case n²
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.datastructure.hashmap
---------------------------------------------------------------------------

--- Create a new hashmap
-- @treturn table A table containing the hashmap methods
-- @staticfct lib-tde.datastrucuture.hashmap
-- @usage -- This will create a new empty hashmap
-- lib-tde.datastrucuture.hashmap()
return function(arr, func)
    -- set our comparison function to the internal one or to the one provided by the user
    local comparision = function(smaller, bigger)
        return smaller < bigger
    end
    if type(func) == "function" then
        comparision = func
    end

    local function partition(list, low, high)
        local pivot = list[high]
        local index = low
        for j = low, high do
            if comparision(list[j], pivot) then
                local temp = list[index]
                list[index] = list[j]
                list[j] = temp
                index = index + 1
            end
        end
        local temp = list[index]
        list[index] = list[high]
        list[high] = temp
        return index
    end

    local function quicksort(list, low, high)
        if comparision(low, high) then
            local part = partition(list, low, high)
            quicksort(list, low, part - 1)
            quicksort(list, part + 1, high)
        end
    end

    quicksort(arr, 1, #arr)

    return arr
end
