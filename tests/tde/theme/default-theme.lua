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
local default = require("tde.theme.default-theme")
local theme = default.theme
local tdeOverride = default.tde_overrides
local filehandle = require("tde.lib-tde.file")
local dir_exists = filehandle.dir_exists
local file_exists = filehandle.exists

local function test_material_theme(colorscheme)
    assert(colorscheme.hue_50, "Make sure theme hue_50 exists")
    assert(colorscheme.hue_100, "Make sure theme hue_100 exists")
    assert(colorscheme.hue_200, "Make sure theme hue_200 exists")
    assert(colorscheme.hue_300, "Make sure theme hue_300 exists")
    assert(colorscheme.hue_400, "Make sure theme hue_400 exists")
    assert(colorscheme.hue_500, "Make sure theme hue_500 exists")
    assert(colorscheme.hue_600, "Make sure theme hue_600 exists")
    assert(colorscheme.hue_700, "Make sure theme hue_700 exists")
    assert(colorscheme.hue_800, "Make sure theme hue_800 exists")
    assert(colorscheme.hue_900, "Make sure theme hue_900 exists")

    -- the below are optional
    --assert(colorscheme.hue_A100, "Make sure theme hue_A100 exists" )
    --assert(colorscheme.hue_A200, "Make sure theme hue_A200 exists" )
    --assert(colorscheme.hue_A400, "Make sure theme hue_A400 exists" )
    --assert(colorscheme.hue_A700, "Make sure theme hue_A700 exists" )
end

local function is_color(str)
    local startsWithHash = str:sub(1, 1) == "#"
    local lenght = (#str == 4 or #str == 7 or #str == 9)
    local hasInvalidChars = false
    if startsWithHash then
        hasInvalidChars = str:sub(2, #str):match("[^a-fA-F0-9]")
    else
        hasInvalidChars = str:match("[^a-fA-F0-9]")
    end
    return startsWithHash and lenght and not hasInvalidChars and type(str) == "string"
end

function Test_theme_primary()
    assert(theme.primary, "Make sure theme primary exists")
    test_material_theme(theme.primary)
end

function Test_theme_accent()
    assert(theme.accent, "Make sure theme accent exists")
    test_material_theme(theme.accent)
end

function Test_theme_background()
    assert(theme.background, "Make sure theme background exists")
    test_material_theme(theme.background)
end

function Test_theme_foreground_color()
    assert(is_color(theme.text), "Make sure theme text exists")
end

function Test_theme_icon_dir()
    assert(dir_exists(theme.icons), "Make sure theme icons exists")
end

function Test_theme_dir()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(dir_exists(value.dir), "Make sure theme dir exists")
end

function Test_theme_font()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(type(value.font) == "string", "Make sure theme font exists")
    assert(type(value.title_font) == "string", "Make sure theme title_font exists")
end

function Test_theme_fg()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(is_color(value.fg_normal), "Make sure theme fg_normal exists")
    assert(is_color(value.fg_focus), "Make sure theme fg_focus exists")
    assert(is_color(value.fg_urgent), "Make sure theme fg_urgent exists")
    assert(is_color(value.bat_fg_critical), "Make sure theme bat_fg_critical exists")
end

function Test_theme_bg()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(is_color(value.bg_normal), "Make sure theme bg_normal exists")
    assert(is_color(value.bg_focus), "Make sure theme bg_focus exists")
    assert(is_color(value.bg_urgent), "Make sure theme bg_urgent exists")
    assert(is_color(value.bg_systray), "Make sure theme bg_systray exists")
    assert(is_color(value.bg_modal), "Make sure theme bg_modal exists")
    assert(is_color(value.bg_modal_title), "Make sure theme bg_modal_title exists")
end

function Test_theme_border()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(type(value.border_width) == "number", "Make sure theme border_widthexists")
    assert(is_color(value.border_normal), "Make sure theme border_normal exists")
    assert(is_color(value.border_focus), "Make sure theme border_focus exists")
    assert(is_color(value.border_marked), "Make sure theme border_marked exists")
end

function Test_theme_notification()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(is_color(value.transparent), "Make sure theme transparent exists")
    assert(is_color(value.notification_bg), "Make sure theme notification_bg exists")
    assert(is_color(value.notification_border_color), "Make sure theme notification_border_color exists")

    assert(type(value.notification_border_width) == "number", "Make sure theme notification_border_width exists")
    assert(type(value.notification_spacing) == "number", "Make sure theme notification_spacing exists")
    assert(type(value.notification_icon_size) == "number", "Make sure theme notification_icon_size exists")

    assert(type(value.notification_position) == "string", "Make sure theme notification_position exists")
    assert(
        type(value.notification_icon_resize_strategy) == "string",
        "Make sure theme notification_icon_resize_strategy exists"
    )
end

function Test_theme_group()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(is_color(value.groups_title_bg), "Make sure theme groups_title_bg exists")
    assert(is_color(value.groups_bg), "Make sure theme groups_bg exists")

    assert(type(value.groups_radius) == "number", "Make sure theme groups_radius exists")
end

function Test_theme_menu()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(type(value.menu_height) == "number", "Make sure theme menu_height exists")
    assert(type(value.menu_width) == "number", "Make sure theme menu_width exists")
end

function Test_theme_tooltip()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(is_color(value.tooltip_bg), "Make sure theme tooltip_bg exists")

    assert(type(value.tooltip_border_width) == "number", "Make sure theme tooltip_border_width exists")
end

function Test_theme_layout()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent,
        background_transparency = theme.background_transparency
    }
    tdeOverride(value)
    assert(file_exists(value.layout_max), "Make sure theme layout_max exists")
    assert(file_exists(value.layout_tile), "Make sure theme layout_tile exists")
    assert(file_exists(value.layout_dwindle), "Make sure theme layout_dwindle exists")
    assert(file_exists(value.layout_floating), "Make sure theme layout_floating exists")
    assert(file_exists(value.layout_fairv), "Make sure theme layout_fairv exists")
    assert(file_exists(value.layout_magnifier), "Make sure theme layout_magnifier exists")
end
