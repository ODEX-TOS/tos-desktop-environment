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
local find_browser = require("module.docs").find_browser
local common = require("lib-tde.function.common")
local split = common.split

local function starts_with(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local function is_uri(uri)
    -- TODO: Add more uri schemes that the browser supports
    local supported_schemes = {"http", "https", "ftp", "mailto", "phone", "file"}
    for _, scheme in ipairs(supported_schemes) do
        if starts_with(uri, scheme .. "://") then
            return true, uri
        end
    end

    -- now check if it is perhaps a domain name in the form of <domain_name>.<tld>
    local splitted = split(uri, '%.')

    if #splitted >= 2 then
        return true, "https://" .. uri
    end

    return false, ""
end

local function get_completions(query)
    local res = {}

    local bIsUri, uri = is_uri(query)
    if  bIsUri then
        table.insert(res, {
            icon = icons.search,
            text = i18n.translate("Open in browser: %s", "\t" .. tostring(uri)),
            payload = tostring(uri)
        })
    else
        table.insert(res, {
            icon = icons.search,
            text = i18n.translate("Open in browser: %s", "\t" .. tostring(query)),
            payload = "https://www.google.com/search?q=" .. tostring(query)
        })
    end

    return res
end

local function perform_action(payload)
    awful.spawn.easy_async("xdg-open '" .. payload .. "'", function()
        find_browser()
    end)
end

local name = "Browser"

return {
    get_completion = get_completions,
    perform_action = perform_action,
    name = name,
}