local i18n = require("tde.lib-tde.i18n")

function test_i18n_functions_exist()
    assert(type(i18n.init) == "function")
    assert(type(i18n.translate) == "function")
    assert(type(i18n.custom_translations) == "function")
    assert(type(i18n.system_language) == "function")
    assert(type(i18n.set_system_language) == "function")
end

function test_i18n_system_language()
    assert(i18n.system_language() == "en")
    i18n.set_system_language("dutch")
    assert(i18n.system_language() == "dutch")
    i18n.set_system_language("en")
    assert(i18n.system_language() == "en")
end

function test_i18n_custome_translations()
    -- we set the language to anything else than english
    -- because translating from english to english is not valid
    i18n.set_system_language("dutch")
    assert(i18n.translate("random") == "random")
    i18n.custom_translations(
        {
            random = "modnar"
        }
    )
    assert(i18n.translate("random") == "modnar")
    i18n.set_system_language("en")
end

function test_init_works()
    -- init the translations with default values
    assert(i18n.init("en"))
    assert(not i18n.init("en"))
end

function test_dutch_translations()
    i18n.set_system_language("dutch")
    local home = i18n.translate("home")
    local connection = i18n.translate("Wireless connection")

    i18n.set_system_language("en")
    assert(home == "huis")
    assert(connection == "Draadloze verbinding")
end
