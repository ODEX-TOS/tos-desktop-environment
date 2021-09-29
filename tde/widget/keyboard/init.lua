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
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local signals = require('lib-tde.signals')
local clickable_container = require("widget.material.clickable-container")
local common = require("lib-tde.function.common")
local flags_dir = "/etc/xdg/tde/widget/keyboard/flags/"

local scrollbox = require("lib-widget.scrollbox")
local button = require("lib-widget.button")
local inputfield = require("lib-widget.inputfield")
local card = require("lib-widget.card")

local quicksort = require("lib-tde.sort.quicksort")

local icons = require("theme.icons")

local selected_layouts = {}

local __country_cache = {}

local function make_layout_entry(layout)

    if __country_cache[layout] ~= nil then
        return __country_cache[layout]
    end

    local bIsSelected = false

    -- check if the layout already exists in the active_layouts
    for _, active_layout in ipairs(selected_layouts) do
        if active_layout == layout then
            bIsSelected = true
        end
    end

    local country_text = layout

    if awful.widget.keyboardlayout.xkeyboard_code_to_country ~= nil then
        country_text = awful.widget.keyboardlayout.xkeyboard_code_to_country[layout] or layout
    end

    local textbox = wibox.widget {
        text = country_text,
        align  = 'left',
        valign = 'center',
        font = beautiful.font,
        widget = wibox.widget.textbox
    }


    local _layout = wibox.widget {
        layout = wibox.layout.align.horizontal,
        textbox,
        wibox.widget.base.empty_widget(),
        wibox.widget {
            image = flags_dir .. layout .. '.svg',
            resize = true,
            forced_height = dpi(15),
            widget = wibox.widget.imagebox
        },
    }

    local margin = wibox.container.margin(_layout, dpi(15), dpi(7), dpi(7), dpi(7))

    local bg = wibox.widget {
        margin,
        bg     = beautiful.transparent,
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(10))
        end
    }

    -- in the initial condition we need to make sure that preselected items are already highligted and in the selected_layout opytion
    if bIsSelected then
        bg.bg = beautiful.primary.hue_800
    end


    bg:connect_signal("mouse::enter", function()
        bg.bg = beautiful.primary.hue_600
    end)

    bg:connect_signal("mouse::leave", function()
        if bIsSelected then
            bg.bg = beautiful.primary.hue_800
        else
            bg.bg = beautiful.transparent
        end
    end)

    signals.connect_primary_theme_changed(function(pallet)
        if bIsSelected then
            bg.bg = pallet.hue_800
        else
            bg.bg = beautiful.transparent
        end
	end)


    bg:connect_signal("button::release", function(_,_,_, btn)
        if btn == 1 and not bIsSelected then
            -- enable a given element
            table.insert(selected_layouts, layout)
            print(selected_layouts)
            bIsSelected = true
        elseif btn == 1 and bIsSelected then
            -- remove a given element
            bIsSelected = false
            for index, element in ipairs(selected_layouts) do
                if layout == element then
                    table.remove(selected_layouts, index)
                end
            end
        end
    end)

    bg.__layout_name = layout

    __country_cache[layout] = bg
    return bg
end


local function gen_panel(s, layouts)
    local panel_width = dpi(350)

    local panel
    local body = card("Keyboard Layout")

    local _widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5),
        forced_width = dpi(panel_width),
        bg = beautiful.background.hue_800 .. beautiful.background_transparency
    }

    for _, layout in ipairs(layouts) do
        _widget:add(make_layout_entry(layout))
    end

    local btn = button("Save", function()

        if #selected_layouts == 0 then
            print("You should at least select one layout option")
            return
        end

        tde.emit_signal("xkb::map_changed")
        tde.emit_signal("xkb::group_changed")

        if panel ~= nil then
            panel:close()
        end
    end)

    local scroll = scrollbox(_widget)

    local function country_is_a_match(country_code, search)
        if search == "" then
            return true
        end

        search = search:lower()

        local is_direct_match = string.find(country_code:lower(), search) ~= nil

        if is_direct_match then
            return true
        end

        -- we are not running under TDE/Twin but instead running under awesome
        if awful.widget.keyboardlayout.xkeyboard_code_to_country == nil then
            return false
        end

        -- Perhaps we are searching for a match to the country name instead of the country code
        local country = awful.widget.keyboardlayout.xkeyboard_code_to_country[country_code] or ""
        local is_country_match = string.find(country:lower(), search) ~= nil

        if is_country_match then
            return true
        end

        return false
    end

    local search = inputfield(function(text)
        scroll.reset()

        _widget.children = {}

        -- filter out the widgets inside the _widget based on the countryname/code
        for _, layout in ipairs(layouts) do
            if country_is_a_match(layout, text) then
                _widget:add(make_layout_entry(layout))
            end
        end
    end, nil, nil, nil, nil, icons.search)

    local ratio = wibox.widget {
        scroll,
        wibox.container.margin(search, 0,0, dpi(10), dpi(10)),
        btn,
        forced_height = s.geometry.height/2,
        layout = wibox.layout.ratio.vertical
    }

    ratio:adjust_ratio(2, 0.80, 0.10, 0.10)

    body.update_body(wibox.container.margin(ratio, dpi(7), dpi(7), dpi(7), dpi(7)))

    panel = awful.popup {
		widget = wibox.container.margin(body, dpi(7), dpi(7), dpi(7), dpi(7)),
		screen = s,
		type = 'dock',
		visible = false,
		ontop = true,
		width = dpi(panel_width),
		maximum_width = dpi(panel_width),
		maximum_height = s.geometry.height/2,
		bg = beautiful.background.hue_800 .. beautiful.background_transparency,
		fg = beautiful.fg_normal,
		shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(10))
        end
	}

    local backdrop = wibox {
		ontop = true,
		screen = s,
		bg = beautiful.transparent,
		type = 'utility',
		x = s.geometry.x,
		y = s.geometry.y,
		width = s.geometry.width,
		height = s.geometry.height
	}

    signals.connect_background_theme_changed(function(pallet)
        panel.bg = pallet.hue_800 .. beautiful.background_transparency
		_widget.bg = pallet.hue_800 .. beautiful.background_transparency
	end)


    panel.place = function()
        awful.placement.top_right(
            panel,
            {
                honor_workarea = true,
                parent = s,
                margins = {
                    top = dpi(33),
                    right = dpi(5)
                }
            }
        )
    end

    panel.open = function()
        backdrop.visible = true
        panel.visible = true
        scroll.reset()
        panel.place()
    end


    panel.close = function()
        backdrop.visible = false
        panel.visible = false
        search.stop_grabbing()
    end

    panel.toggle = function()
        if panel.visible then
            panel.close()
        else
            panel.open()
        end
    end

    backdrop:buttons(
		awful.util.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					panel.close()
				end
			)
		)
	)

    return panel
end



return function(s)
    local keyboard_layout = awful.widget.keyboardlayout({
        mouse_binding = false
    })

    local layout_codes = {}

    for k, _ in pairs(awful.widget.keyboardlayout.xkeyboard_country_code) do
        if #k == 2 then
            table.insert(layout_codes, k)
        end
    end

    local sorted = quicksort(layout_codes)

    selected_layouts = _G.save_state.keyboard.layouts

    local image = wibox.widget {
        resize = true,
        image = flags_dir .. selected_layouts[1] .. ".svg",
        widget = wibox.widget.imagebox
    }

    keyboard_layout.widget:set_text(selected_layouts[1])

    -- some layout's are in the form <country_code>-<layout_type>
    -- in that case we return only the country code, otherwise we return everything
    local function country_code(layout)
        local splitted_code = common.split(layout, '-')
        if #splitted_code > 0 then
            return splitted_code[1]
        end

        return layout
    end

    local function next_layout()
        if #selected_layouts < 2 then
            return
        end

        -- shift the entire list by one
        local new_list = {}
        for index, value in ipairs(selected_layouts) do
            if index ~= 1 then
                table.insert(new_list, value)
            end
        end
        table.insert(new_list, selected_layouts[1])
        selected_layouts = new_list

        -- update the text and change the layout
        keyboard_layout.widget:set_text(selected_layouts[1])
        image:set_image(flags_dir .. country_code(selected_layouts[1]) .. ".svg")
        print("Changed layout to: " .. selected_layouts[1])
        awful.spawn("setxkbmap " .. selected_layouts[1])
    end


    local _widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(5),
        wibox.container.place(image),
        nil,
        keyboard_layout.widget
    }

    local panel

    local widget_button = clickable_container(wibox.container.margin(_widget, dpi(14), dpi(14), dpi(7), dpi(7)))
			widget_button:buttons(
			gears.table.join(
				awful.button(
				{},
				1,
				nil,
				function()
					next_layout()
				end
				),
                awful.button(
				{},
				3,
				nil,
				function()
                    -- generate the panel on the first opening
                    -- Since we load in a lot of country images, it is best to wait until we need to load them into memory
                    if panel == nil then
                        panel = gen_panel(s, sorted)
                    end
					panel.toggle()
				end
				)
			)
	)

    signals.connect_keyboard_layout(function()
        next_layout()
    end)

    tde.connect_signal("xkb::map_changed", function()
        signals.emit_keyboard_layout_updated(selected_layouts, selected_layouts[1])
    end)
    tde.connect_signal("xkb::group_changed", function()
        signals.emit_keyboard_layout_updated(selected_layouts, selected_layouts[1])
    end)

    return widget_button
end
