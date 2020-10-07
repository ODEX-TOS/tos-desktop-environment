-- these global variables will be overwritten by the luapath file
-- We save them so we can reset them
local path = package.path
local cpath = package.cpath

require("tde.lib-tde.luapath")
local newPath = package.path
local newCpath = package.cpath

package.path = path
package.cpath = cpath

function test_plugin_path()
    assert(newPath:match(os.getenv("HOME") .. "/.config/tde"))
end

function test_lib_lua_path()
    assert(newPath:match("lib[-]tde/lib[-]lua/[?]/[?].lua"))
    assert(newPath:match("lib[-]tde/lib[-]lua/[?].lua"))
end

function test_lib_so_path()
    assert(newCpath:match("lib[-]tde/lib[-]so/[?]/[?].so"))
    assert(newCpath:match("lib[-]tde/lib[-]so/[?].so"))
end
