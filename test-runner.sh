export LUA_PATH="$PWD/tests/mock/?.lua;$PWD/tests/mock/?.lua;"
export LUA_PATH="$LUA_PATH;$PWD/tde/?/?.lua;$PWD/tde/?.lua;"
export LUA_PATH="$LUA_PATH;$PWD/plugins/?/init.lua;"
export LUA_PATH="$LUA_PATH;$PWD/plugins/?.lua;"
export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;/etc/xdg/awesome/?.lua;/etc/xdg/awesome/?/init.lua;"
export LUA_PATH="$LUA_PATH;"

LUA="lua5.3"

if [[ ! -z "$1" ]]; then
    RUNNER="junit" FILE="$1" "$LUA" tests/runner.lua 
else
    "$LUA" tests/runner.lua
fi
