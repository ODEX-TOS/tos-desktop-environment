local filehandle = require("lib-tde.file")
local desktop_icon = require("widget.desktop_icon")
local installed = require("lib-tde.hardware-check").has_package_installed

local desktopLocation = os.getenv("HOME") .. "/Desktop"
local offset = -1
if installed("installer") then
    offset = 0
end

-- TODO: run filesystem event listner each time the desktop changes
if filehandle.dir_exists(desktopLocation) then
    for index, file in ipairs(filehandle.list_dir(desktopLocation)) do
        desktop_icon.from_file(file, index + offset)
    end
end
