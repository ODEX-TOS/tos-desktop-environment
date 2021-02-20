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
-- Usage: cat file.lua | lua pretty_print.lua
-- colorizes the lua file

local RED = "\27[0;31m"
local GREEN = "\27[0;32m"
local BLUE = "\27[0;35m"
local LBLUE = "\27[0;36m"
local ORANGE = "\27[1;33m"
local COMMENT = "\27[2m"
local NC = "\27[0m"

local opperators = {
    ["~="] = 1,
    ["<="] = 1,
    [">="] = 1,
    ["<"] = 1,
    [">"] = 1,
    ["=="] = 1,
    ["="] = 1,
    ["+"] = 1,
    ["-"] = 1,
    ["*"] = 1,
    ["/"] = 1,
    ["("] = 1,
    [")"] = 1,
    ["{"] = 1,
    ["}"] = 1,
    ["["] = 1,
    ["]"] = 1,
    [";"] = 1,
    [","] = 1,
    ["."] = 1,
    [".."] = 1,
    ["..."] = 1,
    [":"] = 1,
    ["^"] = 1,
    ["%"] = 1
}
local keywords = {
    ["and"] = 1,
    ["break"] = 1,
    ["do"] = 1,
    ["else"] = 1,
    ["elseif"] = 1,
    ["end"] = 1,
    ["for"] = 1,
    ["function"] = 1,
    ["global"] = 1,
    ["if"] = 1,
    ["in"] = 1,
    ["local"] = 1,
    ["nil"] = 1,
    ["not"] = 1,
    ["or"] = 1,
    ["repeat"] = 1,
    ["return"] = 1,
    ["then"] = 1,
    ["until"] = 1,
    ["while"] = 1,
    ["arg"] = 1,
    ["self"] = 1
}
local internalVariables = {
    ["_ALERT"] = 1,
    ["_ERRORMESSAGE"] = 1,
    ["_INPUT"] = 1,
    ["_OUTPUT"] = 1,
    ["_STDERR"] = 1,
    ["_STDIN"] = 1,
    ["_STDOUT"] = 1,
    ["_PROMPT"] = 1,
    ["PI"] = 1
}
local libraryFunctions = {
    -- Basic Functions
    ["assert"] = 1,
    ["table"] = 1,
    ["insert"] = 1,
    ["call"] = 1,
    ["collectgarbage"] = 1,
    ["copytagmethods"] = 1,
    ["dofile"] = 1,
    ["dostring"] = 1,
    ["error"] = 1,
    ["foreach"] = 1,
    ["foreachi"] = 1,
    ["getglobal"] = 1,
    ["getn"] = 1,
    ["gettagmethod"] = 1,
    ["globals"] = 1,
    ["newtag"] = 1,
    ["next"] = 1,
    ["print"] = 1,
    ["rawget"] = 1,
    ["rawset"] = 1,
    ["setglobal"] = 1,
    ["settagmethod"] = 1,
    ["sort"] = 1,
    ["tag"] = 1,
    ["tonumber"] = 1,
    ["tostring"] = 1,
    ["tinsert"] = 1,
    ["tremove"] = 1,
    ["type"] = 1,
    -- String Manipulation
    ["strbyte"] = 1,
    ["strchar"] = 1,
    ["strfind"] = 1,
    ["strlen"] = 1,
    ["strrep"] = 1,
    ["strsub"] = 1,
    ["strupper"] = 1,
    ["format"] = 1,
    ["gsub"] = 1,
    -- Mathematical Functions
    ["abs"] = 1,
    ["acos"] = 1,
    ["asin"] = 1,
    ["atan"] = 1,
    ["atan2"] = 1,
    ["ceil"] = 1,
    ["cos"] = 1,
    ["deg"] = 1,
    ["exp"] = 1,
    ["floor"] = 1,
    ["log"] = 1,
    ["log10"] = 1,
    ["max"] = 1,
    ["min"] = 1,
    ["mod"] = 1,
    ["rad"] = 1,
    ["sin"] = 1,
    ["sqrt"] = 1,
    ["tan"] = 1,
    ["frexp"] = 1,
    ["ldexp"] = 1,
    ["random"] = 1,
    ["randomseed"] = 1,
    -- I/O Facilities
    ["openfile"] = 1,
    ["closefile"] = 1,
    ["readfrom"] = 1,
    ["writeto"] = 1,
    ["appendto"] = 1,
    ["remove"] = 1,
    ["rename"] = 1,
    ["flush"] = 1,
    ["seek"] = 1,
    ["tmpname"] = 1,
    ["read"] = 1,
    ["write"] = 1,
    -- System Facilities
    ["clock"] = 1,
    ["date"] = 1,
    ["execute"] = 1,
    ["exit"] = 1,
    ["getenv"] = 1,
    ["setlocale"] = 1,
    ["require"] = 1
}

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local result = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(result, str)
    end
    local separators = {}
    for sep_2 in string.gmatch(inputstr, "([" .. sep .. "]+)") do
        table.insert(separators, sep_2)
    end
    return result, separators
end

local function is_string(token)
    return string.sub(token, 1, 1) == '"' and string.sub(token, #token, #token + 1) == '"'
end

local function is_variable(token)
    return string.match(token, "^[a-zA-Z][a-zA-Z0-9_]*$") ~= nil
end

local function is_number(token)
    return tonumber(token) ~= nil
end

-- in case we don't match
local function sub_divide(sub_divided_token, depth)
    if (depth == nil) then
        depth = 1
    end
    local tokens, separators = split(sub_divided_token, "(,)")
    local last_char
    for index, token in ipairs(tokens) do
        last_char = string.sub(token, #token, #token + 1)
        if last_char == "(" or last_char == "," or last_char == ")" then
            tokens[index] = string.sub(token, 1, #token - 1)
        end
    end
    return (#tokens > 1 or last_char ~= nil) and depth < 5, tokens, separators, depth + 1
end

local function tokenize_lines(line, splitted, separators, token_depth)
    local tokens = {}

    local new_line, comment = string.match(line, "^(.*)(%-%-.*)")
    if new_line ~= nil then
        line = new_line
    end

    local match = string.match(line, "^( *)")
    if match ~= nil then
        table.insert(
            tokens,
            {
                text = match,
                bIsColored = false
            }
        )
    end

    if splitted == nil then
        splitted = split(line, " ")
    end

    if separators == nil then
        separators = {}
    end

    for index, token in ipairs(splitted) do
        if opperators[token] == 1 then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = RED
                }
            )
        elseif libraryFunctions[token] == 1 then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = BLUE
                }
            )
        elseif internalVariables[token] == 1 or keywords[token] == 1 then
            -- TODO: strings with spaces is broken
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = RED
                }
            )
        elseif is_string(token) then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = GREEN
                }
            )
        elseif is_variable(token) then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = LBLUE
                }
            )
        elseif is_number(token) then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = ORANGE
                }
            )
        else
            local bSubdividable, splitted_tokens, splitted_separators, depth = sub_divide(token, token_depth)
            if bSubdividable then
                for _, sub_divided_token in ipairs(tokenize_lines(token, splitted_tokens, splitted_separators, depth)) do
                    table.insert(tokens, sub_divided_token)
                end
            else
                table.insert(
                    tokens,
                    {
                        text = token,
                        bIsColored = true,
                        color = BLUE
                    }
                )
            end
        end

        if separators[index] ~= nil then
            table.insert(
                tokens,
                {
                    text = separators[index],
                    bIsColored = true,
                    color = RED
                }
            )
        end
    end

    if comment ~= nil then
        table.insert(
            tokens,
            {
                text = comment,
                color = COMMENT,
                bIsColored = true
            }
        )
        return tokens
    end

    return tokens
end

-- find tokens in all lines
-- and append newlines after each line
local function tokenize_content(lines)
    local tokens = {}

    for _, line in ipairs(lines) do
        local line_tokens = tokenize_lines(line)
        for _, line_token in ipairs(line_tokens) do
            table.insert(tokens, line_token)
        end
        table.insert(
            tokens,
            {
                bIsColored = false,
                text = "\n"
            }
        )
    end

    return tokens
end

-- colorize the list of tokens found
local function colorize(tokens)
    local result = ""
    for _, token in ipairs(tokens) do
        if token.bIsColored then
            result = result .. token.color .. token.text .. " " .. NC
        else
            result = result .. token.text
        end
    end
    return result
end

local function ParseFile(fileContent)
    local lines = {}
    for s in fileContent:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    local tokens = tokenize_content(lines)
    io.write(colorize(tokens))
end

local t = io.read("*all")
ParseFile(t)
