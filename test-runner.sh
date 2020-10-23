LUA="lua5.3"

# run the integration tests
if [[ ! -z "$TDE_IT_TEST_RUN" ]]; then
  echo "Starting integration tests"

  export LUA_PATH="$PWD/tde/?/?.lua;$PWD/tde/?.lua;$PWD/tde/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?.lua;"
  export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;"
  export LUA_PATH="$LUA_PATH;"
  if [[ ! -z "$1" ]]; then
    RUNNER="junit" FILE="$1" "$LUA" tests/runner-it.lua
  else
    "$LUA" tests/runner-it.lua
  fi
else
  # run the unit tests
  export LUA_PATH="$PWD/tests/mock/?.lua;$PWD/tests/mock/?.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/tde/?/?.lua;$PWD/tde/?.lua;$PWD/tde/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?.lua;"
  export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;"
  export LUA_PATH="$LUA_PATH;"

  export LUA_CPATH="$PWD/tde/lib-tde/lib-so/?/?.so;$PWD/tde/lib-tde/lib-so/?.so;$LUA_CPATH;;"

  if [[ ! -z "$1" ]]; then
    RUNNER="junit" FILE="$1" "$LUA" tests/runner.lua
  else
    "$LUA" tests/runner.lua
  fi
fi
