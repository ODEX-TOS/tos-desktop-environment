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

-- This is a crude implementation of a lexer that then colorizes the input tokens
-- Feel free to make this program better (It can easily be improved)
-- I just don't want to invest the time as this is mainly used in tde-client
-- and tde-client is usually a one-liner

-- dracula theme (https://draculatheme.com/contribute)
local keyword_color = "#ff79c6"
local operation_color = "#ff5555"
local number_color = "#bd93f9"
local comment_color = "#6272a4"
local string_color = "#f1fa8c"
local variable_color = "#f8f8f2"
local internal_variables_color = "#bd93f9"
local special_chars_color = "#ffb86c"
local plain_color = "#ffb86c"
local function_call_color = "#50fa7b"

--[[local RED = "\27[0;31m"
local GREEN = "\27[0;32m"
local BLUE = "\27[0;35m"
local LBLUE = "\27[0;36m"
local ORANGE = "\27[1;33m"
local COMMENT = "\27[2m"
]]
local NC = "\27[0m"

local function todec(hex_str)
    local decimal = tonumber(hex_str, 16) or 255
    return tostring(decimal)
end

local function color_to_escape_sequence(color)
    local r = todec(string.sub(color, 2, 3) or "FF")
    local g = todec(string.sub(color, 4, 5) or "FF")
    local b = todec(string.sub(color, 6, 7) or "FF")
    return "\27[38;2;" .. r .. ";" .. g .. ";" .. b .. "m"
end

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
    --  check if our first separator is before the first result, if so notify the tokenizer
    if separators[1] ~= nil and result[1] ~= nil then
        local start = string.find(inputstr, separators[1], nil, true)
        local match_start = string.find(inputstr, result[1], nil, true)
        if start ~= nil and match_start ~= nil and start < match_start then
            separators["first"] = true
        end
    end
    return result, separators
end

local function find_next_quote_index(splitted_line, first_quote_index)
    for i = first_quote_index + 1, #splitted_line, 1 do
        if string.find(splitted_line[i], '"') then
            return i
        end
    end
    return nil
end

-- find string that potentially have been splitted and create a separate token for them
local function join_string(splitted_line)
    local result = {}
    local i = 1
    while i <= #splitted_line do
        if string.find(splitted_line[i], '"[^"]*"') then
            local start = splitted_line[i]:match('^([^"]*)"')
            local str = splitted_line[i]:match('"[^"]*"')
            local stop = splitted_line[i]:match('"([^"]*)$')
            table.insert(result, start)
            table.insert(result, str)
            table.insert(result, stop)
            i = i + 1
        elseif string.find(splitted_line[i], '"') then
            local next_quote = find_next_quote_index(splitted_line, i)

            if next_quote ~= nil then
                local combinded = splitted_line[i]
                for j = i + 1, next_quote, 1 do
                    combinded = combinded .. " " .. splitted_line[j]
                end
                local start, finish = string.find(combinded, '"[^"]*"')

                table.insert(result, combinded:sub(1, start - 1))
                table.insert(result, combinded:sub(start, finish))
                table.insert(result, combinded:sub(finish + 1, #combinded))

                i = next_quote + 1
            else
                table.insert(result, splitted_line[i])
                i = i + 1
            end
        else
            table.insert(result, splitted_line[i])
            i = i + 1
        end
    end
    return result
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

local function is_function_call(token)
    local end_is_brace = string.sub(token, #token, #token)
    end_is_brace = end_is_brace == "(" or end_is_brace == ")"
    local possible_variable = string.match(token, "^(.*)%(") or ""

    local dot_or_double_point_start = string.find(possible_variable, "[.:]")

    if dot_or_double_point_start ~= nil then
        local bIsFunctionCall = true
        local splitted = split(token, ",:")
        for _, value in ipairs(splitted) do
            if not is_variable(value) then
                bIsFunctionCall = false
            end
        end
        return bIsFunctionCall and end_is_brace
    end
    return is_variable(possible_variable) and end_is_brace
end

-- in case we don't match
local function sub_divide(sub_divided_token, depth)
    if (depth == nil) then
        depth = 1
    end
    local special_chars = {
        [","] = 1,
        [":"] = 1,
        ["("] = 1,
        [")"] = 1,
        ["["] = 1,
        ["]"] = 1
    }
    local tokens, separators = split(sub_divided_token, "(,:%[%])")
    local last_char
    for index, token in ipairs(tokens) do
        last_char = string.sub(token, #token, #token + 1)
        if special_chars[last_char] == 1 then
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
        splitted = join_string(splitted)
    end

    if separators == nil then
        separators = {}
    end

    for index, token in ipairs(splitted) do
        if separators[index] ~= nil and separators["first"] ~= nil then
            table.insert(
                tokens,
                {
                    text = separators[index],
                    bIsColored = true,
                    color = color_to_escape_sequence(special_chars_color)
                }
            )
        end

        if opperators[token] == 1 then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(operation_color)
                }
            )
        elseif
            libraryFunctions[token] == 1 or internalVariables[token] == 1 or
                libraryFunctions[string.sub(token, 1, #token - 1)] == 1 or
                internalVariables[string.sub(token, 1, #token - 1)] == 1
         then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(internal_variables_color)
                }
            )
        elseif keywords[token] == 1 then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(keyword_color)
                }
            )
        elseif is_string(token) then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(string_color)
                }
            )
        elseif is_function_call(token) then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(function_call_color)
                }
            )
        elseif is_variable(token) then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(variable_color)
                }
            )
        elseif is_number(token) then
            -- this edge case denotes the end of a multi-line comment
            -- TODO: this could also be a multi line string, currently not supported
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(number_color)
                }
            )
        elseif token == "]]" then
            table.insert(
                tokens,
                {
                    text = token,
                    bIsColored = true,
                    color = color_to_escape_sequence(comment_color)
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
                        color = color_to_escape_sequence(plain_color)
                    }
                )
            end
        end
        if separators[index] ~= nil and separators["first"] == nil then
            table.insert(
                tokens,
                {
                    text = separators[index],
                    bIsColored = true,
                    color = color_to_escape_sequence(special_chars_color)
                }
            )
        end
    end

    if comment ~= nil then
        table.insert(
            tokens,
            {
                text = comment,
                color = color_to_escape_sequence(comment_color),
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

local function printColorized(string)
    io.write(string)
end

local function ParseString(fileContent)
    local lines = {}
    for s in fileContent:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    local tokens = tokenize_content(lines)
    return colorize(tokens)
end

-- we are running this code directly from a lua interpreter
if debug.getinfo(3) == nil then
    local t = io.read("*all")
    local colorized = ParseString(t)
    printColorized(colorized)
else
    return {
        ParseString = ParseString,
        printColorized = printColorized,
    }
end
