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
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local icons = require("theme.icons")
local mat_colors = require("theme.mat-colors")
local wibox = require("wibox")
local menubar = require("menubar")

local keys = require("configuration.keys.mod")

local highlight_text = require("lib-tde.function.common").highlight_text

local focused = require("lib-tde.function.common").focused_screen

local button = require("lib-widget.button")

-- our loader widget while we wait for the tip to complete
local loader = require("lib-widget.loading")()
loader.stop()

local tutorial_widget = require("widget.tutorial")

local app_width = dpi(600)
local app_height = dpi(500)
local m = dpi(10)

local stop_tip = function () end

local terminal_icon = menubar.utils.lookup_icon("terminal") or icons.logo
local settings_icon = menubar.utils.lookup_icon("preferences-desktop-theme") or icons.logo

local super = keys.modKey

local function get_key(key)

    if string.sub(key, 1,1) ~= "#" then
        return key
    end

    local long, utf8 = tde._get_key_name(key)

    if utf8 ~= "" and utf8 ~= nil then
        return utf8
    end

    if long ~= nil and long ~= "" then
        return long
    end

    return key
end

local function highlight_key(_keys)
    local res = get_key(_keys[1] or super)

    for i, k in ipairs(_keys) do
        if i > 1 then
            res = res .. '+' .. (get_key(k) or k)
        end
    end

    return highlight_text(res)
end

local tips = {
    {
        text = i18n.translate("Welcome to TDE %s", "\n\n🎉🎉🎉"), img = icons.logo, cb = function(done_cb, stop_cb)
            local stopped = false

            stop_cb(function() stopped = true end)

            gears.timer.start_new(5, function() if not stopped then done_cb() end end)
        end,
        loading = false
    },
    {
        text = i18n.translate("Open up an application by using the keys %s or by pressing the search icon in the top right", highlight_key({super, keys.launcher})), img = icons.search, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    awful.spawn.easy_async("pgrep rofi", function(_, _, _, code)
                        if code == 0 and not stopped then
                            done_cb()
                        end
                    end)
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Open up an Terminal by pressing %s", highlight_key({super, keys.terminal})), img = terminal_icon, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    for _, c in ipairs(client.get()) do
                        if c.class == "st-256color" and not stopped then
                            done_cb()
                        end
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Close the Terminal by pressing %s", highlight_key({super, keys.kill})), img = icons.close, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    local st_found = false

                    for _, c in ipairs(client.get()) do
                        if c.class == "st-256color" then
                            st_found = true
                        end
                    end

                    if not st_found and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Now open 3 terminals using %s", highlight_key({super, keys.terminal})), img = terminal_icon, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    local count = 0
                    for _, c in ipairs(client.get()) do
                        if c.class == "st-256color" then
                            count = count + 1
                        end
                    end

                    if count >= 3 and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Great job!!! Do you notice how they tile?"), img = beautiful.layout_tile or icons.logo, cb = function(done_cb, stop_cb)
            local stopped = false

            stop_cb(function() stopped = true end)

            gears.timer.start_new(5, function() if not stopped then done_cb() end end)
        end,
        loading = false
    },
    {
        text = i18n.translate("Try pressing %s a couple of times and notice how your applications change", highlight_key({super, keys.nextLayout})), img = beautiful.layout_tile or icons.logo, cb = function(done_cb, stop_cb)
            local stopped = false

            local start_tile = awful.screen.focused().selected_tag.layout.name
            local count = 0

            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    local new_tile = awful.screen.focused().selected_tag.layout.name

                    if new_tile ~= start_tile then
                        count = count + 1
                        start_tile = new_tile
                    end

                    if count >= 3 and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)
        end,
        loading = true
    },
    {
        text = i18n.translate("You can change the focus around using %s", highlight_text("Super + ⬆/➡/⬇/⬅")), img = icons.mouse, cb = function(done_cb, stop_cb)
            local stopped = false

            if client.focus then
                local start_client = client.focus.pid

                local timer = gears.timer {
                    timeout = 2,
                    autostart = true,
                    call_now = false,
                    callback = function()
                        if stopped then return end

                        if client.focus == nil then
                            return
                        end

                        if client.focus.pid ~= start_client and not stopped  then
                            done_cb()
                        end
                    end
                }

                stop_cb(function()
                    stopped = true
                    timer:stop()
                end)
            end
        end,
        loading = true
    },
    {
        text = i18n.translate("Wonderfull, you changed the focus around"), img = icons.mouse, cb = function(done_cb, stop_cb)
            local stopped = false

            stop_cb(function() stopped = true end)

            gears.timer.start_new(3, function() if not stopped then done_cb() end end)
        end,
        loading = false
    },
    {
        text = i18n.translate("You can move application around much like changing focus using the %s keys", highlight_text("Super + Shift + ⬆/➡/⬇/⬅")), img = icons.mouse, cb = function(done_cb, stop_cb)
            local stopped = false

            if client.focus then
                local start_client_location = client.focus.x
                local start_client_pid = client.focus.pid

                local timer = gears.timer {
                    timeout = 2,
                    autostart = true,
                    call_now = false,
                    callback = function()
                        if stopped then return end

                        if client.focus == nil then
                            return
                        end

                        if client.focus.x ~= start_client_location and start_client_pid == client.focus.pid and not stopped  then
                            done_cb()
                        end
                    end
                }

                stop_cb(function()
                    stopped = true
                    timer:stop()
                end)
            end
        end,
        loading = true
    },
    {
        text = i18n.translate("Close the terminals until you have one left using %s", highlight_key({super, keys.kill})), img = terminal_icon, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    local count = 0
                    for _, c in ipairs(client.get()) do
                        if c.class == "st-256color" then
                            count = count + 1
                        end
                    end

                    if count == 1 and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Let's move this terminal to a new %s by using the following key combination %s", highlight_text("'tag'"), highlight_key({super, "Shift","2"})), img = terminal_icon, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    local st = nil

                    for _, c in ipairs(client.get()) do
                        if c.class == "st-256color" then
                            st = c
                        end
                    end

                    if st == nil then
                        return
                    end

                    if st.screen.selected_tag.index == 2 and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Close all open Terminals by pressing %s", highlight_key({super, keys.kill})), img = icons.close, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    local st_found = false

                    for _, c in ipairs(client.get()) do
                        if c.class == "st-256color" then
                            st_found = true
                        end
                    end

                    if not st_found and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Now you can also open the settings using %s", highlight_key({super, keys.settings})), img = settings_icon, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    if root.elements.settings.visible and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Open the installer by clicking on the installer on the desktop"), img = menubar.utils.lookup_icon("calamares") or icons.logo, cb = function(done_cb, stop_cb)
            local stopped = false
            local timer = gears.timer {
                timeout = 2,
                autostart = true,
                call_now = false,
                callback = function()
                    if stopped then return end

                    local installer_found = false

                    for _, c in ipairs(client.get()) do
                        if c.class == "calamares" then
                            installer_found = true
                        end
                    end

                    if installer_found and not stopped then
                        done_cb()
                    end
                end
            }

            stop_cb(function()
                stopped = true
                timer:stop()
            end)


        end,
        loading = true
    },
    {
        text = i18n.translate("Here is an extra tip, you can view the keyboard shortcuts using %s", highlight_key({super, "F1"})), img = icons.logo, cb = function(done_cb, stop_cb)
            local stopped = false

            stop_cb(function() stopped = true end)

            gears.timer.start_new(3, function() if not stopped then done_cb() end end)
        end,
        loading = false
    },
    {
        text = i18n.translate("You have learned the basics of %s", highlight_text("TDE")), img = icons.logo, cb = function(done_cb, stop_cb)
            local stopped = false

            stop_cb(function() stopped = true end)

            gears.timer.start_new(3, function() if not stopped then done_cb() end end)
        end,
        loading = false
    },
    {
        text = i18n.translate("Good luck and have fun on your %s adventure %s", highlight_text("TDE"), "💜"), img = icons.logo, cb = function(done_cb, stop_cb)
            local stopped = false

            stop_cb(function() stopped = true end)

            gears.timer.start_new(3, function() if not stopped then done_cb() end end)
        end,
        loading = false
    },
}

local tip_index = 1


local function finish()
    local HOME = os.getenv("HOME")
    local FILE = HOME .. "/.cache/tutorial_tos"
    io.open(FILE, "w"):write("tutorial is complete"):close()
end


local function create_app()
    local s = focused()
    local hub =
      wibox(
      {
        ontop = true,
        visible = true,
        type = "toolbar",
        bg = beautiful.background.hue_800 .. beautiful.background_transparency,
        width = app_width,
        height = app_height,
        x = ((s.workarea.width / 2) - (app_width / 2)) + s.workarea.x,
        y = ((s.workarea.height - app_height - m) / 2) + s.workarea.y,
        screen = s,
        shape = function(cr, shapeWidth, shapeHeight)
          gears.shape.rounded_rect(cr, shapeWidth, shapeHeight, _G.save_state.rounded_corner)
        end,
        widget = wibox.container.place(loader)
      }
    )

    local bIsDragging = false

    local header = wibox.widget {
        layout = wibox.layout.align.horizontal,
        button({
                body = {
                layout = wibox.container.margin,
                top = m,
                bottom = m,
                left = m,
                right = m,
                wibox.widget.textbox(i18n.translate("Previous"))
            },
            callback = function()
                stop_tip()

                tip_index = tip_index - 1

                local tip = tips[tip_index]

                if tip == nil then
                    tip_index = 1
                    tip = tips[tip_index]
                end

                hub.set_tip(tip)
            end,
            pallet = mat_colors.grey,
            no_update = true
        }),
        wibox.widget{
            text = i18n.translate("Tutorial"),
            align  = 'center',
            valign = 'center',
            font = beautiful.title_font,
            widget = wibox.widget.textbox
        },
        button({
            body = {
                layout = wibox.container.margin,
                top = m,
                bottom = m,
                left = m,
                right = m,
                wibox.widget.textbox(i18n.translate("Next"))
            },
            callback = function()
                stop_tip()

                tip_index = tip_index + 1

                local tip = tips[tip_index]

                if tip == nil then
                    hub.visible = false
                    return
                end

                hub.set_tip(tip)
            end
        }),
    }

    header:connect_signal("button::press", function()
        if bIsDragging then
          return
        end
        bIsDragging = true
        awful.mouse.wibox.move(hub, function()
          bIsDragging = false
        end)
    end)



    hub.set_tip = function(tip)
        local tip_w = tutorial_widget(i18n.translate(tip.text), tip.img)

        if tip.loading then
            loader.start()
            hub.widget = wibox.widget {
                wibox.container.margin(header, m, m, m, m),
                wibox.container.place(loader),
                wibox.container.place(tip_w),
                layout = wibox.layout.ratio.vertical,
            }
        else
            hub.widget = wibox.widget {
                wibox.container.margin(header, m, m, m, m),
                wibox.widget.base.empty_widget(),
                wibox.container.place(tip_w),
                layout = wibox.layout.ratio.vertical,
            }
        end

        hub.widget:adjust_ratio(2, 0.1, 0.1, 0.8)


        local function done_cb()
            if stop_tip then stop_tip() end
            loader.stop()

            tip_index = tip_index + 1

            local _tip = tips[tip_index]

            if _tip == nil then
                finish()
                hub.visible = false
            else
                hub.set_tip(_tip)
            end
        end

        local function stop_cb(stop)
            stop_tip = stop
        end

        -- this function gets called when the tip is done
        tip.cb(done_cb, stop_cb)
    end

    return hub
end


local function start()
    print("Showing tutorial")
    local app = create_app()

    local tip = tips[tip_index]

    app.set_tip(tip)
end

local HOME = os.getenv("HOME")
local FILE = HOME .. "/.cache/tutorial_tos"
if require("lib-tde.file").exists(FILE) then
    print("Tutorial has already been shown")

    return start
else
    gears.timer.start_new(
        3,
        function()
            start()
        end
    )
end

