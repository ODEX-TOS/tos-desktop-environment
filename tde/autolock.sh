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

# shellcheck disable=SC2016

killall xidlehook

timeone=${1:-120}
timetwo=${2:-10}
timethree=${3:-10}
timefour=${4:-60}
timetwolock=${5:-light-locker-command -l}
#timetwolock=${5:-dm-tool lock}

xidlehook \
        --not-when-fullscreen \
        --not-when-audio \
        --timer "$timeone" \
        'brightness -g > /tmp/brightness; brightness -s 5' \
        'brightness -s $(cat /tmp/brightness)' \
        --timer "$timetwo" \
        "$timetwolock" \
        'brightness -s $(cat /tmp/brightness)' \
        --timer "$timethree" \
        "xset dpms force off" \
        'brightness -s $(cat /tmp/brightness)' \
        --timer "$timefour" \
        "systemctl suspend" \
        'brightness -s $(cat /tmp/brightness)'


