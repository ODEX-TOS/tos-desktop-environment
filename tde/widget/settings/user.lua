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
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local filesystem = require("lib-tde.file")
local signals = require("lib-tde.signals")
local dpi = beautiful.xresources.apply_dpi
local filehandle = require("lib-tde.file")
local imagemagic = require("lib-tde.imagemagic")
local scrollbox = require("lib-widget.scrollbox")
local profilebox = require("lib-widget.profilebox")
local card = require("lib-widget.card")
local button = require("lib-widget.button")
local loading = require("lib-widget.loading")()
loading.stop()

-- TODO: add option to modify the hostname and group management :)

-- this will hold the scrollbox, used to reset it
local body = nil
local layout = nil

local _size = require("widget.settings.size")

local m = _size.m
local settings_index = _size.settings_index
local settings_height = _size.settings_height

local tempUserDir = filehandle.mktempdir()

signals.connect_exit(function ()
  filehandle.rm(tempUserDir)
end)

local bSelectedProfilePicture = false
local refresh = function(_)
end


local function start_loading()
  layout:reset()
  body:reset()
  loading.start()
  layout:add(wibox.container.place(loading))
  root.elements.settings.ontop = false
  root.elements.settings_grabber:stop()
end

local function stop_loading(wall)
  loading.stop()
  -- Regrab the focus back (unless we closed the settings)
  if root.elements.settings.visible then
    root.elements.settings.ontop = true
    root.elements.settings_grabber:start()
  end
  refresh(wall)
end

-- wall is the scaled profilePicture
-- fullwall is a fullscreen (or original profilePicture)
local function make_mon(wall, _, fullwall, size)
  fullwall = fullwall or wall

  local clicked_callback = function(btn)
    -- we check if button == 1 for a left mouse button (this way scrolling still works)
    if bSelectedProfilePicture and btn == 1 then
      start_loading()
      awful.spawn.easy_async(
        "tos -p " .. fullwall,
        function()
          bSelectedProfilePicture = false
          print("Change profile picture to: " .. fullwall)
          -- TODO: update all references to the profile picture
          stop_loading(fullwall)
          signals.emit_profile_picture_changed(wall)
          -- collect the garbage to remove the image cache from memory
          collectgarbage("collect")
        end
      )
    end
  end

  local picture =
    profilebox({
      picture = wall,
      diameter = size,
      clicked_callback = clicked_callback
    })

  return wibox.container.place(picture)
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m
  view.bottom = m

  local title = wibox.widget.textbox(i18n.translate("User"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local pictures = card()

  layout = wibox.layout.grid()
  layout.spacing = m
  layout.forced_num_cols = 4
  layout.homogeneous = true
  layout.expand = true
  layout.min_rows_size = dpi(100)

  local changeProfilePicture =
    button({
      body = "Change Profile Picture",
      callback = function()
        -- TODO: change profilePicture
        bSelectedProfilePicture = not bSelectedProfilePicture
        refresh()
      end
    })
  changeProfilePicture.top = m
  changeProfilePicture.bottom = m

  body = scrollbox(layout)
  pictures.update_body(body)

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.fixed.vertical,
        {layout = wibox.container.margin, top = m, pictures},
        {layout = wibox.container.margin, top = m, changeProfilePicture}
      },
      nil
    }
  }

  -- The user option tells use if these are pictures supplied by the user
  local function load_picture(k, table, done, user)
    local v = table[k]
    -- check if it is a file
    if filesystem.exists(v) then
      local base = filehandle.basename(v)
      local width = dpi(100)
      local height = width
      local scaledImage = tempUserDir .. "/" .. base
      if user then
        scaledImage = tempUserDir .. "/user-" .. base
      end
      if filesystem.exists(scaledImage) and bSelectedProfilePicture then
        layout:add(make_mon(scaledImage, k, v, width))
        if done then
          done(user, table, k)
        end
      else
        -- We use imagemagick to generate a "thumbnail"
        -- This is done to save memory consumption
        -- However note that our cache (tempUserDir) is stored in ram
        imagemagic.scale(
          v,
          width,
          height,
          scaledImage,
          function()
            if filesystem.exists(scaledImage) and bSelectedProfilePicture then
              layout:add(make_mon(scaledImage, k, v, width))
            else
              print("Something went wrong scaling " .. v)
            end
            if done then
              done(user, table, k)
            end
          end
        )
      end
    else
      -- in case the entry is a directory and not a file
      if done then
        done(user, table, k)
      end
    end
  end

  local recursive_picture_load_func

  local function loadMonitors()
    local usr_files = filesystem.list_dir("/usr/share/backgrounds/tos")

    recursive_picture_load_func = function(bool, table, i)
      if i < #table then
        i = i + 1
        load_picture(i, table, recursive_picture_load_func, bool)
      end
    end
    load_picture(1, usr_files, recursive_picture_load_func, false)
    local pictures_dir = os.getenv("HOME") .. "/Pictures/tde"
    if filesystem.dir_exists(pictures_dir) then
      local home_dir = filesystem.list_dir_full(pictures_dir)
      -- true to tell the function that these are user pictures
      load_picture(1, home_dir, recursive_picture_load_func, true)
    end
  end

  local timer =
    gears.timer {
    timeout = 0.1,
    call_now = false,
    autostart = false,
    single_shot = true,
    callback = loadMonitors
  }

  local function find_picture()
    local picture = "/etc/xdg/tde/widget/user-profile/icons/user.svg"
    if filehandle.exists(os.getenv("HOME") .. "/.face") then
      picture = os.getenv("HOME") .. "/.face"
    end
    signals.emit_profile_picture_changed(picture)
    return picture
  end


  refresh = function(wall)
    layout:reset()
    body:reset()
    -- remove all images from memory (to save memory space)
    collectgarbage("collect")

    if bSelectedProfilePicture then
      -- do an asynchronous render of all profilePictures
      timer:start()
      layout.forced_num_cols = 4
    else
      local picture = find_picture()

      pictures.forced_height = settings_height / 2
      layout.forced_num_cols = 1

      local base = filehandle.basename(picture)
      local width = pictures.forced_height - dpi(50)
      local height = width
      local scaledImage = tempUserDir .. "/picture-" .. base
      if filesystem.exists(scaledImage) and wall == nil then
        layout:add(make_mon(scaledImage, 1, picture, width))
      else
        -- We use imagemagick to generate a "thumbnail"
        -- This is done to save memory consumption
        -- However note that our cache (tempUserDir) is stored in ram
        imagemagic.scale(
          wall or picture,
          width,
          height,
          scaledImage,
          function()
            layout:add(make_mon(scaledImage, 1, picture, width))
          end
        )
      end
    end
  end
  -- emit the picture data
  find_picture()
  view.refresh = refresh
  return view
end
