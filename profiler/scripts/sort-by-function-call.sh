#!/bin/bash

if [[ ! -f "$1" ]]; then
    echo "Supply a valid profiler file"
    exit 1
fi

awk '/[0-9]+/{printf("%s %s %s %.7f %.7f %s\n",$2, $4, $6, $8,  $10, $12)}' "$1" | \
    sort -k5,5 -n | \
    column -t -N "#,Function,Calls,Time,Time per function call,Code"