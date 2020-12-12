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
screens=$(xrandr | grep " connected" | cut -d " " -f1) # get all screens
timeout=10 # time to wait before reverting the screen settings
DPI="$(grep Xft.dpi: ~/.Xresources | cut -d ' ' -f2)"
DPI=${DPI:-"100"}

function set-screen {
    for screen in $screens; do
        tos screen dpi "$screen" "$1" # set dpi for every screen
    done
}

if [[ "$1" == "" ]]; then
    val=$(printf "0.25 (Very Big)\n0.5 (Big)\n0.75 (Medium)\n1 (Normal)\n1.25 (Small)\n1.5 (Tiny)\n2 (Very Tiny)\n" | rofi -dmenu -dpi "$DPI" -theme /etc/xdg/tde/configuration/rofi/sidebar/rofi.rasi | sed -r 's/\s+.*$//') # get the requested dpi
    if [[ ! "$val" == "" ]]; then # only set the screen if the user selected a option
        original=$(grep "scale=" ~/.config/tos/theme | head -n1 | cut -d " " -f2)
        # set scaling to default if it doesn't exist
        if [[ "$original" == "" ]]; then
                original="1x1"
        fi
        set-screen "$val"x"$val"


        # TODO: a timer should run while waiting for the rofi output
        # If the timer expires that we should reset the screen
        bash "$0" "$original" "$$" & # call ourselfs in the background
        sleep "$timeout"
        set-screen "$original"
        pkill -f "rofi"
        pkill -f "$$"
    fi
else
    pkill -f "rofi"
    # this gets ran in the "fork"
    val=$(printf "Yes\nNo\n" | rofi -dmenu -dpi "$DPI" -p "Is the scaling correct?" -theme /etc/xdg/tde/configuration/rofi/sidebar/dpi.rasi) # get the requested dpi
    if [[ "$val" == "No" ]]; then
        set-screen "$1"
    fi
    kill -9 "$2" # kill the parent
fi

