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
local filehandle = require("lib-tde.file")
local mappers = require("lib-tde.mappers")
local fuzzy = require("lib-tde.fuzzy_find")

-- this function helps with finding the browser and going to it's tag when opening the documentation
local function find_browser()
    local name = {"firefoxdeveloperedition", "firefox", "nightly", "Chromium", "Google-chrome", "Brave-browser", "Vivaldi-stable", "Opera"}
    for _, c in ipairs(client.get()) do

        local match = mappers.reduce(name, function(accumulator, element, _)
            if element == c.class then
                return true
            end
            return accumulator
        end, false)

        if c.urgent or match then
            c.first_tag:view_only()
            return
        end
    end
end

local function find_local_docs()
        -- check if the docs exist in the usual location
        local locations = {"/usr/share/doc/tde/doc", "/usr/share/doc/awesome/doc"}
        for _, dir in ipairs(locations) do
            if filehandle.dir_exists(dir) then
                return dir
            end
        end
end

local function index_files(dir, file_regex)
    return mappers.filter(filehandle.list_dir_full(dir), function (file, _)
        return string.find(file, file_regex)
    end)
end

local function find_best_file_match(search_query, files)
    return fuzzy.best_score(files, search_query, 10, function(file)
        return filehandle.basename(file)
    end)
end

local function open_doc(doc)
    find_browser()
    if type(doc) == "string" then
        awful.spawn("xdg-open '" .. doc .. "'", false)
        return
    end

    awful.spawn("xdg-open https://tos.odex.be/docs", false)
end

if _G.docs == nil then
    docs = function(search_query, bShouldNotLaunch)
        bShouldNotLaunch = bShouldNotLaunch or false
        search_query = search_query or "index.html"

        -- check if the docs exist in the usual location
        local dir = find_local_docs()
        if dir == nil then
            -- no local files were found, opening the url to the release version of the documentation
            if not bShouldNotLaunch then
                open_doc()
            end
            return
        end

        -- we found our documentation directory :)
        -- now lets index this directory and search for the given search query, only including .html files
        local files = index_files(dir, "html$")

        local scores = find_best_file_match(search_query, files)
        if #scores == 0 then
            if not bShouldNotLaunch then
                open_doc(dir .. "/index.html")
            end
            return scores
        end

        if not bShouldNotLaunch then
            open_doc(scores[1].file)
        end

        return scores
    end
end
return {
    find_browser = find_browser,
    open_doc = open_doc,
}
