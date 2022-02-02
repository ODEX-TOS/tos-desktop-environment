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
-- Manage default applications for a given mimetype (Setting applications, getting and listing)
--
-- This will run a process in the background (As the user that runs TDE) and guarantees that is is up and running
--
--    lib-tde.mime.get_mimetypes() -- Returns a list of all known mimetypes
--    lib-tde.mime.mimetypeAppChooser("application/json") -- Open up a modal to select the application for the given mimetype
--
-- @author Tom Meyers
-- @copyright 2021 Tom Meyers
-- @tdemod lib-tde.mime
---------------------------------------------------------------------------
local lgi = require('lgi')
local menubar = require("menubar")
local Gtk = lgi.Gtk
local Gio = lgi.Gio

local logger = require('lib-tde.logger')


local __mimetype_cache = nil
--- Get a list of all known mimetypes
-- @staticfct get_mimetypes
-- @usage -- Returns a list of mimetypes
-- get_mimetypes() -- {"application/json", "image/png", ...}
local function get_mimetypes()
    if __mimetype_cache ~= nil then
        return __mimetype_cache
    end
    -- This is a heavy function to call, so we cache it
    __mimetype_cache = Gio.content_types_get_registered()
    return __mimetype_cache
end

--- Get the application icon and name for the given mimetype
-- @staticfct get_metadata
-- @usage -- Returns a string representation of the icon for the given application matching the mimetype and the application name
-- get_icon_for_type("application/json") -- "menubar lookupable name", "app_name"
local function get_metadata(content_type)
   -- This returns a list of generic icons for the content_type
    -- Gio.content_type_get_icon(mime).names

    local app_info = Gio.app_info_get_default_for_type(content_type, false)

    local icons
    local name

    -- No default app for this mimetype
    if app_info == nil then
        print("No default app for: " .. content_type, logger.warning)

        -- try to fetch the default icon instead
        name = content_type
        icons = Gio.content_type_get_icon(content_type).names
    else
        icons = Gio.AppInfo.get_icon(app_info).names
        name = Gio.AppInfo.get_display_name(app_info)
    end

    if icons == nil or #icons == 0 then
        logger.log_with_stacktrace("Could not find any icons for: " .. content_type, logger.error)
        return content_type, "x-application"
    end

    -- we found a match with the theme icon
    for _, _name in ipairs(icons) do
        local __lookup = menubar.utils.lookup_icon(_name)
        if __lookup ~= nil then
            return name, __lookup
        end
    end

end

--- Allow setting the mimetype through a Dialog box
-- @tparam string mimetype The mimetype that needs to be changed
-- @tparam[opt] function done_callback Trigger this function after the dialog picker closed
-- @staticfct mimetypeAppChooser
-- @usage -- Run the program forever
-- mimetypeAppChooser("application/json", function() print("User changed the mimetype") end)
local function mimetypeAppChooser(mimetype, done_callback)
    local dialog = Gtk.AppChooserDialog {
        content_type = mimetype,
        flags = Gtk.DialogFlags.GTK_DIALOG_MODAL
    }

    dialog:run()
    dialog:destroy()

    if done_callback ~= nil then
        done_callback()
    end
end


return {
    get_mimetypes = get_mimetypes,
    get_metadata = get_metadata,
    mimetypeAppChooser = mimetypeAppChooser
}