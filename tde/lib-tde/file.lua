---------------------------------------------------------------------------
-- General functions to manipulate your file and filesystems
--
-- This module exposes an API to communicate with the filesystem
--
-- Often you need to check what the environment is where you are running in
-- This often involves checking what files exist for example in `/proc` or `/sys``
--
-- Checking files is as easy as
--
--    lib-tde.file.exists("/etc/passwd") -- returns true on TOS
--    lib-tde.file.exists("/this/does/not/exist") -- returns false
--
-- You can also do the same for directories
--
--    lib-tde.file.dir_exists(os.getenv("HOME") .. "/.config") -- returns true on systems with default XDG_CONFIG_DIR support
--    lib-tde.file.dir_exists("/this/does/not/exist/") -- returns false
--
-- You can also readout the data that is inside the a file (into a string)
-- Imagine we have a file in the home directory called file.txt with the content abcdefg
--
--    lib-tde.file.string(os.getenv("HOME") .. "/file.txt") -- returns abcdefg
--
-- Lastly we provide a function to read the file in as a table of lines
-- Imagine we have a file in the home directory called file.txt with the following content
--
--    line one
--    line two
--    line three
--
-- Then we can execute the following function to put it into a table of lines
--
--    lib-tde.file.lines(os.getenv("HOME") .. "/file.txt") -- returns {1: "line one", 2: "line two", 3: "line three"}
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.file
---------------------------------------------------------------------------

-- check if a file or directory exists
local function exists(file)
  if not (type(file) == "string") then
    return false
  end
  -- we can't os.rename root but it exists (always)
  if file == "/" then
    return true
  end
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok
end

--- Check if a file exists
-- @tparam file string The path to the file, can be both absolute or relative.
-- @treturn bool True if a file exists false otherwise
-- @staticfct exists
-- @usage -- This true
-- lib-tde.file.exists("/etc/passwd")
function file_exists(file)
  if type(file) ~= "string" then
    return false
  end
  return exists(file) and not exists(file .. "/")
end

-- TODO: unit test the file writing

--- Write data to a new file
-- @tparam file string The path to the file, can be both absolute or relative.
-- @tparam data string The data to put into the file
-- @treturn bool if the write was succesfull
-- @staticfct write
-- @usage -- This true
-- lib-tde.file.write("hallo.txt", "this is content in the file")
function write(file, data)
  if type(file) ~= "string" then
    return false
  end
  fd = io.open(file, "a")
  fd:write(data .. "\n")
  fd:close()
  return true
end

--- Override the entire file
-- @tparam file string The path to the file, can be both absolute or relative.
-- @tparam data string The data to put into the file
-- @treturn bool if the write was succesfull
-- @staticfct overwrite
-- @usage -- This true
-- lib-tde.file.overwrite("hallo.txt", "this is content in the file")
function overwrite(file, data)
  if type(file) ~= "string" then
    return false
  end
  fd = io.open(file, "w")
  fd:write(data .. "\n")
  fd:close()
  return true
end

--- Check if a directory exists
-- @tparam dir string The path to the directory, can be both absolute or relative.
-- @treturn bool True if the directory exists false otherwise
-- @staticfct dir_exists
-- @usage -- This true
-- lib-tde.file.dir_exists("/etc")
function dir_exists(dir)
  if type(dir) ~= "string" then
    return false
  end
  if dir:sub(-1) == "/" then
    return exists(dir)
  end
  return exists(dir)
end

--- Get all lines from a file, returns an empty table if it doesn't exist
-- @tparam file string The path to the file, can be both absolute or relative.
-- @tparam[opt] match string A regular expression to filter out lines that should be ignored by default = ^.*$
-- @tparam[opt] head number Acts like the head unix tool, it returns the first <head> lines in a file
-- @treturn table The lines in a file
-- @staticfct lines
-- @usage -- This gives the first 100 lines of /etc/hosts and filters it by only showing lines that start with ipv4 addresses
-- lib-tde.file.lines_from("/etc/hosts", "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*", 100) -> is of type table
function lines_from(file, match, head)
  if match == nil then
    match = "^.*$"
  end
  if not file_exists(file) then
    return {}
  end
  lines = {}
  i = 0
  for line in io.lines(file) do
    i = i + 1
    if head ~= nil and i > head then
      return lines
    end
    if string.match(line, match) then
      lines[#lines + 1] = line
    end
  end
  return lines
end

--- Put the content of a file into a string
-- @tparam file string The path to the file, can be both absolute or relative.
-- @tparam[opt] match string A regular expression to filter out lines that should be ignored by default = ^.*$
-- @tparam[opt] head number Acts like the head unix tool, it returns the first <head> lines in a file
-- @treturn string The filtered out content of a file
-- @staticfct string
-- @usage -- This gives the first 100 lines of /etc/hosts and filters it by only showing lines that start with ipv4 addresses
-- lib-tde.file.string("/etc/hosts", "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*", 100) -> is of type string
function getString(file, match, head)
  if match == nil then
    match = "^.*$"
  end
  if not file_exists(file) then
    return ""
  end
  i = 0
  string = ""
  for line in io.lines(file) do
    i = i + 1
    if head ~= nil and i > head then
      return string
    end
    if string.match(line, match) then
      string = string .. line .. "\n"
    end
  end
  return string
end

--- Return a table of filename found in a directory
-- @tparam dir string The path to the directory, can be both absolute or relative.
-- @treturn table an iterable table containg all files in the directory
-- @staticfct list_dir
-- @usage -- This returns a table
-- lib-tde.file.dir_exists("/etc") -> {1:"/etc/passwd", 2:"/etc/shadow", 3:"/etc/hosts", ...}
local function list_dir(str)
  if not (type(str) == "string") then
    return {}
  end
  -- use posix complient checks
  local M = require("posix.dirent")
  local ok, files = pcall(M.dir, str)
  if not ok then
    return {}
  end
  local ABS_files = {}
  for _, item in ipairs(files) do
    if not (item == ".") and not (item == "..") then
      table.insert(ABS_files, str .. "/" .. item)
    end
  end
  -- momentary check
  return ABS_files
end

--- Return a table of filename found in a directory and all child directories (be carefull for big directories)
-- @tparam dir string The path to the directory, can be both absolute or relative.
-- @treturn table an iterable table containg all files in the directory
-- @staticfct list_dir
-- @usage -- This returns a table
-- lib-tde.file.dir_exists("/etc") -> {1:"/etc/passwd", 2:"/etc/ssh/sshd_config", 3:"/etc/pacman/pacman.conf", ...}
local function list_dir_full(str)
  if not (type(str) == "string") then
    return {}
  end
  local files = {}
  -- traverse the directory
  for _, value in ipairs(list_dir(str)) do
    if file_exists(value) then
      print(value)
      table.insert(files, value)
    else
      local filearr = list_dir_full(value)
      for _, val in ipairs(filearr) do
        print(val)
        table.insert(files, val)
      end
    end
  end
  return files
end

function log(filename)
  -- tests the functions above
  local lines = lines_from(filename)

  -- print all line numbers and their contents
  for k, v in pairs(lines) do
    print("line[" .. k .. "]", v)
  end
end

return {
  log = log,
  lines = lines_from,
  string = getString,
  exists = file_exists,
  dir_exists = dir_exists,
  list_dir = list_dir,
  list_dir_full = list_dir_full,
  write = write,
  overwrite = overwrite
}
