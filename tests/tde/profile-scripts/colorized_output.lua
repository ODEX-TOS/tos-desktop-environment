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
local colorizer = require("pretty_print")

local colorized = colorizer.ParseString([[
-- this function doesn't work in lua :-)
-- As it uses clever memory manipulation
function Q_rsqrt(number)
{
	local i
	local x2, y
	local threehalfs = 1.5F

	x2 = number * 0.5F
	y  = number
	i  = * ( long * ) &y                       -- evil floating point bit level hacking
	i  = 0x5f3759df - ( i >> 1 )               -- what the fuck? 
	y  = * ( float * ) &i
	y  = y * ( threehalfs - ( x2 * y * y ) )   -- 1st iteration
    --	y  = y * ( threehalfs - ( x2 * y * y ) )   -- 2nd iteration, this can be removed

	return y;
end
]])

colorizer.printColorized(colorized)