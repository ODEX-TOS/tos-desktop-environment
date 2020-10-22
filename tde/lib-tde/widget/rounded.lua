local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
return function(size)
  if size == nil then
    size = dpi(10)
  end
  return function(c, w, h)
    gears.shape.rounded_rect(c, w, h, size)
  end
end
