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
local filehandle = require("lib-tde.file")
local common = require("lib-tde.function.common")
local split = common.split
local trim = common.trim

local function starts_with(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local function is_ssh_login(query)
    -- if the query starts with 'ssh ' or 'ssh:' then
    if starts_with(query, "ssh ") then
        return true, trim(string.sub(query, #"ssh ", string.len(query)))
    end
    if starts_with(query, "ssh:") then
        return true, trim(string.sub(query, #"ssh:", string.len(query)))
    end

    local splitted = split(query, '@')
    if #splitted == 2 then
        return #splitted[1] > 1 and #splitted[2] > 1, query
    end
    return false, ""
end

local function get_completions(query)
    local res = {}

    local lines = filehandle.lines(os.getenv("HOME") .. "/.ssh/config")

    for _, line in ipairs(lines) do
        local parsed = line:match("Host%s+(.*)")
        if parsed then
            table.insert(res, {
                icon = icons.login,
                text = "ssh" .. "\t" .. tostring(parsed),
                payload = tostring(parsed)
            })
        end
    end

    -- if the patern username@hostname is matched then we also add the query itself
    local is_ssh, new_query = is_ssh_login(query)
    if is_ssh then
        table.insert(res, {
            icon = icons.login,
            __score = math.huge,
            text = "ssh" .. "\t" .. new_query,
            payload = new_query
        })
    end

    return res
end

local function perform_action(payload)
    local terminal = os.getenv("TERMINAL") or "st"

    local cmd = terminal .. " -e sh -c 'ssh " .. payload .." || read'"

    awful.spawn(cmd)
end

local name = "SSH"

return {
    get_completion = get_completions,
    perform_action = perform_action,
    name = name,
}