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

export LUA_PATH="$PWD/tests/tde/mock/?.lua;$PWD/tests/tde/mock/?.lua;"
export LUA_PATH="$PWD/tde/?/?.lua;$PWD/tde/?.lua;$PWD/tde/?/init.lua;"
export LUA_PATH="$LUA_PATH;$PWD/plugins/?/init.lua;"
export LUA_PATH="$LUA_PATH;$PWD/plugins/?.lua;"
export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;"
export LUA_PATH="$LUA_PATH;$PWD/tde/lib-tde/lib-lua/?/?.lua;$PWD/tde/lib-tde/lib-lua/?.lua;"
export LUA_PATH="$LUA_PATH;$PWD/tde/lib-tde/translations/?.lua;"
export LUA_PATH="$LUA_PATH;"


export LUA_CPATH="$PWD/tde/lib-tde/lib-so/?/?.so;$PWD/tde/lib-tde/lib-so/?.so;$LUA_CPATH;;"

TOTAL_TIME="10"
FILE=""
FUNCTIONS_AMOUNT="100000"
OUTPUT=""
REALTIME=""
NO_FD=""

function help() {
  name=$(basename "$0" .sh)
  echo -e "$name : OPTIONS [chtfFor]"
  echo ""
  echo -e "$name -c | --clean \t\t\tRun the profiler without profiling the function (only time the execution) this shows actual execution time without any overhead"
  echo -e "$name -h | --help \t\t\tShow this help message"
  echo -e "$name -t | --tde <time> \t\tMaximum time to run tde for"
  echo -e "$name -f | --file <filename>\t\tRun a custom lua file (as the benchmark)"
  echo -e "$name -F | --functions <x> \t\tReturn the top x functions"
  echo -e "$name -fd | --filedescriptor \tSuppress all filedescriptor output from execution"
  echo -e "$name -o | --output <filename> \tStore the data in filename"
  echo -e "$name -r | --realtime \t\tReturn the time a function took in real time instead of utilized cpu time"
  echo -e "$name -m | --memory \t\tFind the memory leaks in the application"

}

while true; do
  case "$1" in
    "-h" | "--help")
      help
      exit 0
      ;;
    "-t" | "--tde")
      TOTAL_TIME="$2"
      shift
      shift
      ;;
    "-f" | "--file")
      FILE="$2"
      if [[ ! -f "$FILE" ]]; then
        echo "$FILE is not a file"
        exit 1
      fi
      shift
      shift
      export LUA_PATH="$LUA_PATH;$PWD/tests/tde/mock/?.lua;$PWD/tests/tde/mock/?/?.lua;"
      ;;
    "-F" | "--functions")
      FUNCTIONS_AMOUNT="$2"
      shift
      shift
      ;;
    "-fd" | "--filedescriptor")
      NO_FD="1"
      shift
    ;;
    "-o" | "--output")
      OUTPUT="$2"
      shift
      shift
      ;;
    "-r" | "--realtime")
      REALTIME="1"
      shift
      ;;
    "-c"|"--clean")
      CLEAN="1"
      shift
    ;;
    "-m"|"--memory")
      tde-client profiler/snapshot.tde
      mv ~/LuaMemRefInfo-All-[snap].txt ~/LuaMemRefInfo-before.txt 

      echo "First memory profile is done, waiting 60 seconds to start second profile"

      sleep 60

      echo "Starting second memory profile"
      tde-client profiler/snapshot.tde
      mv ~/LuaMemRefInfo-All-[snap].txt ~/LuaMemRefInfo-after.txt 

      echo "Second memory profile is done, comparing"

      tde-client profiler/compare_memory.tde
      rm ~/LuaMemRefInfo-after.txt ~/LuaMemRefInfo-before.txt 
      exit 0
    ;;
    "")
      break
      ;;
  esac
done

if [[ "$CLEAN" == "1" && -f "$FILE" ]]; then
  time "$LUA" "$FILE"
  exit "$?"
fi

TOTAL_TIME="$TOTAL_TIME" NO_FD="$NO_FD" OUTPUT="$OUTPUT" REALTIME="$REALTIME" FUNCTIONS_AMOUNT="$FUNCTIONS_AMOUNT" FILE="$FILE" "$LUA" profiler/init.lua
