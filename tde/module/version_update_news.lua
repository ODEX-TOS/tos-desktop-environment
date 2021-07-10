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
local signals = require("lib-tde.signals")
local wibox = require("wibox")
local gears = require("gears")

local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local common = require("lib-tde.function.common")
local version = common.major_version()
local split = common.split

local icons = require("theme.icons")

local button = require("lib-widget.button")
local scrollbox = require("lib-widget.scrollbox")

local function to_obj(news)
    local section
    local prev_section = nil
    local news_topics = {}
    for _, line in ipairs(news) do
        section = line:match("### (.*)")

        if section ~= nil then
            prev_section = section
        end

        if prev_section ~= nil and news_topics[prev_section] == nil then
            news_topics[prev_section] = ""
        end

        if prev_section ~= nil and section == nil then
            news_topics[prev_section] = news_topics[prev_section] .. line .. "\n"
        end
    end

    return news_topics
end

local function extract_news_from_markdown(stdout)
    local lines = split(stdout, "\n")
    local isInCurrentNews = false
    local news_lines = {}
    for _, line in ipairs(lines) do
        local patchVersion = line:match("## Patch (%d+%.%d+)")
        if patchVersion ~= nil and tonumber(patchVersion) == version then
            isInCurrentNews = true
        elseif patchVersion ~= nil then
            isInCurrentNews = false
        end

        if isInCurrentNews then
            table.insert(news_lines, line)
        end
    end

    return to_obj(news_lines)
end

local function create_news_widget(news)
    local layout = wibox.layout.fixed.vertical()

    layout:add(
        wibox.widget{
            text = i18n.translate("Release Notes"),
            align = "center",
            font = beautiful.title_font,
            widget = wibox.widget.textbox
        }
    )
    layout:add(wibox.container.margin(wibox.widget{
        text = news["Release Notes"] or "",
        align = "center",
        font = beautiful.font,
        widget = wibox.widget.textbox
    }, 0, 0, 0, dpi(20)))

    for name, part in pairs(news) do
        -- Dev Notes are not intended to be shown in the release notes
        if name ~= "Dev Notes" and name ~= "Release Notes" then
            layout:add(wibox.widget{
                text = name,
                font = beautiful.title_font,
                widget = wibox.widget.textbox
            })
            local text, _ = string.gsub(part, '\n', '\n\t')
            layout:add(wibox.container.margin(wibox.widget.textbox('\t' .. text), 0, 0, 0, dpi(20)))
        end
    end

    local box = scrollbox(layout)

    return wibox.container.margin(wibox.widget {
        wibox.container.margin(box, dpi(5), 0, dpi(5), 0),
        bg = beautiful.bg_modal_title,
        widget = wibox.container.background,
        shape = function(cr, shapeWidth, shapeHeight)
            gears.shape.rounded_rect(cr, shapeWidth, shapeHeight, dpi(12))
        end
    }, dpi(12), dpi(12), dpi(12), dpi(12))
end

local function create_wiboxes(news)
    awful.screen.connect_for_each_screen(
  function(s)
        local min_height = dpi(400)
        local image_height = dpi(150)
        local margin = dpi(10)

        local height = math.max(min_height, s.geometry.height / 2)
        local newsOverlay =
        wibox(
        {
            visible = false,
            ontop = true,
            type = "normal",
            height = height,
            width = s.geometry.width / 2,
            bg = beautiful.background.hue_800 .. beautiful.background_transparency,
            x = s.geometry.x + s.geometry.width / 4,
            y = s.geometry.y + (height / 2),
            shape = function(cr, shapeWidth, shapeHeight)
                gears.shape.rounded_rect(cr, shapeWidth, shapeHeight, dpi(12))
            end
        }
        )

        signals.connect_background_theme_changed(function(pallet)
            newsOverlay.bg = pallet.hue_800 .. beautiful.background_transparency
        end)

        screen.connect_signal(
        "removed",
        function(removed)
            if s == removed then
                newsOverlay.visible = false
                newsOverlay = nil
            end
        end
        )

        local text_info = create_news_widget(news)
        text_info.forced_height = height - image_height - (margin * 3) - dpi(60)


        signals.connect_refresh_screen(
        function()
            print("Refreshing news screen")
            if not s.valid or newsOverlay == nil then
                return
            end
            height = math.max(min_height, s.geometry.height / 2)
            -- the action center itself
            newsOverlay.x = s.geometry.x + s.geometry.width / 4
            newsOverlay.y = s.geometry.y + (height / 2)
            newsOverlay.width = s.geometry.width / 2
            newsOverlay.height = height
        end
        )

        -- Put its items in a shaped container
        newsOverlay:setup {
            -- Container
            {
                wibox.container.margin(wibox.container.place(wibox.widget{
                    image = icons.news_Large,
                    resize = true,
                    forced_height = image_height,
                    widget = wibox.widget.imagebox,
                }), margin, margin,margin,margin),
                wibox.widget{
                    text = i18n.translate("News") .. ' TDE ' .. tostring(version) .. ' (' .. awesome.release .. ')',
                    align = "center",
                    font = beautiful.title_font,
                    widget = wibox.widget.textbox
                },
                text_info,
                wibox.container.margin(button("Read", function()
                    common.focused_screen().newsOverlay.hide()
                end), margin, margin,margin,margin),
                layout = wibox.layout.fixed.vertical
            },
            -- The real background color
            bg = beautiful.background.hue_800 .. beautiful.background_transparency,
            valign = "center",
            halign = "center",
            widget = wibox.container.place()
        }

        local newsbackdrop =
            wibox {
                ontop = true,
                visible = false,
                screen = s,
                bg = "#000000aa",
                type = "dock",
                x = s.geometry.x,
                y = s.geometry.y,
                width = s.geometry.width,
                height = s.geometry.height - dpi(40)
            }

        newsOverlay.show = function()
            newsbackdrop.visible = true
            newsOverlay.visible = true
        end

        newsOverlay.hide = function()
            newsbackdrop.visible = false
            newsOverlay.visible = false

            signals.emit_showed_news()
        end

        s.newsOverlay = newsOverlay
end
)
end

local function show_news(news)
    print("Showing news")
    print(news)
    create_wiboxes(news)

    common.focused_screen().newsOverlay.show()
end

if version > _G.save_state.last_version then
    print("We have a newer tde version")
    -- lets fetch the news asynchronously
    local cmd = [[curl -s https://raw.githubusercontent.com/ODEX-TOS/tos-desktop-environment/release/NEWS.md]]
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
        local news = extract_news_from_markdown(stdout or "")
        show_news(news)
    end)
end

