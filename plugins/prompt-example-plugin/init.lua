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
local icons = require("theme.icons")

-- This function should return a completion list
-- This list will be displayed in the prompt
-- The supplied query is the search string the user typed in
-- The function should return a list of elements with the following properties:
-- icon -> a string pointing to an image on the filesystem - or a cairo surface
-- text -> a string showing the text to the end user in the prompt
-- payload -> a custom object that will be passed to the `perform_action` function when this item is selected
local function get_completions(query)
    return {
        {
            icon = icons.unknown,
            text = "Plugin completion for: " .. tostring(query),
            payload = query,
            __score = math.huge -- optional argument to override the place in the prompt to appear
        }
    }
end

-- This function will be called when an item from this plugin is selected in the prompt
-- The payload parameter is the payload you supplied in the `get_completions` function
-- You can perform the action here that the end user requested, for example open a webpage, login via ssh, open an application etc
local function perform_action(payload)
    print("Prompt example plugin got payload: " .. payload)
end

-- This function allows you to tab complete a query for faster searching
-- The payload parameter is the payload you supplied in the `get_completions` function
-- The query parameter is the search string the user typed in
-- Return a string represeting the completed query
local function get_tab_completion(payload, query)
    return "Plugin completion for: " .. query .. " with payload: " .. payload
end


return {
    get_completion = get_completions,
    perform_action = perform_action,
    get_tab_completion = get_tab_completion,

    -- Don't forget to change this name to the name of your plugin
    name = "example plugin"
}