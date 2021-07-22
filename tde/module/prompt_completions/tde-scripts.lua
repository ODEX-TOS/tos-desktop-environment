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
local filesystem = require("lib-tde.file")

local function get_completions(_)
    local res = {}


    for _, tde_script in ipairs(filesystem.list_dir(os.getenv("HOME") .. "/.config/tde")) do
        -- check that it is a file and that it ends with .tde
        if string.sub(tde_script, #tde_script-3, #tde_script) == ".tde" and filesystem.exists(tde_script) then
            table.insert(res, {
                icon = icons.logo,
                text = i18n.translate("Run: %s", filesystem.basename(tde_script)),
                payload = tde_script
            })
        end
    end

    return res
end

local function perform_action(payload)
    local err, res = pcall(dofile, payload)
    if not err then
        return res
    end
    return res
end

local name = i18n.translate("TDE")

return {
    get_completion = get_completions,
    perform_action = perform_action,
    name = name,
}