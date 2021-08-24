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
local rounded = require("lib-tde.widget.rounded")
local filesystem = require("lib-tde.file")
local icons = require("theme.icons")
local signals = require("lib-tde.signals")
local dpi = beautiful.xresources.apply_dpi
local configWriter = require("lib-tde.config-writer")
local datetime = require("lib-tde.function.datetime")
local imagemagic = require("lib-tde.imagemagic")
local xrandr_menu = require("lib-tde.xrandr").menu
local scrollbox = require("lib-widget.scrollbox")
local slider = require("lib-widget.slider")
local card = require("lib-widget.card")
local button = require("lib-widget.button")
local sort = require('lib-tde.sort.quicksort')
local split = require('lib-tde.function.common').split
local xrandr = require('lib-tde.xrandr')
local mat_icon_button = require("widget.material.icon-button")
local mat_icon = require("widget.material.icon")


-- this will hold the scrollbox, used to reset it
local body = nil
local resolution_box = nil


local m = dpi(10)
local settings_index = dpi(40)

local tempDisplayDir = filesystem.mktempdir()
local monitorScaledImage = ""

local active_pallet = beautiful.primary


-- REFRESH MODE VARS
local refresh_card = card('Refresh rate list')
local resolution_card = card('Resolution list')

local refresh_rate_cmd = ""
local active_refresh_buttons = {}
local active_resolution_buttons = {}
local weak = {}
weak.__mode = "k"
setmetatable(active_refresh_buttons, weak)
setmetatable(active_resolution_buttons, weak)

-- END REFRESH MODE VARS


signals.connect_primary_theme_changed(
  function(pallete)
    active_pallet = pallete
  end
)

signals.connect_exit(
  function()
    filesystem.rm(tempDisplayDir)
  end
)

local mon_size = {
  w = nil,
  h = nil
}

-- The optional argument is for monitor_id when in REFRESH_MODE
local refresh = function(_)
end

local function weighted_resolution(resolution)
  local splitted = split(resolution, 'x')
  return (tonumber(splitted[1]) or 1) * (tonumber(splitted[2]) or 1)
end


local NORMAL_MODE = 1
local WALLPAPER_MODE = 2
local XRANDR_MODE = 3
local REFRESH_MODE = 4
local DPI_MODE = 5

local Display_Mode = NORMAL_MODE

-- Shift the value of the pallet by 1
local function shift_pallet(pallet)
  local new_pallet = {
    hue_50 =   pallet["hue_300"],
    hue_100 =  pallet["hue_400"],
    hue_200 =  pallet["hue_500"],
    hue_300 =  pallet["hue_600"],
    hue_400 =  pallet["hue_700"],
    hue_500 =  pallet["hue_800"],
    hue_600 =  pallet["hue_900"],
    hue_700 =  pallet["hue_900"],
    hue_800 =  pallet["hue_900"],
    hue_900 =  pallet["hue_A100"],
    hue_A100 = pallet["hue_A200"],
    hue_A200 = pallet["hue_A400"],
    hue_A400 = pallet["hue_A700"],
    hue_A700 = pallet["hue_A700"]
  }
  return new_pallet
end

local function make_refresh_list(refresh_tbl, resolution, monitor_id)
  local refresh_list = wibox.layout.fixed.vertical()

  active_refresh_buttons = {}

  for index, value in ipairs(refresh_tbl) do
      table.insert(active_refresh_buttons, button(value .. ' Hz', function ()
        refresh_rate_cmd = 'xrandr --output ' .. monitor_id .. ' --rate ' .. tostring(value) .. ' --mode ' .. resolution

        -- Visually show the selected option
        for i, btn in ipairs(active_refresh_buttons) do
          if i == index then
            btn.update_pallet(shift_pallet(active_pallet))
          else
            btn.update_pallet(active_pallet)
          end
        end
      end, active_pallet))
      refresh_list:add(wibox.container.margin(
          active_refresh_buttons[#active_refresh_buttons],
          dpi(5),dpi(5),dpi(5),dpi(5)
      ))
  end

  return refresh_list
end

local function make_resolution_list(monitor_information, monitor_id)
  local resolution_list = wibox.layout.fixed.vertical()

  active_resolution_buttons = {}

  local sorted_resolutions = {}
  for key, _ in pairs(monitor_information) do
      table.insert(sorted_resolutions, key)
  end

  sorted_resolutions = sort(sorted_resolutions, function (smaller, bigger)
      return weighted_resolution(smaller) > weighted_resolution(bigger)
  end)

  for index, value in ipairs(sorted_resolutions) do
      table.insert(active_resolution_buttons,  button(value, function ()
            refresh_card.update_body(make_refresh_list(monitor_information[value], value, monitor_id))

            -- Visually show the selected option
            for i, btn in ipairs(active_resolution_buttons) do
              if i == index then
                btn.update_pallet(shift_pallet(active_pallet))
              else
                btn.update_pallet(active_pallet)
              end
            end
        end, active_pallet)
      )
      resolution_list:add(wibox.container.margin(
        active_resolution_buttons[#active_resolution_buttons],
          dpi(5),dpi(5),dpi(5),dpi(5)
      ))
  end

  resolution_box = scrollbox(resolution_list)
  resolution_card.update_body(resolution_box)
end

local function make_screen_layout(wall, label)
  local size = dpi(20)
  local monitor =
    wibox.widget {
    widget = wibox.widget.imagebox,
    shape = rounded(),
    clip_shape = rounded(),
    resize = true,
    forced_width = nil,
    forced_height = nil
  }
  monitor:set_image(wall)
  return wibox.container.place(
    wibox.widget {
      layout = wibox.layout.stack,
      forced_width = size * 16,
      forced_height = size * 9,
      wibox.container.place(monitor),
      {
        layout = wibox.container.place,
        valign = "center",
        halign = "center",
        {
          layout = wibox.container.background,
          fg = beautiful.fg_normal,
          bg = beautiful.bg_settings_display_number,
          shape = rounded(dpi(60)),
          forced_width = dpi(60),
          forced_height = dpi(60),
          wibox.container.place(
            {
              widget = wibox.widget.textbox,
              markup = label
            }
          )
        }
      }
    }
  )
end

-- wall is the scaled wallpaper (To reduce render times and memory consumption)
-- fullwall is a fullscreen (or original wallpaper)
-- the disable_number argument tells use if we should show the number in the center of the monitor
local function make_mon(wall, id, fullwall, disable_number)
  fullwall = fullwall or wall
  local monitor =
    wibox.widget {
    widget = wibox.widget.imagebox,
    shape = rounded(),
    clip_shape = rounded(),
    resize = true,
    forced_width = mon_size.w,
    forced_height = mon_size.h
  }
  monitor:set_image(wall)

  if Display_Mode == NORMAL_MODE then
    awful.tooltip {
      objects        = { monitor },
      text =  i18n.translate("Open the resolution and refresh rate editor")
    }
  end

  monitor:connect_signal(
    "button::press",
    function(_, _, _, btn)
      -- we check if button == 1 for a left mouse button (this way scrolling still works)
      if Display_Mode == WALLPAPER_MODE and btn == 1 then
        awful.spawn.easy_async(
          "tos theme set " .. fullwall,
          function()
            Display_Mode = NORMAL_MODE
            refresh()
            local themeFile = os.getenv("HOME") .. "/.config/tos/theme"
            -- our theme file exists
            if filesystem.exists(themeFile) then
              local newContent = ""
              for _, line in ipairs(filesystem.lines(themeFile)) do
                -- if the line is a file then it is a picture, otherwise it is a configuration option
                if not filesystem.exists(line) then
                  newContent = newContent .. line .. "\n"
                end
              end
              newContent = newContent .. fullwall
              filesystem.overwrite(themeFile, newContent)
            end
            -- collect the garbage to remove the image cache from memory
            collectgarbage("collect")
          end
        )
      end

      -- In this case someone wants to change a specific screen
      if Display_Mode == NORMAL_MODE and btn == 1 then
        print('Opening refresh rate and resolution editor')
        Display_Mode = REFRESH_MODE
        refresh(id)
      end
    end
  )
  if disable_number then
    return wibox.container.place(monitor)
  end
  return wibox.container.place(
    wibox.widget {
      layout = wibox.layout.stack,
      forced_width = mon_size.w,
      forced_height = mon_size.h,
      wibox.container.place(monitor),
      {
        layout = wibox.container.place,
        valign = "center",
        halign = "center",
        {
          layout = wibox.container.background,
          fg = beautiful.fg_normal,
          bg = beautiful.bg_settings_display_number,
          shape = rounded(dpi(100)),
          forced_width = dpi(100),
          forced_height = dpi(100),
          wibox.container.place(
            {
              widget = wibox.widget.textbox,
              font = beautiful.monitor_font,
              text = id
            }
          )
        }
      }
    }
  )
end

return function()
  local view = wibox.container.margin()
  view.left = m
  view.right = m
  view.bottom = m

  local title = wibox.widget.textbox(i18n.translate("Display"))
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local monitors = card()

  local layout = wibox.layout.grid()
  layout.spacing = m
  layout.forced_num_cols = 4
  layout.homogeneous = true
  layout.expand = true
  layout.min_rows_size = dpi(100)

  local brightness =
    slider(
    0,
    100,
    1,
    0,
    function(value)
      if _G.oled then
        awful.spawn("brightness -s " .. tostring(value) .. " -F", false)
      else
        awful.spawn("brightness -s 100 -F", false) -- reset pixel values when using backlight
        awful.spawn("brightness -s " .. tostring(value), false)
      end
    end
  )

  signals.connect_brightness(
    function(value)
      brightness.update(tonumber(value))
    end
  )

  local screen_time =
    slider(
    10,
    600,
    1,
    tonumber(general["screen_on_time"]) or 120,
    function(value)
      print("Updated screen time: " .. tostring(value) .. "sec")
      general["screen_on_time"] = tostring(value)
      configWriter.update_entry(os.getenv("HOME") .. "/.config/tos/general.conf", "screen_on_time", tostring(value))
      if general["screen_timeout"] == "1" or general["screen_timeout"] == nil then
        awful.spawn("pkill -f autolock.sh", false)
        awful.spawn("sh /etc/xdg/tde/autolock.sh " .. tostring(value), false)
      end
    end,
    function()
      return  i18n.translate("%s before sleeping", datetime.numberInSecToMS(tonumber(general["screen_on_time"]) or 120))
    end
  )


  local rounded_corner =
    slider(
    0,
    dpi(50),
    1,
    _G.save_state.rounded_corner or dpi(10),
    function(value)
      print("Setting rounded corner radius: " .. tostring(dpi(value)) .. "px")
     signals.emit_change_rounded_corner_dpi(dpi(value))
    end
  )

  local function gen_dpi_body()
    local v_layout = wibox.layout.fixed.vertical()
    local h_layout = wibox.layout.fixed.horizontal()

    h_layout:add(mat_icon_button(mat_icon(icons.settings, dpi(25))))
    h_layout:add(mat_icon_button(mat_icon(icons.network, dpi(25))))
    h_layout:add(mat_icon_button(mat_icon(icons.package, dpi(25))))
    h_layout:add(mat_icon_button(mat_icon(icons.about, dpi(25))))
    h_layout:add(mat_icon_button(mat_icon(icons.search, dpi(25))))

    h_layout.forced_height = dpi(40)

    v_layout:add(h_layout)
    v_layout:add(wibox.container.margin(button('Spooky...', function() end), dpi(10), dpi(10), dpi(10), dpi(10)))
    v_layout:add(wibox.container.margin(
      wibox.widget {
        text = i18n.translate('Spooky...'),
        font = beautiful.font_type .. ' ' .. dpi(10),
        widget = wibox.widget.textbox
      },
      dpi(10), dpi(10), dpi(10), dpi(10)))

    return v_layout
  end

  local dpi_examples = card("Example")

  local dpi_slider =
  slider(
  5,
  300,
  1,
  beautiful.xresources.dpi,
  function(value)
    print("Updated dpi: " .. tostring(value))

    local default = beautiful.xresources.dpi
    beautiful.xresources.set_dpi(value)

    dpi_examples.update_body(gen_dpi_body())

    beautiful.xresources.set_dpi(default)
  end
  )

  local dpi_save_button = button("Save", function()
    local value = tostring(math.floor(dpi_slider.get_number()))
    print("Saving dpi value: " .. value)
    local xresource_file = os.getenv("HOME") .. '/.Xresources'

    -- make the changes persistant
    filesystem.replace(xresource_file, "Xft.dpi:.*", "Xft.dpi: " .. value)
    awful.spawn({'xrdb', xresource_file}, false)

    awesome.restart()
  end)

  dpi_examples.update_body(
    gen_dpi_body()
  )

  dpi_save_button.forced_height = dpi(20)
  dpi_slider.forced_height = dpi(20)

  local changewall =
    button(
    "Change wallpaper",
    function()
      if not (Display_Mode == WALLPAPER_MODE) then
        Display_Mode = WALLPAPER_MODE
      else
        Display_Mode = NORMAL_MODE
      end
      refresh()
    end
  )
  changewall.top = m
  changewall.bottom = m

  local screenLayoutBtn =
    button(
    "Screen Layout",
    function()
      if not (Display_Mode == XRANDR_MODE) then
        Display_Mode = XRANDR_MODE
      else
        Display_Mode = NORMAL_MODE
      end
      refresh()
    end
  )
  screenLayoutBtn.top = m
  screenLayoutBtn.bottom = m

  body = scrollbox(layout)
  monitors.update_body(
    wibox.widget {
      layout = wibox.container.margin,
      margins = m,
      body
    }
  )

  local brightness_card = card()
  local screen_time_card = card()
  local rounded_corner_card = card()
  local dpi_card = card()

  local dpi_button_to = button("Change Application Scaling", function ()
    Display_Mode = DPI_MODE
    refresh()
  end)

  local dpi_button_back = button("Back", function ()
    Display_Mode = NORMAL_MODE
    refresh()
  end)

  brightness_card.update_body(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.margin,
        margins = m,
        {
          font = beautiful.font,
          text = i18n.translate("Brightness"),
          widget = wibox.widget.textbox
        }
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        bottom = m,
        brightness
      }
    }
  )
  screen_time_card.update_body(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.margin,
        margins = m,
        {
          font = beautiful.font,
          text = i18n.translate("Screen on time"),
          widget = wibox.widget.textbox
        }
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        bottom = m,
        screen_time
      }
    }
  )

  rounded_corner_card.update_body(
    wibox.widget {
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.margin,
        margins = m,
        {
          font = beautiful.font,
          text = i18n.translate("Rounded corners"),
          widget = wibox.widget.textbox
        }
      },
      {
        layout = wibox.container.margin,
        left = m,
        right = m,
        bottom = m,
        rounded_corner
      }
    }
  )

  local function go_to_dpi_widget()
    dpi_card.update_body(
      wibox.widget {
        layout = wibox.layout.fixed.vertical,
        {
          layout = wibox.container.margin,
          margins = m,
          {
            font = beautiful.font,
            text = i18n.translate("Change Application Scaling"),
            widget = wibox.widget.textbox
          }
        },
        {
          layout = wibox.container.margin,
          left = m,
          right = m,
          bottom = m,
          dpi_button_to
        }
      }
    )
  end

  local function return_from_dpi_widget()
    dpi_card.update_body(
      wibox.widget {
        layout = wibox.layout.fixed.vertical,
        {
          layout = wibox.container.margin,
          margins = m,
          {
            font = beautiful.font,
            text = i18n.translate("Change Application Scaling"),
            widget = wibox.widget.textbox
          }
        },
        {
          layout = wibox.container.margin,
          left = m,
          right = m,
          bottom = m,
          dpi_button_back
        }
      }
    )
  end

  go_to_dpi_widget()



  brightness_card.forced_height = (m * 6) + dpi(30)
  screen_time_card.forced_height = (m * 6) + dpi(30)
  rounded_corner_card.forced_height = (m * 6) + dpi(30)
  dpi_card.forced_height = (m * 6) + dpi(30)
  monitors.forced_height = dpi(400)

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.fixed.vertical,
        brightness_card,
        {
          layout = wibox.container.margin,
          top = m,
          screen_time_card
        },
        {
          layout = wibox.container.margin,
          top = m,
          rounded_corner_card
        },
        {
          layout = wibox.container.margin,
          top = m,
          dpi_card
        },
        {layout = wibox.container.margin, top = m, monitors},
        {layout = wibox.container.margin, top = m, changewall},
        {layout = wibox.container.margin, top = m, screenLayoutBtn}
      },
      nil
    }
  }

  -- The user option tells use if these are pictures supplied by the user
  local function load_monitor(k, table, done, user)
    local v = table[k]
    -- check if it is a file
    if filesystem.exists(v) then
      local base = filesystem.basename(v)
      -- TODO: 16/9 aspect ratio (we might want to calculate it form screen space)
      local width = dpi(300)
      local height = (width / 16) * 9
      local scaledImage = tempDisplayDir .. "/" .. base
      if user then
        scaledImage = tempDisplayDir .. "/user-" .. base
      end
      if filesystem.exists(scaledImage) and Display_Mode == WALLPAPER_MODE then
        layout:add(make_mon(scaledImage, k, v, true))
        if done then
          done(user, table, k)
        end
      else
        -- We use imagemagick to generate a "thumbnail"
        -- This is done to save memory consumption
        -- However note that our cache (tempDisplayDir) is stored in ram
        imagemagic.scale(
          v,
          width,
          height,
          scaledImage,
          function()
            if filesystem.exists(scaledImage) and Display_Mode == WALLPAPER_MODE then
              layout:add(make_mon(scaledImage, k, v, true))
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

  local recursive_monitor_load_func

  local function loadMonitors()
    local usr_files = filesystem.list_dir("/usr/share/backgrounds/tos")

    recursive_monitor_load_func = function(bool, table, i)
      if i < #table then
        i = i + 1
        load_monitor(i, table, recursive_monitor_load_func, bool)
      end
    end
    load_monitor(1, usr_files, recursive_monitor_load_func, false)
    local pictures = os.getenv("HOME") .. "/Pictures/tde"
    if filesystem.dir_exists(pictures) then
      local home_dir = filesystem.list_dir_full(pictures)
      -- true to tell the function that these are user pictures
      load_monitor(1, home_dir, recursive_monitor_load_func, true)
    end
  end

  local wallpaper_img = ''

  local function render_normal_mode()
    changewall.visible = true
    screenLayoutBtn.visible = true
    awful.spawn.with_line_callback(
      "tos theme active",
      {
        stdout = function(o)
          wallpaper_img = o
        end,
        output_done = function()
          -- TODO: get all screens
          local screens = xrandr.outputs ()

          if #screens < 4 then
            layout.forced_num_cols = #screens
          else
            layout.forced_num_cols = 4
          end

          -- generate the wallpaper (scaled)
          local base = filesystem.basename(wallpaper_img)
          -- TODO: 16/9 aspect ratio (we might want to calculate it form screen space)
          local width = dpi(600) / #screens
          local height = (width / 16) * 9
          monitorScaledImage = tempDisplayDir .. "/monitor-" .. base

          for _, display_name in ipairs(screens) do

            if filesystem.exists(monitorScaledImage) then
              layout:add(make_mon(monitorScaledImage, display_name, wallpaper_img))
            else
              -- We use imagemagick to generate a "thumbnail"
              -- This is done to save memory consumption
              -- However note that our cache (tempDisplayDir) is stored in ram
              imagemagic.scale(
                wallpaper_img,
                width,
                height,
                monitorScaledImage,
                function()
                  layout:add(make_mon(monitorScaledImage, display_name, wallpaper_img))
                end
              )
            end
          end
        end
      }
    )
  end

  local timer =
    gears.timer {
    timeout = 0.1,
    call_now = false,
    autostart = false,
    single_shot = true,
    callback = loadMonitors
  }

  local function render_wallpaper_mode()
    changewall.visible = true
    screenLayoutBtn.visible = false
    -- do an asynchronous render of all wallpapers
    timer:start()
    layout.forced_num_cols = 4
  end

  local function render_xrandr_mode()
    changewall.visible = false
    screenLayoutBtn.visible = true

    local permutated_screens = xrandr_menu()

    for _, tbl in ipairs(permutated_screens) do
      local label = tbl[1]
      local cmd = tbl[2]
      local screen_names = tbl[3]

      local widget = wibox.layout.flex.horizontal()
      widget:add(wibox.widget.textbox(label))
      for index = 1, #screen_names, 1 do
        local screen_wdgt = make_screen_layout(monitorScaledImage, screen_names[index])
        widget:add(wibox.container.margin(screen_wdgt, m, m, m, m))
      end

      local screen_btn =
        button(
        widget,
        function()
          print("Executing: " .. cmd)
          awful.spawn.easy_async_with_shell(
            cmd,
            function()
              awful.spawn("sh -c 'sleep 1 && which autorandr && autorandr --save tde --force'", false)
              Display_Mode = NORMAL_MODE
              refresh()
            end
          )
        end,
        active_pallet
      )
      layout:add(screen_btn)
      layout.forced_num_cols = 1
    end
  end

  local function render_dpi_mode()
    body.enable()
    layout.forced_num_cols = 1
    layout.min_rows_size = dpi(30)

    layout.homogeneous = false

    layout:add(
      dpi_save_button,
      dpi_slider,
      dpi_examples
    )
  end

  local function render_refresh_mode(monitor_id)
    body.disable()

    local x_out = xrandr.output_data()
    local monitor_information = x_out[monitor_id]

    layout.forced_num_cols = 1


    if monitor_information == nil then
      print('Invalid monitor aborting')
      local widget = wibox.widget.textbox(i18n.translate("%s is invalid", monitor_id))
      layout:add(widget)
      return
    end

    make_resolution_list(monitor_information, monitor_id)

    local widget = wibox.widget {
      resolution_card,
      wibox.widget.base.empty_widget(),
      wibox.widget {
        layout = wibox.layout.align.vertical,
        wibox.widget.base.empty_widget(),
        refresh_card,
        wibox.container.margin(button(
          "Save", function ()
            awful.spawn("sh -c '" .. refresh_rate_cmd .. " ; which autorandr && autorandr --save tde --force'", false)
            body.enable()

            Display_Mode = NORMAL_MODE
            refresh()
          end, active_pallet
          ), 0, 0, dpi(20), 0),
      },
      layout  = wibox.layout.ratio.horizontal
    }

    widget:adjust_ratio(2, 0.625, 0.05, 0.325)

    layout:add(wibox.widget {
      wibox.container.margin(button(
        "Back", function ()
          body.enable()

          Display_Mode = NORMAL_MODE
          refresh()
        end, active_pallet
        ), 0, 0, 0, dpi(20)),
      nil,
      widget,
      layout = wibox.layout.fixed.vertical
    })


  end

  refresh = function(monitor_id)
    layout:reset()
    layout.homogeneous = true
    layout.min_rows_size = dpi(100)
    body:reset()
    body.enable()

    -- remove all images from memory (to save memory space)
    collectgarbage("collect")

    awful.spawn.easy_async_with_shell(
      "brightness -g",
      function(o)
        brightness:set_value(math.floor(tonumber(o)))
      end
    )

    if Display_Mode ~= DPI_MODE then
      go_to_dpi_widget()
    else
      return_from_dpi_widget()
    end

    if Display_Mode == WALLPAPER_MODE then
      render_wallpaper_mode()
    elseif Display_Mode == XRANDR_MODE then
      render_xrandr_mode()
    elseif Display_Mode == REFRESH_MODE and monitor_id ~= nil then
      render_refresh_mode(monitor_id)
    elseif Display_Mode == DPI_MODE then
      render_dpi_mode()
    else
      -- In case the Display_Mode contains an invalid state
      Display_Mode = NORMAL_MODE
      render_normal_mode()
    end
  end

  signals.connect_refresh_screen(
    function()
      -- If we are in the screen layout mode, refresh it on screen refreshes
      if Display_Mode == XRANDR_MODE then
        refresh()
      end
    end
  )

  view.refresh = refresh
  return view
end
