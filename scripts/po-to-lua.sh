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
if [[ ! -f "$1" ]]; then
    echo "Please specify a .po file to convert into a .lua translation file"
    exit 1 
fi

if [[ "$2" == "" ]]; then
    echo "Supply an output .po file where to save the translations to"
    exit 1 
fi


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