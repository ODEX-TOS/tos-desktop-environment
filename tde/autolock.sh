#!/bin/sh

killall xidlehook

timeone=${1:-120}
timetwo=${2:-10}
timethree=${3:-10}
timefour=${4:-60}
timetwolock=${5:-mantablockscreen -sc}

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
