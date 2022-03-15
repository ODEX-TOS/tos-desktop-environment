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
local beautiful = require('beautiful')
local wibox = require('wibox')
local tag_renderer = require("lib-tde.tag_renderer")


local wallpaper =  _G.save_state.wallpaper.default_image or beautiful.wallpaper

local static_previous_wibox = wibox {
    ontop = true,
    screen = awful.screen.focused(),
    type = 'dock',
    visible = false,
}


local swipe_wibox = wibox {
    ontop = true,
    screen = awful.screen.focused(),
    type = 'dock',
    visible = false,
}

swipe_wibox.shape = function(cr, w, h)
    -- See the delta of x that is of the screen
    local delta_x = swipe_wibox.screen.geometry.x - swipe_wibox.x

    cr:rectangle(delta_x, 0, w, h)
end

local swipe_image = wibox.widget.imagebox(wallpaper, true)
swipe_image.valign = 'center'
swipe_image.vertical_fit_policy = 'fit'
swipe_image.scaling_quality = 'fast'

local static_previous_image = wibox.widget.imagebox(wallpaper, true)
static_previous_image.valign = 'center'
static_previous_image.vertical_fit_policy = 'fit'
static_previous_image.scaling_quality = 'fast'


local function lerp(start, finish, percentage)
    return start + (finish - start) * (percentage / 100)
end

local function handle_left_swipe(scrn, percentage)
    swipe_wibox.x = lerp(scrn.geometry.x - scrn.geometry.width, scrn.geometry.x, percentage)
end

local function handle_right_swipe(scrn, percentage)
    swipe_wibox.x = lerp(scrn.geometry.x + scrn.geometry.width, scrn.geometry.x, percentage)
end

local function handle_swipe_event(scrn, percentage, bFromLeftSide)

    swipe_wibox.screen = scrn

    -- we have finished swiping
    if percentage >= 100 or percentage <= 0 then
        swipe_wibox.visible = false
        return
    end

    -- We are in the middle of a swipe
    swipe_wibox.width  = scrn.geometry.width
    swipe_wibox.height = scrn.geometry.height
    swipe_wibox.y      = scrn.geometry.y

    swipe_image.forced_height = scrn.geometry.height
    swipe_image.forced_width = scrn.geometry.width

   if bFromLeftSide then
    handle_left_swipe(scrn, percentage)
   else
    handle_right_swipe(scrn, percentage)
   end

    swipe_wibox.visible = true
end

local function previous_old_school(tag, screen, percentage)
    local __surface = tag_renderer.fetch_from_tag_cache(tag) or tag_renderer.render_background(tag) or wallpaper
    swipe_image:set_image(__surface)


    handle_swipe_event(screen, percentage, true)
end

local function previous_new_school(tag, screen, percentage)
    local current_tag = screen.selected_tag

    -- Instead of showing the previous rendered tag, we show the previous tag and display the current on on top of it
    local __surface = tag_renderer.fetch_from_tag_cache(current_tag) or tag_renderer.render_tag_content_to_image(current_tag) or tag_renderer.render_background(current_tag) or wallpaper
    swipe_image:set_image(__surface)

    local __surface_previous = tag_renderer.fetch_from_tag_cache(tag) or tag_renderer.render_background(tag) or wallpaper
    static_previous_image:set_image(__surface_previous)

    static_previous_wibox.screen = screen

    -- We are in the middle of a swipe
    static_previous_wibox.width  = screen.geometry.width
    static_previous_wibox.height = screen.geometry.height
    static_previous_wibox.y      = screen.geometry.y
    static_previous_wibox.x      = screen.geometry.x

    static_previous_image.forced_height = screen.geometry.height
    static_previous_image.forced_width = screen.geometry.width

    static_previous_wibox.visible = true

    -- The swipe event needs to be painted on top of the static image
    handle_swipe_event(screen, 100 -percentage, false)
end

-- Global swipe events
tde.connect_signal("mouse::swipe_event::previous", function(percentage)
    local screen = awful.screen.focused()

    local index = screen.selected_tag.index - 1
    if index < 1 then
        index = 8
    elseif index > 8 then
        index = 1
    end

    local tag = screen.tags[index]

    if general["swipe_event_type"] == "new" or general["swipe_event_type"] == nil then
        previous_new_school(tag, screen, percentage)
    else
        previous_old_school(tag, screen, percentage)
    end
end)

tde.connect_signal("mouse::swipe_event::next", function(percentage)
    local screen = awful.screen.focused()

    local index = screen.selected_tag.index + 1
    if index < 1 then
        index = 8
    elseif index > 8 then
        index = 1
    end

    local tag = screen.tags[index]

    local __surface = tag_renderer.fetch_from_tag_cache(tag) or tag_renderer.render_background(tag) or wallpaper
    swipe_image:set_image(__surface)

    handle_swipe_event(screen, percentage, false)
end)


-- Let's keep a cached list of surfaces for each tag
screen.connect_signal("tag::history::update", function()
    -- Ensure that after a tag change the wibox is no longer visible, because we completed an animation
    swipe_wibox.visible = false
    static_previous_wibox.visible = false
end)

awful.screen.connect_for_each_screen(function(s)
    if s.index == 1 then
        swipe_wibox:setup {
	        layout = wibox.layout.align.horizontal,
            nil,
            swipe_image,
            nil
        }

        static_previous_wibox:setup {
	        layout = wibox.layout.align.horizontal,
            nil,
            static_previous_image,
            nil
        }
    end
end)
