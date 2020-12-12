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

# network ssid's
networks="$(nmcli d wifi list | awk '$1 !~ /IN-USE|*/{print $0}' | grep -Eo '^.* Infra' | sed 's/Infra//' | sed -r 's/([0-9A-F]{2}:){5}[0-9A-F]{2}\s+//' | awk '{print "\""$0"\""}' | sed -r -e 's/^\"\s+/\"/g' -e 's/\s*\"//g' | sort | uniq)" # get all screens
DPI=${1:-"100"}

val="$(printf "%s" "$networks" | rofi -dmenu -dpi "$DPI" -theme /etc/xdg/tde/configuration/rofi/sidebar/rofi.rasi)" # get the requested network

if [[ "$val" == "" ]]; then
        exit 1 # user aborted
fi

nmcli dev wifi connect "$val" || echo "Asking for password of $val"
# shellcheck disable=SC2063
nmcli dev wifi list | grep '*' | head -n1 | grep -q " $val " && exit # exit if a connection has been made
# otherwise we ask the password from the user
password=$(printf "What is the password of %s?" "$val" | rofi -dmenu -dpi "$DPI" -password -theme /etc/xdg/tde/configuration/rofi/sidebar/rofi.rasi) # get the requested dpi

if [[ "$password" == "" ]]; then
        exit 1 # user aborted password entry field
fi

nmcli dev wifi connect "$val" password "$password"

