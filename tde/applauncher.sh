#!/bin/bash

# disable globbing for qalc
set -o noglob

DPI="$1"
CONFIG="$2"

theme="$CONFIG/configuration/rofi/appmenu/drun.rasi"
spotlight="$CONFIG/configuration/rofi/sidebar/rofi-spotlight.sh"

result="$(rofi -dpi $DPI -show drun -theme $theme)"

while [[ ! "$result" == "" ]]; do
    qalculatedResult="$(qalc $result)"
    # TODO: this is a hacky way to know if qalc tried to parse an application
    if ! echo "$qalculatedResult" | grep -q "^error: "; then
        result="$(qalc $result | rofi -dpi -dmenu -theme $theme)"
    else
        result=""
    fi
done
