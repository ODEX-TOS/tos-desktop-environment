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
local hardware = require("lib-tde.hardware-check")

local function get_update_function(callback, index)
    if index == nil then
        index = 0
    end

    local lookup_table = {
        {app = "pacman", exec = "sudo pacman -Syu"},
        {app = "yay", exec = "yay -Syu"},
        {app = "tos", exec = "tos -Syu"},
        {app = "apt", exec = "sudo apt update && sudo apt upgrade"},
        {app = "yum", exec = "sudo yum update"}
    }

    local updater = lookup_table[index + 1]
    hardware.has_package_installed(updater.app, function(exists)
        if exists then
            callback(updater.exec)
        else
            get_update_function(callback, index+1)
        end
    end)
end

local update_packages_cmd
get_update_function(function(cmd)
    update_packages_cmd = cmd
end)

local function get_completions(_)
    local res = {}
    if update_packages_cmd ~= nil then
        table.insert(res, {
            icon = icons.download,
            text = i18n.translate("System Updates"),
            payload = update_packages_cmd
        })
    end

    return res
end

local function perform_action(payload)
    local terminal = os.getenv("TERMINAL") or "st"

    local cmd = terminal .. " -e " .. payload

    awful.spawn(cmd)
end

local name = i18n.translate("Update")

return {
    get_completion = get_completions,
    perform_action = perform_action,
    name = name,
}