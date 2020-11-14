LUA="lua5.3"

export LUA_PATH="$PWD/tde/?/?.lua;$PWD/tde/?.lua;$PWD/tde/?/init.lua;"
export LUA_PATH="$LUA_PATH;$PWD/plugins/?/init.lua;"
export LUA_PATH="$LUA_PATH;$PWD/plugins/?.lua;"
export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua;"
export LUA_PATH="$LUA_PATH;$PWD/tde/lib-tde/lib-lua/?/?.lua;$PWD/tde/lib-tde/lib-lua/?.lua;$PWD/tests/mock/?.lua;$PWD/tests/mock/?/?.lua"
export LUA_PATH="$LUA_PATH;"
export LUA_CPATH="$PWD/tde/lib-tde/lib-so/?/?.so;$PWD/tde/lib-tde/lib-so/?.so;$LUA_CPATH;;"

TOTAL_TIME="10"
FILE=""
FUNCTIONS_AMOUNT="100000"
OUTPUT=""
REALTIME=""

function help() {
  name=$(basename "$0" .sh)
  echo -e "$name : OPTIONS [htfFor]"
  echo ""
  echo -e "$name -h | --help \t\t\tShow this help message"
  echo -e "$name -t | --tde <time> \t\tMaximum time to run tde for"
  echo -e "$name -f | --file <filename>\t\tRun a custom lua file (as the benchmark)"
  echo -e "$name -F | --functions <x> \t\tReturn the top x functions"
  echo -e "$name -o | --output <filename> \tStore the data in filename"
  echo -e "$name -r | --realtime \t\tReturn the time a function took in real time instead of utilized cpu time"
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
      ;;
    "-F" | "--functions")
      FUNCTIONS_AMOUNT="$2"
      shift
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
    "")
      break
      ;;
  esac
done

TOTAL_TIME="$TOTAL_TIME" OUTPUT="$OUTPUT" REALTIME="$REALTIME" FUNCTIONS_AMOUNT="$FUNCTIONS_AMOUNT" FILE="$FILE" "$LUA" profiler/init.lua
