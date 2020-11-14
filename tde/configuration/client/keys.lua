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
require("awful.autofocus")
local config = require("configuration.keys.mod")
local modkey = config.modKey

local clientKeys =
  awful.util.table.join(
  awful.key(
    {modkey},
    config.fullscreen,
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = i18n.translate("toggle fullscreen"), group = i18n.translate("client")}
  ),
  awful.key(
    {modkey},
    config.kill,
    function(c)
      c:kill()
    end,
    {description = i18n.translate("close"), group = i18n.translate("client")}
  ),
  awful.key(
    {modkey},
    config.floating,
    function(c)
      c.floating = not c.floating
      c:raise()
    end,
    {description = i18n.translate("toggle floating"), group = i18n.translate("client")}
  )
)

return clientKeys
