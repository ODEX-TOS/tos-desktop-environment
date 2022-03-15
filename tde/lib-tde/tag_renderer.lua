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
local cairo = require('lgi').cairo
local gears = require('gears')
local beautiful = require('beautiful')


local function xcb_surface_to_image_surface(cr, xcb_surface, geometry, screen_geo)
    local tmp = gears.surface.duplicate_surface(xcb_surface)

    local x = geometry.x - screen_geo.x
    local y = geometry.y - screen_geo.y


    cr:translate(x, y)
    cr:set_source_surface(tmp, 0, 0)
    cr:paint()
    cr:translate(-x, -y)
    tmp:finish()
end

local function wibox_to_image_surface(cr, wibox, screen_geo)
    xcb_surface_to_image_surface(cr, wibox.drawable.surface, wibox:geometry(), screen_geo)
end

local function paint_wallpaper(cr)
    local wallpaper = _G.save_state.wallpaper.default_image or beautiful.wallpaper

    local surface = gears.surface(wallpaper)

    -- Draw the surface over the entire cairo context
    cr:set_source_surface(surface, 0, 0)
    cr:paint()
end

local function is_visible(_client)
    return _client.valid and not _client.hidden and not _client.minimized and _client.opacity > 0
end

local function get_clients_on_tag(tag)
    local __clients = tag.screen.all_clients

    local __filtered = {}

    for _, _client in ipairs(__clients) do
        if _client:tags()[1] == tag and is_visible(_client) then
            table.insert(__filtered, _client)
        end
    end

    return __filtered
end

local function render_background(tag)
    local scrn = tag.screen or awful.screen.focused()

    local img = cairo.ImageSurface.create(cairo.Format.RGB24, scrn.geometry.width, scrn.geometry.height)
    local cr  = cairo.Context(img)

    -- First pass we paint the wallpaper
    paint_wallpaper(cr)

    -- Finally we paint tde wiboxes
    if scrn.bottom_panel and scrn.bottom_panel.visible then
        wibox_to_image_surface(cr, scrn.bottom_panel, scrn.geometry)
    end

    if scrn.top_panel and scrn.top_panel.visible then
        wibox_to_image_surface(cr, scrn.top_panel, scrn.geometry)
    end
    return img
end

local function render_tag_content_to_image(tag)
    local scrn = tag.screen or awful.screen.focused()

    local img = render_background(tag)
    local cr  = cairo.Context(img)

    -- Then we paint clients
    local viewable_clients = get_clients_on_tag(tag)
    -- Paint each client to the resulting image
    for _, clnt in ipairs(viewable_clients) do
        local _geo = clnt:geometry()
        xcb_surface_to_image_surface(cr, clnt.content, _geo, scrn.geometry)
    end


    if scrn.info_center and scrn.info_center.visible then
        wibox_to_image_surface(cr, scrn.info_center, scrn.geometry)
    end

    if scrn.control_center and scrn.control_center.visible then
        wibox_to_image_surface(cr, scrn.control_center, scrn.geometry)
    end

    if root.elements.settings and root.elements.settings.visible and root.elements.settings.screen == scrn then
        wibox_to_image_surface(cr, root.elements.settings, scrn.geometry)
    end

    return img
end

local __tag_cache = {}

local function request_render_of_current_tag(screen)
    screen = screen or awful.screen.focused()

    local tag = screen.selected_tag
    local name = tag.screen.name  .. '-' .. tostring(tag.index)


    -- Ensure we free the old surface
    if __tag_cache[name] ~= nil then
        __tag_cache[name]:finish()
    end

    __tag_cache[name] = render_tag_content_to_image(tag)
end

tde.connect_signal("tag::leave", function(tag)
        local name = tag.screen.name .. '-' ..tostring(tag.index)

        -- Ensure we free the old surface
        if __tag_cache[name] ~= nil then
            __tag_cache[name]:finish()
        end

        __tag_cache[name] = render_tag_content_to_image(tag)

        -- The tag just changed again which invalidated the screen.content
        if tag ~= awful.screen.focused().selected_tag then
            __tag_cache[name]:finish()
            __tag_cache[name] = nil
        end
end)

local function fetch_from_tag_cache(tag)
    return __tag_cache[tag.screen.name  .. '-' .. tostring(tag.index)]
end

return {
    render_tag_content_to_image = render_tag_content_to_image,
    fetch_from_tag_cache = fetch_from_tag_cache,
    render_background = render_background,
    request_render_of_current_tag = request_render_of_current_tag
}