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
local fuzzy = require("lib-tde.fuzzy_find")

local documentation = require("module.prompt_completions.documentation")
local calculator = require("module.prompt_completions.calculator")
local browser = require("module.prompt_completions.browser")
local ssh = require("module.prompt_completions.ssh")
local update = require("module.prompt_completions.update")
local open = require("module.prompt_completions.open")
local plugin = require("module.prompt_completions.plugin")
local tde_script = require("module.prompt_completions.tde-scripts")

local function get_completions(query)
    print("Fetching completions for: " .. tostring(query))
    local doc_completions = documentation.get_completion(query)
    local calc_completions = calculator.get_completion(query)
    local browser_completions = browser.get_completion(query)
    local ssh_completions = ssh.get_completion(query)
    local update_completions = update.get_completion(query)
    local open_completions = open.get_completion(query)
    local tde_script_completions = tde_script.get_completion(query)
    local plugin_completions = plugin.get_completion(query)

    local result = {}

    for _, v in ipairs(calc_completions) do
        v.action_name = calculator.name
        table.insert(result, v)
    end

    for _, v in ipairs(browser_completions) do
        v.action_name = browser.name
        table.insert(result, v)
    end

    for _, v in ipairs(ssh_completions) do
        v.action_name = ssh.name
        table.insert(result, v)
    end

    for _, v in ipairs(update_completions) do
        v.action_name = update.name
        table.insert(result, v)
    end

    for _, v in ipairs(tde_script_completions) do
        v.action_name = tde_script.name
        table.insert(result, v)
    end

    for _, v in ipairs(open_completions) do
        v.action_name = open.name
        table.insert(result, v)
    end

    for _, v in ipairs(doc_completions) do
        v.action_name = documentation.name
        table.insert(result, v)
    end

    for _, v in ipairs(plugin_completions) do
        v.action_name = plugin.name
        table.insert(result, v)
    end

    return fuzzy.best_score(result, query, 50, function (el)
        return el.text
    end)
end

local function perform_actions(payload, action_name)
    local actions = {}
    actions[documentation.name] = documentation.perform_action
    actions[browser.name] = browser.perform_action
    actions[ssh.name] = ssh.perform_action
    actions[update.name] = update.perform_action
    actions[open.name] = open.perform_action
    actions[tde_script.name] = tde_script.perform_action
    actions[plugin.name] = plugin.perform_action

    local executor = actions[action_name]

    if executor ~= nil then
        return executor(payload)
    else
        print("Could not execute prompt payload for: " .. tostring(action_name))
    end

end

return {
    get_completions = get_completions,
    perform_actions = perform_actions,
}