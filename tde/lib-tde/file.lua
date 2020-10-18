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

-- see if the file exists
function file_exists(file)
  if type(file) ~= "string" then
    return false
  end
  return exists(file)
end

function dir_exists(dir)
  if type(dir) ~= "string" then
    return false
  end
  if dir:sub(-1) == "/" then
    return exists(dir)
  end
  return exists(dir .. "/")
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
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
  dir_exists = dir_exists
}
