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
local icons = require("theme.icons")
local theme = require("theme.icons.dark-light")

local internal_plugins = {}

-- topbar plugins
internal_plugins["widget.todo"] = {
    name = "Todo list",
    metadata = {
        type = "topbar",
        internal_plugin = true,
        icon = icons.check,
        version = tde.version,
        description = "A simple todo list in the topbar",
        description_nl = "Een simpele todo lijst in de topbar",
    }
}

internal_plugins["widget.countdown"] = {
    name = "Countdown Timer",
    metadata = {
        type = "topbar",
        internal_plugin = true,
        icon = icons.clock_add,
        version = tde.version,
        description = "A timer to notify you when an event happens",
        description_nl = "Een klok die u verwittigt wanneer er iets gebeurt"
    }
}

-- notification plugins
internal_plugins["widget.user-profile"] = {
    name = "User profile",
    metadata = {
        type = "notification",
        internal_plugin = true,
        icon = icons.user,
        version = tde.version,
        description = "Show user information",
        description_nl = "Toon gebruiker informatie"
    }
}

internal_plugins["widget.social-media"] = {
    name = "Social Media",
    metadata = {
        type = "notification",
        internal_plugin = true,
        icon = theme("/etc/xdg/tde/widget/social-media/icons/reddit.svg"),
        version = tde.version,
        description = "Social media browser links",
        description_nl = "Sociale media browser links"
    }
}

internal_plugins["widget.weather"] = {
    name = "Weather",
    metadata = {
        type = "notification",
        internal_plugin = true,
        icon = theme("/etc/xdg/tde/widget/weather/icons/sun_icon.svg"),
        version = tde.version,
        description = "Show weather information",
        description_nl = "Toon weer informatie"
    }
}

internal_plugins["widget.sars-cov-2"] = {
    name = "Corona stats",
    metadata = {
        type = "notification",
        internal_plugin = true,
        icon = theme("/etc/xdg/tde/widget/sars-cov-2/icons/corona.svg"),
        version = tde.version,
        description = "Show corona statistics of your country",
        description_nl = "Toon corona statistieken van jou land"
    }
}

internal_plugins["widget.calculator"] = {
    name = "Calculator",
    metadata = {
        type = "notification",
        internal_plugin = true,
        icon = icons.calc,
        version = tde.version,
        description = "A basic calculator",
        description_nl = "Een simpel rekenmachien"
    }
}

return internal_plugins