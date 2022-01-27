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
-- Fuzzy match strings in lua
--
-- This module implements a basic fuzzy finding algorithm
-- I currently do not have the time to make a faster, better implementation
-- This algorithm is O(n^2) which makes it bad for large strings
-- Feel free to improve it :-)
--
--
-- This fuzzy finder gives a score based on how simular 2 strings are
--
--    fuzzy.score("a", "a") -- returns 1
--    fuzzy.score("a", "ab") -- returns 0.5
--    fuzzy.score("ab", "ab") -- returns 4
--    fuzzy.score("wood", "woodcutter") -- returns 8.8
--    fuzzy.score("wood", "how much does that laptop cost?") -- returns 1.29032
--    fuzzy.score("a", "b") -- returns 0
--
-- You can also fuzzy find a query from a given list of strings
-- The fuzzy finder will then order the list to return the best string in the lowest index
--
--    fuzzy.best_score({"a", "b", "c", "1", "2", "ab"}, "a") -- returns {"a", "ab", "b", "c", "1"}
--    fuzzy.best_score({"a", "ab", "abc", "abcd", "abcde", "xyz"}, "abc", 6) -- returns {"abc", "abcd", "abcde", "ab", "a", "xyz"}
--    fuzzy.best_score({"hello", "world", "hello world", "hello, world", "hi world", "hello neighbour"}, "hello") -- returns {"hello", "hello world", "hello, world", "hello neighbour", "world", "hi world"}
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.fuzzy_find
---------------------------------------------------------------------------

local mergesort = require("lib-tde.sort.mergesort")
local mappers = require("lib-tde.mappers")


local function create_permutations(list, max_permutation_length, max_permutation_entries)
    local permutations = {}

    local active_permutation_length = #list

    if active_permutation_length > max_permutation_length then
        active_permutation_length = max_permutation_length
    end

    local char_index = 1
    local last_permutation_start_index

    while active_permutation_length > 0 do
        local to_add = active_permutation_length
        local current_permutation = ""

        last_permutation_start_index = char_index

        while to_add > 0 do
            current_permutation = current_permutation .. list[char_index]
            char_index = char_index + 1
            to_add = to_add - 1
        end

        table.insert(permutations, current_permutation)

        if #permutations > max_permutation_entries then
            return permutations
        end

        char_index = last_permutation_start_index + 1

        if char_index + active_permutation_length - 1 > #list then
            char_index = 1
            active_permutation_length = active_permutation_length - 1
        end

    end

    return permutations
end

local function escape_magic(s)
    return (s:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]','%%%1'))
  end
-- count the amount of times a match occurs in a string
local function count_matches(text, match)
    local _, count = string.gsub(text, escape_magic(match), match)
    return count
end

local function begin_location(text, match)
    local start,_,_ = string.find(text, escape_magic(match))
    return start or #text
end

--- Generate a score for how well the text matches the search query
-- the higher the score the better it matches
-- @tparam string search The substring that is used to fuzzy match
-- @tparam string text The text to fuzzy match against the search string
-- @tparam[opt] number max_permutation_length The maximum length of a permuted substring of the search string (Used to compute the score)
-- @tparam[opt] number max_permutation_entries The maximum amount to calculate the permuted search string in
-- @treturn number The score assigned to the fuzzy search
-- @staticfct score
-- @usage -- This true
-- lib-tde.fuzzy_find.score("/etc", "/etc/passwd") -- returns 7.63636 (the higher the better)
-- lib-tde.fuzzy_find.score("/etc/passwd", "/etc/passwd") -- returns 290 (the higher the better)
local function fuzzy_score(search, text, max_permutation_length, max_permutation_entries)
    local score = 0
    max_permutation_length = max_permutation_length or 20
    max_permutation_entries = max_permutation_entries or 1000

    if search == "" or search == nil or text == "" or text == nil then
        return score
    end

    local splitted_search = {}
    for letter in search:gmatch(".") do table.insert(splitted_search, letter) end

    -- create mutations of the splitted_search list
    -- eg if the list is {'a','b', 'c'} create the following permutations
    -- {'a', 'b', 'c', 'ab', 'bc', 'abc'}

    local permutations = create_permutations(splitted_search, max_permutation_length, max_permutation_entries)

    for _, permutation in ipairs(permutations) do
        local permutation_count = (count_matches(text, permutation) * #permutation)
        local begin_index = begin_location(text, permutation)

        local weighted_index = ((#text - begin_index) / #text) * #permutation

        -- We have a literal match, which we award a higher score
        if begin_index < 2 then
            weighted_index = weighted_index * #permutation
        end

        score = score + permutation_count
        score = score + weighted_index
    end

    -- now we reduce the score by the length of the search query / length of the text
    --score = score * (#search / #text)

    return score
end

--- Generate a sorted list of strings by the score of the fuzzy finding algorithm
-- The first index of the list is the best match
-- @tparam table list The list of string to fuzzy find and sort
-- @tparam string search The substring that is used to fuzzy match
-- @tparam[opt] number max_result The top x results after fuzzy finding
-- @tparam[opt] function filter_callback In case you want to fuzzy find not the element of the list itself but rather a subpropertie or a modified version of the list
-- @treturn table The sorted table based on the best fuzzy match
-- @staticfct best_score
-- @usage
-- lib-tde.fuzzy_find.best_score({"a", "ab", "abc", "abcd", "abcde", "xyz"}, "abc") -- returns {"abc", "abcd", "abcde", "ab", "a", "xyz"}
local function best_score(list, search, max_result, filter_callback, min_score)
    max_result = max_result or #list
    filter_callback = filter_callback or function(el)
        return el
    end

    local max_permutation_length  = 10
    local max_permutation_entries = 100
    min_score = min_score or 1

    local scores = {}
    for _, item in ipairs(list) do
        -- Some items can 'force' overwrite the fuzzy finding logic
        local score = item.__score or fuzzy_score(search, filter_callback(item), max_permutation_length, max_permutation_entries)
        table.insert(scores, {
            item = item,
            score = score
        })
    end

    -- now sort it based best fuzzy match
    -- our fuzzy finding algorithm is pretty basic, we check the length of the html page, count the matches of the given characters
    -- and see procentually which is closer
    scores = mergesort(scores, function(best_match, worst_match)
        return best_match.score > worst_match.score
    end)

    -- filter it to our max score list
    scores = mappers.filter(scores, function (_, index)
        return index <= max_result
    end)

    -- filter out low score
    scores = mappers.filter(scores, function (el, _)
        return el.score > min_score
    end)

    -- now map it back to the original list

    return mappers.map(scores, function(el, _)
        return el.item
    end)
end

return {
    score = fuzzy_score,
    best_score = best_score
}