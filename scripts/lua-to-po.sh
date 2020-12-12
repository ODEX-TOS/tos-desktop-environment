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

# shellcheck disable=SC2129,SC2028

if [[ ! -f "$1" ]]; then
    echo "Please specify a .lua file to convert into a .po file"
    exit 1 
fi

if [[ "$2" == "" ]]; then
    echo "Supply an output .po file where to save the translations to"
    exit 1 
fi

lang=$(basename "$1" ".lua")

echo 'msgid ""' > "$2"
echo 'msgstr ""' >> "$2"
echo '"Project-Id-Version: \n"' >> "$2"
echo '"POT-Creation-Date: \n"' >> "$2"
echo '"PO-Revision-Date: \n"' >> "$2"
echo '"Last-Translator: \n"' >> "$2"
echo '"Language-Team: \n"' >> "$2"
echo '"MIME-Version: 1.0\n"' >> "$2"
echo '"Content-Type: text/plain; charset=UTF-8\n"' >> "$2"
echo '"Content-Transfer-Encoding: 8bit\n"' >> "$2"
echo '"Language: '"$lang"'\n"' >> "$2"
echo '"X-Generator: TDETranslator 1.0.0\n"' >> "$2"

while IFS= read -r line; do
    SEP="|;;|"
    # shellcheck disable=SC2001
    original=$(echo "$line" | sed "s/ ${SEP}.*$//g")
    # shellcheck disable=SC2001
    translated=$(echo "$line" | sed "s/^.*${SEP} //g")
    echo >> "$2"
    echo "#: translation from lua $1" >> "$2"
    echo 'msgid "'"$original"'"' >> "$2"
    echo 'msgstr "'"$translated"'"' >> "$2"
done <<< "$(grep -Po 'translations\[(.*)\].*=.*"(.*)"' tde/lib-tde/translations/nl.lua | awk -F'"' '/"(.*)"/{print $2,"|;;|" ,$4}')"
