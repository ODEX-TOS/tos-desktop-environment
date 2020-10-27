local filehandle = require("lib-tde.file")
local time = require("socket").gettime
-- store the old print variable into echo
echo = print

-- color coded log messages
LOG_ERROR = "\27[0;31m[ ERROR "
LOG_WARN = "\27[0;33m[ WARN "
LOG_DEBUG = "\27[0;35m[ DEBUG "
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

-- overwrite the print function call to enable easier debugging
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
