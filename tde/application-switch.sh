#!/bin/bash

CONFIG="/etc/xdg/tde/configuration/rofi/appmenu/drun.rasi"
DPI=${1:-"100"}

ROFI="rofi -dpi $DPI -theme $CONFIG -show window 2>/dev/null"

result=$($ROFI)
name=$(echo "$result" | cut -f1)
id=$(echo "$result" | cut -f2)
# awesomewm starts at index 1 instead of 0
workspace=$(($(echo "$result" | cut -f3) +1))

# if the user aborts then we don't change the focus
if [[ "$name" == "" || "$id" == "" || "$workspace" == "" ]]; then
    exit
fi
echo "$name $id $workspace"

# switch to the correct workspace
awesome-client <<EOF
_G.mouse.screen.tags[$workspace]:view_only()
EOF

# select the correct window
wmctrl -ia "$id"

