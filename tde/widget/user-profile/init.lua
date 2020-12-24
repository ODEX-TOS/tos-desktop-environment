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
-- YOU CAN UPDATE YOUR PROFILE PICTURE USING `mugshot` package
-- Will use default user.svg if there's no user image in /var/lib/...

local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local theme = require("theme.icons.dark-light")

local beautiful = require("beautiful")

local PATH_TO_ICONS = "/etc/xdg/tde/widget/user-profile/icons/"

local PATH_TO_CACHE_ICON = os.getenv("HOME") .. "/.cache/tos/user-icons/"

local PATH_TO_USERICON = "/var/lib/AccountsService/icons/"

local signals = require("lib-tde.signals")
local filehandle = require("lib-tde.file")

-- guarantee that the cache dir exists
filehandle.dir_create(PATH_TO_CACHE_ICON)

local profile_imagebox =
  wibox.widget {
  {
    id = "icon",
    forced_height = dpi(90),
    image = theme(PATH_TO_ICONS .. "user" .. ".svg"),
    clip_shape = gears.shape.circle,
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local profile_name =
  wibox.widget {
  align = "left",
  valign = "bottom",
  widget = wibox.widget.textbox
}

local distro_name =
  wibox.widget {
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

local kernel_name =
  wibox.widget {
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

local uptime_time =
  wibox.widget {
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

-- Check username
awful.spawn.easy_async_with_shell(
  "whoami",
  function(out)
    -- Update profile name
    -- Capitalize first letter of username
    local name = out:gsub("%W", "")
    name = name:sub(1, 1):upper() .. name:sub(2)
    signals.emit_username(name)
    profile_name.markup = '<span font="SFNS Display Bold 24">' .. name .. "</span>" --out:sub(1,1):upper()..out:sub(2)

    -- Bash script to check if user profile picture exists in /var/lib/AccountsService/icons/
    local cmd_check_user_profile =
      "if test -f " .. PATH_TO_USERICON .. out .. "; then print 'image_detected'; else print 'not_detected'; fi"
    awful.spawn.easy_async_with_shell(
      cmd_check_user_profile,
      function(stdout)
        -- there_is_face
        if stdout:match("image_detected") then
          -- Check if we already have a user's profile image copied to icon folder
          local cmd_icon_check = "if test -f " .. PATH_TO_CACHE_ICON .. "user.jpg" .. "; then print 'exists'; fi"
          awful.spawn.easy_async_with_shell(
            cmd_icon_check,
            function(stdout2)
              if stdout2:match("exists") then
                -- If the file already copied, don't copy, just update the imagebox
                profile_imagebox.icon:set_image(PATH_TO_CACHE_ICON .. "user.jpg")
              else
                -- Image detected, now copy your profile picture to the widget directory icon folder
                local copy_cmd = "cp " .. PATH_TO_USERICON .. out .. " " .. PATH_TO_CACHE_ICON .. "user.jpg"
                awful.spawn(copy_cmd)

                -- Add a timer to a delay
                -- The cp command is not fast enough so we will need this to update image
                gears.timer {
                  timeout = 0,
                  autostart = true,
                  single_shot = true,
                  callback = function()
                    -- Then set copied image as profilepic in the widget
                    profile_imagebox.icon:set_image(PATH_TO_CACHE_ICON .. "user.jpg")
                  end
                }
              end
            end,
            false
          )
        else
          -- r_u_ugly?
          -- if yes then use this image instead
          profile_imagebox.icon:set_image(theme(PATH_TO_ICONS .. "user.svg"))
        end
      end,
      false
    )
  end,
  false
)

-- Check distro name
awful.spawn.easy_async_with_shell(
  "cat /etc/os-release | awk 'NR==1'| awk -F " .. "'" .. '"' .. "'" .. " '{print $2}'",
  function(out)
    -- Remove newline represented by `\n`
    local distroname = out:gsub("%\n", "")
    distro_name.markup = '<span font="SFNS Display Regular 12">' .. distroname .. "</span>"
    signals.emit_distro(distroname)
  end
)

-- Run once on startup or login
awful.spawn.easy_async_with_shell(
  "uptime -p",
  function(out)
    local uptime = out:gsub("%\n", "")
    uptime_time.markup = '<span font="SFNS Display Regular 10">' .. uptime .. "</span>"
    signals.emit_uptime(uptime)
  end
)
-- Check uptime every 600 seconds/10min
awful.widget.watch(
  "uptime -p",
  600,
  function(_, stdout)
    local uptime = stdout:gsub("%\n", "")
    uptime_time.markup = '<span font="SFNS Display Regular 10">' .. uptime .. "</span>"
    signals.emit_uptime(uptime)
  end
)

-- Run once on startup or login
awful.spawn.easy_async_with_shell(
  "uname -r | cut -d '-' -f 1,2",
  function(out)
    local kernel = out:gsub("%\n", "")
    kernel_name.markup = '<span font="SFNS Display Regular 12">Kernel: ' .. kernel .. "</span>"
    signals.emit_kernel(kernel)
  end
)

local user_profile =
  wibox.widget {
  --expand = 'none',
  {
    {
      layout = wibox.layout.align.horizontal,
      {
        profile_imagebox,
        margins = dpi(3),
        widget = wibox.container.margin
      },
      {
        -- expand = 'none',
        layout = wibox.layout.fixed.vertical,
        {
          wibox.container.margin(profile_name, dpi(5)),
          layout = wibox.layout.fixed.horizontal
        },
        {
          wibox.container.margin(distro_name, dpi(5)),
          layout = wibox.layout.fixed.vertical
        },
        {
          wibox.container.margin(kernel_name, dpi(5)),
          layout = wibox.layout.fixed.vertical
        },
        {
          wibox.container.margin(uptime_time, dpi(5)),
          layout = wibox.layout.fixed.vertical
        }
      }
    },
    margins = dpi(5),
    widget = wibox.container.margin
  },
  bg = beautiful.bg_modal,
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 6)
  end,
  widget = wibox.container.background
}

-- return profile_imagebox

return user_profile
