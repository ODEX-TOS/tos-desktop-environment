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
weather=$(curl -sf https://wttr.in/\?format="%l:%t:%C")
weather_icon="test"

# Magic numbers used to denote the weather
SUNNY="110"
NIGHT_CLEAR="220"
CLOUDY_DAY="330"
CLOUDY_NIGHT="440"
CLOUDY="550"
RAIN="660"
STORM="770"
SNOW="880"
MIST="990"

START_NIGHT="21:00"
START_DAY="08:00"

# function used to extract the type of icon to display
# for more information about how and why this function behaves the way it does look at
# /etc/xdg/tde/widgets/weather/icons and weather-update.lua
# see codes at https://github.com/chubin/wttr.in/blob/74d005c0ccb8235319343a8a5237f99f10287695/lib/constants.py for more information
function updateIcon {
    # grab the subtitle and convert it to lower case
    subtitle=$(echo "$weather" | cut -d: -f3 | tr '[:upper:]' '[:lower:]')
    if [[ "$1" == "-D" ]]; then
            echo "[DEBUG] match text: $subtitle"
    fi
    currentTime=$(date +%H:%M)
    if [[ "$subtitle" == "sunny" || "$subtitle" == "clear" ]]; then
        if [[ "$currentTime" > "$START_NIGHT" || "$currentTime" < "$START_DAY" ]]; then
            # moon
            weather_icon="$NIGHT_CLEAR"
        else
            # sun
            weather_icon="$SUNNY"
        fi
    elif [[ "$subtitle" == "partly cloudy" ]]; then
        if [[ "$currentTime" > "$START_NIGHT" || "$currentTime" < "$START_DAY" ]]; then
            # cloudy during night
            weather_icon="$CLOUDY_NIGHT"
        else
            # cloudy during the day
            weather_icon="$CLOUDY_DAY"
        fi
    elif [[ "$subtitle" == "cloudy" || "$subtitle" == "overcast" ]]; then
        weather_icon="$CLOUDY"
    elif [[ "$subtitle" == *"rain"* || "$subtitle" == *"drizzle" ]]; then
        weather_icon="$RAIN"
    elif [[ "$subtitle" == "thundery outbreaks possible" ]]; then
        weather_icon="$STORM"
    elif [[ "$subtitle" == "patchy snow possible" || "$subtitle" == *"sleet"* || "$subtitle" == "blowing snow" || "$subtitle" == "blizzard" || "$subtitle" == *"ice"* ]]; then
        weather_icon="$SNOW"
    elif [[ "$subtitle" == "mist" || "$subtitle" == "fog" || "$subtitle" == "freezing fog" || "$subtitle" == *"snow"* ]]; then
        weather_icon="$MIST"
    fi
}

if [ -n "$weather" ]; then
    weather_temp=$(echo "$weather" | cut -d: -f2 | sed 's/[+-]//g')
    # todo return icon
    # shellcheck disable=SC2068
    updateIcon $@
    weather_description=$(echo "$weather" | cut -d: -f1)

    echo "$weather_icon" "$weather_description"@@"$weather_temp"
else
    echo "..."
fi

