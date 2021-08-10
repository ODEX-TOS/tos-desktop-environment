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
local theme_dir = '/etc/xdg/tde/theme'

local theme = {}

theme.icons = theme_dir .. '/icons/'
theme.font = 'Inter Regular 10'
theme.font_bold = 'Inter Bold 10'

-- Colorscheme
theme.system_black_dark = '#3D4C5F'
theme.system_black_light = '#56687E'

theme.system_red_dark = '#EE4F84'
theme.system_red_light = '#F48FB1'

theme.system_green_dark = '#53E2AE'
theme.system_green_light = '#A1EFD3'

theme.system_yellow_dark = '#F1FF52'
theme.system_yellow_light = '#F1FA8C'

theme.system_blue_dark = '#6498EF'
theme.system_blue_light = '#92B6F4'

theme.system_magenta_dark = '#985EFF'
theme.system_magenta_light = '#BD99FF'

theme.system_cyan_dark = '#24D1E7'
theme.system_cyan_light = '#87DFEB'

theme.system_white_dark = '#E5E5E5'
theme.system_white_light = '#F8F8F2'


-- Background color
theme.background_light = '#f2f2f266'

-- Transparent
theme.transparent = '#00000000'

-- Awesome icon
theme.awesome_icon = theme.icons .. 'awesome.svg'

return {
	theme = theme,
}
