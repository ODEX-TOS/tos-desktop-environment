-- This profile shoud run in O(n) times

require("lib-tde.luapath")
local i18n = require("lib-tde.i18n")

i18n.init("en")
i18n.set_system_language("dutch")

-- do a lot of translations
for _ = 1, 50000 do
    i18n.translate("wireless")
    i18n.translate("OS Name")
end
