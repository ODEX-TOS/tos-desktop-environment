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
-- these global variables will be overwritten by the luapath file
-- We save them so we can reset them
local path = package.path
local cpath = package.cpath

require("tde.lib-tde.luapath")
local newPath = package.path
local newCpath = package.cpath

package.path = path
package.cpath = cpath

function Test_plugin_path()
    assert(
        newPath:match(os.getenv("HOME") .. "/.config/tde"),
        "Make sure " .. os.getenv("HOME") .. "/.config/tde exists in luapath"
    )
end

function Test_lib_lua_path()
    assert(newPath:match("lib[-]tde/lib[-]lua/[?]/[?].lua"), "Make sure tde/lib-lua is fully covered in luapath")
    assert(newPath:match("lib[-]tde/lib[-]lua/[?].lua"), "Make sure tde/lib-lua is fully covered in luapath")
end

function Test_lib_so_path()
    assert(newCpath:match("lib[-]tde/lib[-]so/[?]/[?].so"), "Make sure tde/lib-so is fully covered in luapath")
    assert(newCpath:match("lib[-]tde/lib[-]so/[?].so"), "Make sure tde/lib-so is fully covered in luapath")
end
