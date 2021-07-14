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
local mouse = require("tde.lib-tde.mouse")

function Test_mouse_api_exists()
    assert(mouse.getInputDevices, "The getInputDevices function doesn't exist")
    assert(mouse.setAcceleration, "The setAccellaration function doesn't exist")
    assert(mouse.setMouseSpeed, "The setMouseSpeed function doesn't exist")
    assert(mouse.setNaturalScrolling, "The setNaturalScrolling function doesn't exist")
end

function Test_mouse_input_device_return_correct()
    local result = mouse.getInputDevices()
    assert(type(result) == "table", "The list of input devices should be a table")

    -- only run this when a mouse was found
    if #result > 0 then
        assert(type(result[1].name) == "string", "The input device list should have a name attribute")
        assert(type(result[1].id) == "number", "The input device list should have a id attribute")
    end
end

function Test_mouse_api_unit_tested()
    local amount = 4
    local result = tablelength(mouse)
    assert(
        result == amount,
        "You didn't test all mouse api endpoints, please add them then update the amount to: " .. result
    )
end
