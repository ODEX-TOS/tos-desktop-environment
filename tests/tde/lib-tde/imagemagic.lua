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
local magic = require("tde.lib-tde.imagemagic")

-- TODO: design tests to make sure our api calls to imagemagic work

function Test_imagemagic_api()
    assert(type(magic.scale) == "function", "Make sure the scale function exists in the magic api")
    assert(type(magic.grayscale) == "function", "Make sure the grayscale function exists in the magic api")
    assert(type(magic.transparent) == "function", "Make sure the transparent function exists in the magic api")
    assert(type(magic.compress) == "function", "Make sure the compress function exists in the magic api")
    assert(type(magic.convert) == "function", "Make sure the convert function exists in the magic api")
end

function Test_imagemagic_api_unit_tested()
    local amount = 5
    local result = tablelength(magic)
    assert(
        result == amount,
        "You didn't test all magic api endpoints, please add them then update the amount to: " .. result
    )
end
