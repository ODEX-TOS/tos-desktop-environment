local default = require("tde.theme.default-theme")
local theme = default.theme
local awesomeOverride = default.awesome_overrides
local dir_exists = require("tde.lib-tde.file").dir_exists

local function test_material_theme(colorscheme)
    assert(colorscheme.hue_50)
    assert(colorscheme.hue_100)
    assert(colorscheme.hue_200)
    assert(colorscheme.hue_300)
    assert(colorscheme.hue_400)
    assert(colorscheme.hue_500)
    assert(colorscheme.hue_600)
    assert(colorscheme.hue_700)
    assert(colorscheme.hue_800)
    assert(colorscheme.hue_900)

    -- the below are optional
    --assert(colorscheme.hue_A100)
    --assert(colorscheme.hue_A200)
    --assert(colorscheme.hue_A400)
    --assert(colorscheme.hue_A700)
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

function test_theme_primary()
    assert(theme.primary)
    test_material_theme(theme.primary)
end

function test_theme_accent()
    assert(theme.accent)
    test_material_theme(theme.accent)
end

function test_theme_background()
    assert(theme.background)
    test_material_theme(theme.background)
end

function test_theme_foreground_color()
    assert(is_color(theme.text))
end

function test_theme_icon_dir()
    assert(dir_exists(theme.icons))
end

function test_theme_dir()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(dir_exists(value.dir))
end

function test_theme_font()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(type(value.font) == "string")
    assert(type(value.title_font) == "string")
end

function test_theme_fg()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(is_color(value.fg_normal))
    assert(is_color(value.fg_focus))
    assert(is_color(value.fg_urgent))
    assert(is_color(value.bat_fg_critical))
end

function test_theme_bg()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(is_color(value.bg_normal))
    assert(is_color(value.bg_focus))
    assert(is_color(value.bg_urgent))
    assert(is_color(value.bg_systray))
    assert(is_color(value.bg_modal))
    assert(is_color(value.bg_modal_title))
end

function test_theme_border()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(type(value.border_width) == "number")
    assert(is_color(value.border_normal))
    assert(is_color(value.border_focus))
    assert(is_color(value.border_marked))
end

function test_theme_notification()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(is_color(value.transparent))
    assert(is_color(value.notification_bg))
    assert(is_color(value.notification_border_color))

    assert(type(value.notification_border_width) == "number")
    assert(type(value.notification_spacing) == "number")
    assert(type(value.notification_icon_size) == "number")

    assert(type(value.notification_position) == "string")
    assert(type(value.notification_icon_resize_strategy) == "string")
end

function test_theme_group()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(is_color(value.groups_title_bg))
    assert(is_color(value.groups_bg))

    assert(type(value.groups_radius) == "number")
end

function test_theme_menu()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(type(value.menu_height) == "number")
    assert(type(value.menu_width) == "number")
end

function test_theme_tooltip()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(is_color(value.tooltip_bg))

    assert(type(value.tooltip_border_width) == "number")
end

function test_theme_layout()
    local value = {
        background = theme.background,
        primary = theme.primary,
        accent = theme.accent
    }
    awesomeOverride(value)
    assert(file_exists(value.layout_max))
    assert(file_exists(value.layout_tile))
    assert(file_exists(value.layout_dwindle))
    assert(file_exists(value.layout_floating))
    assert(file_exists(value.layout_fairv))
    assert(file_exists(value.layout_magnifier))
end
