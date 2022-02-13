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
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local icons = require("theme.icons")
local menubar = require("menubar")
local filehandle = require("lib-tde.file")
local hardware = require("lib-tde.hardware-check")
local err = require("lib-tde.logger").error
local signals = require("lib-tde.signals")
local click_handler = require("lib-tde.click-handler")
local menu = require("widget.menu")
local split = require("lib-tde.function.common").split

local width = dpi(60)
local height = width

local amount = math.floor((mouse.screen.workarea.height / height) - 1)
local _count = 0

desktop_icons = {}
local text_name = {}
local icon_timers = {}

-- move all boxes relative to the selected box
local function move_selected_boxes(base, prev_base)
    local delta = {x = base.x - prev_base.x, y = base.y - prev_base.y}
    -- find all selected boxes (they have ontop = true)
    for _, value in ipairs(desktop_icons) do
        if value.ontop and not (value == base) then
            -- now we move this widget by the delta
            value.x = value.x + delta.x
            value.y = value.y + delta.y
        end
    end
end

-- clear all selected icons
local function clear_selections()
    for _, value in ipairs(desktop_icons) do
        value.unselect()
    end
end

-- We will rename a file from 'file.txt' to 'file.copy.txt' if it already exists then we call it file.copy(2).txt
local function generate_copy_file_name(file)

    local path = filehandle.dirname(file)
    local filename = filehandle.basename(file)
    local extention_lst = split(filename, ".")
    local extention = extention_lst[#extention_lst]

    local file_name = filename:gsub("%." .. extention, "")

    local base = path .. '/' .. file_name

    -- Our inotify handler will pick it up
    if filehandle.exists(base .. '.copy.' .. extention) then
        local i = 1
        while filehandle.exists(base .. '.copy('.. tostring(i) .. ').' .. extention) and i < 50 do
            i = i + 1
        end
        return base.. '.copy('.. tostring(i) .. ').' .. extention
    else
        return base .. '.copy.' .. extention
    end
end

local from_file = function(file, index, x, y, drag) -- luacheck: ignore
end

_G.clear_desktop_selection = clear_selections

local function create_icon(icon, name, num, callback, drag, copy, delete, rename, rename_aborted)
    _count = _count + 1
    local x = 0
    local y = 0
    local active_theme = beautiful.accent

    if type(num) == "number" then
        x = dpi(10) + (math.floor((num / amount)) * (width + dpi(10)))
        y = dpi(36) + ((num % amount) * (height + dpi(10)))
    end

    if type(num) == "table" then
        x = num.x
        y = num.y
    end

    -- The offset used when dragging the icon
    local xoffset = 0
    local yoffset = 0

    local box =
        wibox(
        {
            ontop = false,
            visible = true,
            x = x,
            y = y,
            type = "dock",
            bg = beautiful.background.hue_800 .. "00",
            width = width,
            height = height,
            screen = awful.screen.primary,
            cursor = 'hand1',
        }
    )

    local text =  wibox.widget {
        text = name,
        halign = "center",
        valign = "top",
        font = beautiful.font,
        widget = wibox.widget.textbox
    }

    local timer =
        gears.timer {
        timeout = 1 / 24,
        call_now = false,
        autostart = false,
        callback = function()
            local offset = {x = box.x, y = box.y}
            local coords = mouse.coords()
            box.x = coords.x - xoffset
            box.y = coords.y - yoffset
            move_selected_boxes(box, offset)
        end
    }

    hardware.getDisplayFrequency(function(freq)
        timer.timeout = 1 / freq
    end)

    box.hover = function()
        box.ontop = true
        box.bg = active_theme.hue_500 .. "99"
    end

    box.select = function()
        box.hover()
        box.bg = active_theme.hue_600 .. "99"
        box.__selected = true
    end

    box.unhover = function()
        box.ontop = false

        if box.__selected == nil or box.__selected == false then
            box.bg = active_theme.hue_800 .. "00"
        else
            box.hover()
        end
    end

    box.unselect = function()
        box.__selected = false
        box.unhover()
    end

    box.rename = function(new_name)
        name = new_name or name
        text.text = name
    end

    local started = false

    local press_cb, release_cb = click_handler({
        pressed_cb =  function()
            -- Find the offset of the mouse relative to the start of the rectangle
            local coords = mouse.coords()
            xoffset = coords.x - box.x
            yoffset = coords.y - box.y
            if not started then
                started = true
                print("TIMER: started")
                timer:start()
            end
        end,
        released_cb = function()
            if started then
                started = false
                print("TIMER: stopped")
                timer:stop()
            end
            if type(drag) == "function" then
                drag(name, box.x, box.y)
            end
        end,
        double_pressed_cb = function()
            if type(callback) == "function" then
                box.cursor = "watch"
                callback(name, box)
            end
        end,
        short_pressed_cb = function()
            box.select()
        end
    })

    local widget =
        wibox.widget {
        layout = wibox.layout.fixed.vertical,
        wibox.container.place(
            {
                image = icon,
                resize = true,
                forced_height = (2 * height) / 3,
                widget = wibox.widget.imagebox
            }
        ),
        wibox.container.place(
            text
        ),
        forced_width = width
    }

    local function rename_run()
        awful.prompt.run {
            prompt       = "",
            text         = text.text,
            bg_cursor    = beautiful.primary.hue_600,
            textbox      = text,
            exe_callback = function(input)
                if not input or #input == 0 then
                    if rename_aborted then
                        rename_aborted(text.text)
                    end
                    return
                end

                -- before calling the user callback, ensure that the internal naming is still correct
                for index, value in ipairs(text_name) do
                    if value == name then
                        text_name[index] = input
                    end
                end

                rename(input)
                box.rename(input)
            end
        }
    end

    box.prompt = rename_run


    widget:connect_signal("mouse::enter", box.hover)

    widget:connect_signal("mouse::leave", box.unhover)

    signals.connect_primary_theme_changed(
        function(theme)
            active_theme = theme
            box.bg = active_theme.hue_800 .. "00"
        end
    )

    box:setup {
        layout = wibox.layout.flex.vertical,
        widget,
        forced_width = width
    }

    menu({
        wibox = box,
        left_click_pressed = press_cb,
        left_click_released = release_cb,
        items = {
            { i18n.translate("Rename"), function ()
                rename_run()
            end, icons.edit },
            { i18n.translate("Copy"), copy, icons.copy },
            { i18n.translate("Delete"), delete, icons.trash }
        },
    })

    table.insert(desktop_icons, box)
    table.insert(text_name, name)
    table.insert(icon_timers, timer)


    return box
end

local function desktop_file(file, _, index, drag)
    local name = "Desktop file"
    local icon = "application-x-executable"
    local lines = filehandle.lines(file)
    for _, line in ipairs(lines) do
        local nameMatch = line:match("Name=(.*)")
        local iconMatch = line:match("Icon=(.*)")

        if nameMatch and name == "Desktop file" then
            name = nameMatch
        elseif iconMatch and icon == "application-x-executable" then
            icon = iconMatch
        end
    end
    create_icon(
        menubar.utils.lookup_icon(icon) or icons.warning,
        name,
        index,
        function(_, _wibox)
            print("Opened: " .. file)
            clear_selections()
            awful.spawn.easy_async("gtk-launch " .. filehandle.basename(file), function()
                _wibox.cursor = "hand1"
            end)
        end,
        drag,
         -- copy function
         function()
            print("Copied: " .. file)
            local copy_file_name = generate_copy_file_name(file)
            filehandle.copy_file(file, copy_file_name)
        end,
        -- delete function
        function()
            print("Deleting file: " .. file)
            filehandle.rm(file)
        end,
        -- rename function
        function (renamed)
            print("Renaming file: " .. file .. ' to ' .. renamed)
            local dir = filehandle.dirname(file)

            filehandle.move_file(file, dir .. '/' .. renamed)

            file = dir .. '/' .. renamed
        end
    )
end


from_file = function(file, index, x, y, drag)
    local name = filehandle.basename(file)
    -- Ensure that the name is not used already
    for _, text in ipairs(text_name) do
        if text == name then
            return
        end
    end

    if name:match(".desktop$") then
        desktop_file(file, name, index or {x = x, y = y}, drag)
    else
        local icon = icons.warning

        -- can be found here https://specifications.freedesktop.org/icon-naming-spec/latest/ar01s04.html
        if filehandle.exists(file) then
            icon = menubar.utils.lookup_icon("text-x-generic") or icon
        else
            icon = menubar.utils.lookup_icon("folder") or icon
        end

        create_icon(
            icon,
            name,
            index or {x = x, y = y},
            function(_, _wibox)
                print("Opened: " .. file)
                clear_selections()
                awful.spawn.easy_async("open " .. file, function()
                    _wibox.cursor = "hand1"
                end)
            end,
            drag,
            -- copy function
            function()
                print("Copied: " .. file)
                local copy_file_name = generate_copy_file_name(file)
                filehandle.copy_file(file, copy_file_name)
            end,
            -- delete function
            function()
                print("Deleting file: " .. file)
                filehandle.rm(file)
            end,
            -- rename function
            function (renamed)
                print("Renaming file: " .. file .. ' to ' .. renamed)
                local dir = filehandle.dirname(file)

                filehandle.move_file(file, dir .. '/' .. renamed)

                file = dir .. '/' .. renamed
            end
        )
    end
end

local function delete(name)
    local i = -1
    for index, value in ipairs(text_name) do
        if value == name then
            i = index
        end
    end
    if i == -1 or i > #desktop_icons then
        print("Trying to remove: " .. name .. " from the desktop but it no longer exists", err)
    end
    desktop_icons[i].visible = false
    icon_timers[i]:stop()
    table.remove(desktop_icons, i)
    table.remove(icon_timers, i)
    table.remove(text_name, i)
end

local __from_nothing = function (icon, create, drag)
    local desktop = os.getenv("HOME") .. '/Desktop/'
    local file
    local box = create_icon(
            icon,
            "",
            _count,
            function(_, _wibox)
                if file == nil then return end

                print("Opened: " .. file)
                clear_selections()
                awful.spawn.easy_async("open " .. file, function()
                    _wibox.cursor = "hand1"
                end)
            end,
            drag,
            -- copy function
            function()
                if file == nil then return end
                print("Copied: " .. file)
                local copy_file_name = generate_copy_file_name(file)
                filehandle.copy_file(file, copy_file_name)
            end,
            -- delete function
            function()
                if file == nil then return end
                print("Deleting file: " .. file)
                filehandle.rm(file)
            end,
            -- rename function
            function (renamed)
                -- we are in the case were we create the file/directory from nothing
                if file == nil then
                    create(desktop .. renamed)
                    file = desktop .. renamed
                    return
                end

                print("Renaming file: " .. file .. ' to ' .. renamed)
                local dir = filehandle.dirname(file)

                filehandle.move_file(file, dir .. '/' .. renamed)

                file = dir .. '/' .. renamed
            end,
            -- people stopped creating the new file/directory
            function (name)
                delete(name)
            end
        )

    box.prompt()
end

local function location_from_name(name)
    local i = -1
    for index, value in ipairs(text_name) do
        if value == name then
            i = index
        end
    end
    if not (i == -1) then
        return {x = desktop_icons[i].x, y = desktop_icons[i].y}
    end
    return {x = nil, y = nil}
end

-- TODO: Implement creating a file
-- (Create a desktop icon with a rename prompt, but the inotify shouldn't create a new icon)

local file_icon = menubar.utils.lookup_icon("text-x-generic")  or icons.warning
local dir_icon = menubar.utils.lookup_icon("folder") or icons.warning

local function create_file(drag)
    __from_nothing(
        file_icon,
        function(file)
            filehandle.overwrite(file, "")
        end,
        drag
    )

end

-- TODO: Same applies to the directory
local function create_directory(drag)
    __from_nothing(
        dir_icon,
        function(dir)
            filehandle.dir_create(dir)
        end,
        drag
    )
end

return {
    from_file = from_file,
    create_icon = create_icon,
    delete = delete,
    location_from_name = location_from_name,
    create_file = create_file,
    create_directory = create_directory,
    count = function()
        return _count
    end
}
