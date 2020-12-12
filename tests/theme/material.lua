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
local colors = require("tde.theme.mat-colors")

local function is_material_design_pallet(pallet)
    assert(type(pallet) == "table")
    assert(pallet.hue_50)
    assert(pallet.hue_100)
    assert(pallet.hue_200)
    assert(pallet.hue_300)
    assert(pallet.hue_400)
    assert(pallet.hue_500)
    assert(pallet.hue_600)
    assert(pallet.hue_700)
    assert(pallet.hue_800)
    assert(pallet.hue_900)
end

function test_mat_colors_exists()
    assert(colors)
    assert(type(colors) == "table")
end

function test_mat_colors_exists_red()
    is_material_design_pallet(colors.red)
end

function test_mat_colors_exists_pink()
    is_material_design_pallet(colors.pink)
end

function test_mat_colors_exists_purple()
    is_material_design_pallet(colors.purple)
end

-- deep purple
function test_mat_colors_exists_hue_purple()
    is_material_design_pallet(colors.hue_purple)
end

function test_mat_colors_exists_indigo()
    is_material_design_pallet(colors.indigo)
end

function test_mat_colors_exists_blue()
    is_material_design_pallet(colors.blue)
end

-- light blue
function test_mat_colors_exists_hue_blue()
    is_material_design_pallet(colors.hue_blue)
end

function test_mat_colors_exists_cyan()
    is_material_design_pallet(colors.cyan)
end

function test_mat_colors_exists_teal()
    is_material_design_pallet(colors.teal)
end

function test_mat_colors_exists_green()
    is_material_design_pallet(colors.green)
end

-- Light Green
function test_mat_colors_exists_hue_green()
    is_material_design_pallet(colors.hue_green)
end

function test_mat_colors_exists_lime()
    is_material_design_pallet(colors.lime)
end

function test_mat_colors_exists_yellow()
    is_material_design_pallet(colors.yellow)
end

function test_mat_colors_exists_amber()
    is_material_design_pallet(colors.amber)
end

function test_mat_colors_exists_orange()
    is_material_design_pallet(colors.orange)
end

function test_mat_colors_exists_deep_orange()
    is_material_design_pallet(colors.deep_orange)
end

function test_mat_colors_exists_brown()
    is_material_design_pallet(colors.brown)
end

function test_mat_colors_exists_grey()
    is_material_design_pallet(colors.grey)
end

function test_mat_colors_exists_blue_grey()
    is_material_design_pallet(colors.blue_grey)
end

function test_mat_colors_exists_black()
    is_material_design_pallet(colors.black)
end

function test_mat_colors_exists_white()
    is_material_design_pallet(colors.white)
end

function test_mat_colors_exists_light()
    is_material_design_pallet(colors.light)
end
