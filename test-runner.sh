#!/usr/bin/env bash

# MIT License
# 
# Copyright (c) 2019 manilarome
# Copyright (c) 2020 Tom Meyers
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
LUA="lua5.3"

LINES=$(tput lines)
COLUMNS=$(tput cols)

# run the integration tests
if [[ -n "$TDE_IT_TEST_RUN" ]]; then
  echo "Starting integration tests"

  export LUA_PATH="$PWD/tde/?/?.lua;$PWD/tde/?.lua;$PWD/tde/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?.lua;"
  export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;"
  export LUA_PATH="$LUA_PATH;"
  if [[ -n "$1" ]]; then
    RUNNER="junit" FILE="$1" LINES="$LINES" COLUMNS="$COLUMNS" "$LUA" tests/tde/runner-it.lua
  else
    LINES="$LINES" COLUMNS="$COLUMNS" "$LUA" tests/tde/runner-it.lua
  fi
else
  # run the unit tests
  export LUA_PATH="$PWD/tests/tde/mock/?.lua;$PWD/tests/tde/mock/?.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/tde/?/?.lua;$PWD/tde/?.lua;$PWD/tde/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/plugins/?.lua;"
  export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;"
  export LUA_PATH="$LUA_PATH;$PWD/tde/lib-tde/translations/?.lua;"
  export LUA_PATH="$LUA_PATH;"

  export LUA_CPATH="$PWD/tde/lib-tde/lib-so/?/?.so;$PWD/tde/lib-tde/lib-so/?.so;$LUA_CPATH;;"

  if [[ -n "$1" && -f "$1" ]]; then
    RUNNER="junit" FILE="$1" LINES="$LINES" COLUMNS="$COLUMNS" "$LUA" tests/tde/runner.lua
  else
    # shellcheck disable=SC2068
    LINES="$LINES" COLUMNS="$COLUMNS" "$LUA" tests/tde/runner.lua $@
  fi
fi
