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
local widgets = {}

widgets[1] = {
    x = 0.77,
    y = 0.05,
    width = 0.2,
    height = 0.4,
    type = "radial",
    resource = "CPU",
    title = "CPU Widget"
}

widgets[2] = {
    x = 0.77,
    y = 0.50,
    width = 0.2,
    height = 0.4,
    type = "radial",
    resource = "RAM",
    title = "RAM Widget"
}

widgets[3] = {
    x = 0.54,
    y = 0.05,
    width = 0.2,
    height = 0.4,
    type = "chart",
    resource = "CPU",
    title = "CPU Chart"
}

widgets[4] = {
    x = 0.54,
    y = 0.50,
    width = 0.2,
    height = 0.4,
    type = "chart",
    resource = "RAM",
    title = "RAM Chart"
}

return widgets
