local background = require("theme.config")["background"]
local file_exists = require("lib-tde.file").exists
local split = require("lib-tde.function.common").split

-- suffix the icon name with dark if light theme is enabled (icons have an inverted color compared with the background)
-- light theme is enabled if the backgrund property is set to light in colors.conf
-- This function then checks to see if the new file exists otherwise we default to the normal icon
return function(icon, backgrnd)
  if backgrnd == nil then
    -- just return the normal icons if the default background is selected
    if not (background == "light") then
      return icon
    end
  else
    if not (backgrnd == "light") then
    return icon
  end
  end
  -- otherwise check the dark variant of the svg files
  local splitted = split(icon, ".")

  if splitted[1] == nil or splitted[2] == nil then
    return icon
  end
  local light = splitted[1] .. ".dark." .. splitted[2]
  if file_exists(light) then
    return light
  end
  return icon
end

