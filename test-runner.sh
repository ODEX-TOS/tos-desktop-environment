export LUA_PATH="$(pwd)/tests/mock/?.lua;$(pwd)/tests/mock/?.lua;"
export LUA_PATH="$LUA_PATH;$(pwd)/tde/?/?.lua;$(pwd)/tde/?.lua;"
export LUA_PATH="$LUA_PATH;$(pwd)/plugins/?/init.lua;"
export LUA_PATH="$LUA_PATH;$(pwd)/plugins/?.lua;"
export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;/etc/xdg/awesome/?.lua;/etc/xdg/awesome/?/init.lua;"
export LUA_PATH="$LUA_PATH;"

LUA="lua5.3"

if [[ ! -z "$1" ]]; then
    RUNNER="junit" FILE="$1" "$LUA" tests/runner.lua 
else
    "$LUA" tests/runner.lua
fi
