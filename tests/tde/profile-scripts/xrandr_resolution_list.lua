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
i18n = {
    translate = function(str)
        return str
    end
}

general = {

}

screen = {
    primary = {
        dpi = 100
    }
}

local xrandr = require('lib-tde.xrandr')
local logger = require('lib-tde.logger')


screens = xrandr.output_data()

print(screens, logger.info, 5)

local res, rate = xrandr.highest_resolution(screens['eDP1'])

print(res)
print(rate)

local refresh_rate, resolution, index, tbl = xrandr.highest_refresh_rate(screens['eDP1'])
print(refresh_rate)
print(resolution)
print(tbl)

local refresh, index = xrandr.highest_refresh_rate_from_resolution(screens['eDP1'][res])

print(refresh)
print(index)