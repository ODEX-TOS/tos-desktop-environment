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

local function get_completions(query)
    local res = {}

    if filehandle.exists(query) or filehandle.dir_exists(query) then
      table.insert(res, {
          icon = icons.dir,
          text = i18n.translate("Open %s", query),
          payload = tostring(query),
          __score = math.huge
      })
    -- We don't want to show the create directory item for all completions, only when typing in a directory path
    elseif string.find(query, '/') then
        table.insert(res, {
            icon = icons.dir,
            text = i18n.translate("Create directory %s", query),
            payload = tostring(query),
            __score = math.huge
        })
    end

    -- make sure that the resulting text always cleanly shows one '/' character to delimit the path
    -- eg /home//user becomes /home/user
    --query = string.gsub(query .. '/', '%/+', '/')


    -- next we look up the basename of the query, if that exists add all subdirectories to the query
    local base = filehandle.dirname(query)
    if base ~= nil and filehandle.dir_exists(base) then
        for _, dir in ipairs(filehandle.list_dir(base)) do
            table.insert(res, {
                icon = icons.dir,
                text = i18n.translate("Open %s", dir),
                payload = tostring(dir)
            })
        end
    end

    return res
end

local function perform_action(payload)
    -- In case the file/directory doesn't exist and we are executing this action we will create it for you and then open it
    print("Opening payload: " .. payload)

    -- Only create a dir if it doesn't exist and contains a /
    if not filehandle.dir_exists(payload) and not filehandle.exists(payload) and string.find(payload, '/') then
        filehandle.dir_create(payload)
    end

    local cmd = "open " .. payload
    awful.spawn(cmd, false)
end

local function perform_tab_completion(payload, _)
    if filehandle.dir_exists(payload) then
        return payload .. "/"
    end

    return payload
end

local name = i18n.translate("Files")

return {
    get_completion = get_completions,
    perform_action = perform_action,
    perform_tab_completion = perform_tab_completion,
    name = name,
}