#!/bin/bash

if [[ ! -f "$1" ]]; then
    echo "Please specify a .po file to convert into a .lua translation file"
    exit 1 
fi

if [[ "$2" == "" ]]; then
    echo "Supply an output .po file where to save the translations to"
    exit 1 
fi

lang=$(basename "$1" ".lua")


original=""

while IFS= read -r line; do
    if [[ "$original" == "" ]]; then
        original="$line"
    else
        if [[ ! "$original" == '""' ]]; then
            echo "translations[$original] = $line" >> "$2.tmp"
        fi
        original=""
    fi
done <<< $(grep -Po 'msgid ".*"|msgstr ".*"' nl.po | sed -E 's/^msgstr |^msgid //g')

echo "local translations = {}" > "$2"

cat "$2.tmp" | sort >> "$2"

echo "return translations" >> "$2"

rm "$2.tmp"