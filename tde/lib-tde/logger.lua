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
---------------------------------------------------------------------------

local filehandle = require("lib-tde.file")
local time = require("socket").gettime
-- store the old print variable into echo
echo = print

-- color coded log messages

--- Indicate that this print message is an error
-- @property error
-- @param string
LOG_ERROR = "\27[0;31m[ ERROR "
--- Indicate that this print message is a warning
-- @property warn
-- @param string
LOG_WARN = "\27[0;33m[ WARN "
--- Indicate that this print message is a debug message
-- @property debug
-- @param string
LOG_DEBUG = "\27[0;35m[ DEBUG "
--- Indicate that this print message is an info message
-- @property info
-- @param string
LOG_INFO = "\27[0;32m[ INFO "

local dir = os.getenv("HOME") .. "/.cache/tde"
local filename = dir .. "/stdout.log"

-- create the tde directory
if not filehandle.dir_exists(dir) then
	io.popen("mkdir -p " .. dir)
end
-- make the file empty on startup to reduce disk size
if filehandle.dir_exists(dir) then
	filehandle.overwrite(filename, "")
end

-- open the log file (if no handle exists already)

--- The default lua print message is overriden
-- @tparam string arg The string to print
-- @tparam[opt] enum log_type The type of logmessage
-- @staticfct print
-- @usage -- Print the error message "hello"
-- print("hello", logger.error)
print = function(arg, log_type)
	if arg == nil then
		return
	end
	local file = io.open(filename, "a")

	log = log_type or LOG_INFO
	local out = os.date("%H:%M:%S") .. "." .. math.floor(time() * 10000) % 10000
	statement = log .. out:gsub("\n", "") .. " ]\27[0m "
	for line in arg:gmatch("[^\r\n]+") do
		-- print it to stdout
		echo(statement .. line)
		-- append it to the log file
		if file ~= nil then
			file:write(statement .. line .. "\n")
		end
	end
	if file ~= nil then
		file:close()
	end
end

return {
	warn = LOG_WARN,
	error = LOG_ERROR,
	debug = LOG_DEBUG,
	info = LOG_INFO
}
