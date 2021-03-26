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
---------------------------------------------------------------------------
-- This module handles translation inside of TDE
--
-- You can use the default translations of TDE inside of our plugin.
-- Alternatively you can add more translations into tde, which is useful if your translations don't exist yet
--
--     -- i18n is exposed to the plugin authors without needing to re-declare it
--     -- They can already use default translations
--     i18n.translate("Calculator")
--     -- They can also add custom translations to the current language
--     if i18n.system_language() == "nl_be" then
--        i18n.custom_translations({
--         hello = "hallo",
--         day = "dag",
--          })
--     else if i18n.system_language() == "fr"journée
--         i18n.custom_translations({
--          hello = "bonjour",
--         day = "journée",
--         })
--     end
--     -- If the locale is dutch it becomes -> dag
--     -- If the locale is french it becomes -> journée
--     -- If it is any other language it becomes -> day (default)
--     i18n.translate("day")
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.i18n
---------------------------------------------------------------------------

local filehandle = require("lib-tde.file")
local common = require("lib-tde.function.common")
local gears = require("gears")
local err = "\27[0;31m[ ERROR "
local warn = "\27[0;33m[ WARN "

local system_language = "en"
local translations = {}
local init_loaded = false
local translationsPath = gears.filesystem.get_configuration_dir() .. "/lib-tde/translations"

local function detect_system_language()
    local envLang = os.getenv("LANG") or "en_US.UTF-8"
    if envLang == "" then
        system_language = "en"
    else
        system_language = common.split(envLang, "_")[1] or "en"
    end
end

local function _init(default)
    local translation_file = translationsPath .. "/" .. system_language .. ".lua"
    local translation_file_default = translationsPath .. "/" .. default .. ".lua"

    if filehandle.exists(translation_file) then
        translations = require(system_language)
    elseif filehandle.exists(translation_file_default) then
        print("I18N - translation file " .. tostring(translation_file) .. " doesn't exist, can't initialize", err)
        translations = require(default)
    else
        print(
            "I18N - translation file " ..
                tostring(translation_file_default) .. " doesn't exist (fallback), can't initialize",
            err
        )
        return false
    end
    return true
end

--- Used to initialize i18n, (detect system language and load in translations)
-- @tparam string default The default language to use in case no translations exist for the system language
-- @staticfct init
-- @usage -- Initialize i18n if the system language is not found default to English
-- i18n.init("en")
local function init(default)
    if init_loaded then
        print("I18N - already initialized, aborting", err)
        return false
    end
    detect_system_language()
    local res = _init(default)
    if not res then
        return res
    end
    init_loaded = true
    return true
end

--- Used to translate the line into the user language
-- @tparam string str The string to translate
-- @staticfct translate
-- @usage -- The word hello gets translated to the native language of the user
-- i18n.translate("hello") -- becomes hallo if the system language is dutch
local function translate(str)
    if not init_loaded then
        print("I18N - Cannot translate before initializing i18n use i18n.init() ", warn)
    end
    -- TDE treads all input strings into translation as English
    -- We always translate from English to an unknown language
    -- This statement bypasses the overhead of translating (because we don't need to translate)
    if system_language == "en" then
        return str
    end

    if translations then
        local translation = translations[str]
        if translation == nil then
            print("I18N - cannot find translation for '" .. str .. "'", warn)
            return str
        end
        return translation
    end
    return str
end

--- Add custom translations into the translation lookup table
-- @tparam table tbl The table holding key value pairs containing the new translations
-- @staticfct custom_translations
-- @usage -- add the translation hello -> hi
-- i18n.custom_translations({hello="hi"})
-- i18n.translate("hello") -- returns hi
local function custom_translations(tbl)
    for k, v in pairs(tbl) do
        translations[k] = v
    end
end

--- Get the active system language
-- @staticfct system_language
-- @usage -- Returns the current active translation language
-- i18n.system_language() -- returns the system language
local function getLanguage()
    return system_language
end

--- Change the system language to a new value (reloading the translation table, all old custom translations become lost)
-- @tparam string lang The new language to use
-- @staticfct set_system_language
-- @usage -- Update the language to English
-- i18n.set_system_language("en")
local function set_system_language(lang)
    print("I18N - setting system language to " .. lang)
    system_language = lang
    _init(system_language)
end

-- Undocumented function (don't show this to the user)
-- This disables the colored output so that
local function _disable_color()
    err = "[ ERROR "
    warn = "[ WARN "
end
return {
    init = init,
    translate = translate,
    custom_translations = custom_translations,
    system_language = getLanguage,
    set_system_language = set_system_language,
    _disable_color = _disable_color
}
