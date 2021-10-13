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
---------------------------------------------------------------------------
-- This module overrides the existing print function.
--
-- The new print function also logs everything to `$HOME/.cache/tde/stdout.log`
-- This module describes the new api of the print function.
--
-- Assume you want to print something:
--
--    print("This is a print message")
--
-- This gets printed out to stdout and written to `$HOME/.cache/tde/stdout.log`
--
-- You can give the user one of four logtypes: error, warning, debug and info.
-- The default logtype is info.
--
-- To get the logtype you must do the following:
--
--    local logger = require("lib-tde.logger")
--    print("This is an error"       , logger.error)
--    print("This is a warning"      , logger.warn)
--    print("This is a debug message", logger.debug)
--    print("This is an info message", logger.info) -- by default you can omit logger.info
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.logger
-- @supermodule print
---------------------------------------------------------------------------

local filehandle = require("lib-tde.file")
local time = require("socket").gettime

-- color coded log messages

--- Indicate that this print message is an error
-- @property error
-- @param string
local LOG_ERROR = "\27[0;31m[ ERROR "
--- Indicate that this print message is a warning
-- @property warn
-- @param string
local LOG_WARN = "\27[0;33m[ WARN "
--- Indicate that this print message is a debug message
-- @property debug
-- @param string
local LOG_DEBUG = "\27[0;35m[ DEBUG "
--- Indicate that this print message is an info message
-- @property info
-- @param string
local LOG_INFO = "\27[0;32m[ INFO "

if _G.echo ~= nil then
	-- this module was already been called
	return {
		warn = LOG_WARN,
		error = LOG_ERROR,
		debug = LOG_DEBUG,
		info = LOG_INFO
	}
end

-- store the old print variable into echo
echo = print


local dir = os.getenv("HOME") .. "/.cache/tde"
local filename = dir .. "/stdout.log"
local filename_error = dir .. "/error.log"

filehandle.overwrite(filename, "")
filehandle.overwrite(filename_error, "")

local stdout_fd = io.open(filename, "a")
local error_fd = io.open(filename_error, "a")

local prev_time = time()

-- how often we should flush to disk
local flush_time_delta = 0.5

-- helper function to convert a table to a string
-- WARN: For internal use only, this should never be exposed to the end user
-- usage: local string = pretty_print_table({})
local function table_to_string(tbl, depth, indent)
	indent = indent or 1
	-- limit the max size
	if indent > depth then
		if type(tbl) == "table" then
			return "{  ..."
		end
		return ""
	end
	local formatting = string.rep("  ", indent)
	local result = "{\n"
	for k, v in pairs(tbl) do
		local format = formatting .. tostring(k) .. ": "
		if type(v) == "table" then
			result = result .. format .. table_to_string(v, depth - 1, indent + 1) .. formatting .. "},\n"
		else
			if type(v) == "string" then
				result = result .. format .. "'" .. v .. "',\n"
			else
				result = result .. format .. tostring(v) .. ",\n"
			end
		end
	end
	-- edge case initial indentation requires manually adding ending bracket
	if indent == 1 then
		return result .. "}"
	end
	return result
end

--- The default lua print message is overridden
-- @tparam string arg The string to print
-- @tparam[opt] enum log_type The type of log message
-- @tparam[opt] depth number In case you print a table, show the table until a certain depth
-- @staticfct print
-- @usage -- Print the error message "hello"
-- print("hello", logger.error)
print = function(arg, log_type, depth)
	depth = depth or 3
	-- validate the input
	if arg == nil or _G.UNIT_TESTING_ACTIVE == true then
		return
	end
	if type(arg) == "table" then
		arg = table_to_string(arg, depth)
	end
	if not (type(arg) == "string") then
		arg = tostring(arg)
	end

	local log = log_type or LOG_INFO

	local __time = time()

	local out = os.date("%H:%M:%S") .. string.format(".%.04d", math.floor(__time * 10000) % 10000)
	local statement = log .. out:gsub("\n", "") .. " ]\27[0m "
	for line in arg:gmatch("[^\r\n]+") do
		-- print it to stdout
		echo(statement .. line)
		-- append it to the log file
		if stdout_fd ~= nil then
			stdout_fd:write(statement .. line .. "\n")
		end
		if error_fd ~= nil and log == LOG_ERROR then
			error_fd:write(statement .. line .. "\n")
		end
	end

	-- flush to the file every flush_time_delta seconds
	if __time - prev_time > flush_time_delta then
		if stdout_fd ~= nil then
			stdout_fd:flush()
		end
		if error_fd ~= nil then
			error_fd:flush()
		end
		prev_time = __time
	end
end

--- Log a given message and add a stacktrace at the end, usually because something bad happened
-- @tparam string arg The string to print
-- @tparam[opt] enum log_type The type of log message
-- @tparam[opt] depth number In case you print a table, show the table until a certain depth
-- @staticfct log_with_stacktrace
-- @usage -- Print the error message "hello" and show the callstack
-- log_with_stacktrace("hello", logger.error)
local function log_with_stacktrace(arg, log_type, depth)
	if arg == nil or arg == "" then
		print(debug.traceback(), log_type, depth)
	end

	local trace = debug.traceback()
	print(arg .. '\n' .. trace, log_type, depth)
end

return {
	warn = LOG_WARN,
	error = LOG_ERROR,
	debug = LOG_DEBUG,
	info = LOG_INFO,

	log_with_stacktrace = log_with_stacktrace
}
