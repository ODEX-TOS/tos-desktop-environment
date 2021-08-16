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
local plugins = require("lib-tde.plugin-loader")("prompt")

local signals = require("lib-tde.signals")

signals.connect_add_plugin(function (location, plugin)
    if location ~= "prompt" then
        return
    end

    table.insert(plugins, plugin)
end)

local function get_completions(query)
    local res = {}

    for index, plugin in ipairs(plugins) do
        -- validate the plugin
        if type(plugin["get_completion"]) ~= "function" then
            return
        end
        if type(plugin["name"]) ~= "string" then
            return
        end
        local completions = plugin.get_completion(query)
        for _, completion in ipairs(completions) do
            local payload = completion.payload
            completion.payload = {
                load = payload,
                __plugin_index__ = index
            }
            table.insert(res, completion)
        end
    end

    return res
end

local function perform_action(payload)
    if type(payload) ~= "table" then
        return
    end
    if type(payload["__plugin_index__"]) ~= "number" then
        return
    end
    local plugin = plugins[payload["__plugin_index__"]]

    if type(plugin["perform_action"]) ~= "function" then
        return
    end

    plugin.perform_action(payload.load)
end

local name = "prompt plugin"

return {
    get_completion = get_completions,
    perform_action = perform_action,
    name = name,
}