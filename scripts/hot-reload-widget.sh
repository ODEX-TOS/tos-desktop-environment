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

# This file is intended to easily develop TDE widgets
# you can hot-reload widgets by using this file
# simply call this script with the lua file as a parameter

# The most basic lua script to develop should look like this:
#local wibox = require("wibox")
#return wibox.widget.textbox("Hello")

LUA_FILE=""
# hw often to reload in seconds
UPDATE_SPEED="5"
# reload as fast as possible
FAST="0"

function print_help(){
  name=$(basename "$0" .sh)
  echo -e "$name : OPTIONS [s] <lua file>"
  echo ""
  echo -e "$name -s | --side \t\t\tDraw the hot-reload widget to the side of the screen"
  echo -e "$name -h | --help \t\t\tShow this help message"
  exit 0
}

while true; do
  case "$1" in
    "-s"|"--side")
        FAST="1"
        shift
    ;;
    "-h"|"--help")
        print_help
        exit 0
    ;;
    "")
     [[ "$LUA_FILE" == "" ]] && print_help
     break
    ;;
    **)
        LUA_FILE="$1"
        shift
    ;;
  esac
done

function notify_user(){
    echo "$1"
    notify-send "TDE widget hot-reload" "$1"
}

function notify_user_error(){
    echo "$1"
    notify-send "TDE widget hot-reload" "$1" -u "critical"
}

function check_state(){
    # check if the widget exists
    if [[ ! -f "$LUA_FILE" ]]; then
        notify_user "Please supply a file to hot-reload (must be valid lua)"
        exit 1
    fi
    if [[ ! "$(command -v inotifywait)" ]]; then
        if [[ ! "$(command -v pacman)" ]]; then
         notify_user "Can't provide hot reload support, please install inotify-tools"
         exit 1  
        fi
        notify_user "Queing inotify-tools using <span  weight='bold'>pacman -S inotify-tools</span>\n this is to support hot-reloading"
        pacman -S inotify-tools --noconfirm
    fi
    # start dev-widget-hot-reload tde daemon if it doesn't exist yet
    if [[ "$FAST" == "1" ]]; then
        tde-client "if not _G.dev_widget_side_view_started then _G.dev_widget_side_view_init() end"
    else
        tde-client "if not _G.dev_widget_started then _G.dev_widget_init() end"
    fi

}

function hot_reload(){
    file="$(mktemp /tmp/tde_widget_hot_reload_XXXXXXXXX.lua)"
    cp "$LUA_FILE" "$file"
    # shellcheck disable=SC2001
    name="$(echo "$file" | sed 's/.lua$//g')"

    if [[ "$FAST" == "1" ]]; then
        result="$(tde-client "_G.dev_widget_side_view_refresh(\"$name\")")"
    else
        result="$(tde-client "_G.dev_widget_refresh(\"$name\")")"
    fi

    if [[ -n "$result" ]]; then
        notify_user_error "$(echo "$result" | sed -e 's/^ *[a-z]* "//' -e 's/"$//' -e "s;$file;$LUA_FILE;")"
    fi
    notify_user "💡 Hot Reloaded $LUA_FILE"
    rm "$file"
}

function listen(){
    notify_user "Starting listening to filesystem events for $LUA_FILE"

    current_time="$(( $(date +%s) - UPDATE_SPEED ))"

    hot_reload

    inotifywait -m -e modify "$LUA_FILE" | 
    while read -r file; do
        # only reload every $UPDATE_SPEED seconds
        # otherwise we get overloaded with updates
        # which is taxing on the system
        if [[ "$(date +%s)" -gt "$(( current_time + UPDATE_SPEED ))" || "$FAST" == "1" ]]; then
            hot_reload
            current_time="$(date +%s)"
        fi
    done
}

check_state
listen