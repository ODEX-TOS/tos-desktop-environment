#!/bin/bash

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
echo '"Language: '$lang'\n"' >> "$2"
echo '"X-Generator: TDETranslator 1.0.0\n"' >> "$2"

while IFS= read -r line; do
    SEP="|;;|"
    original=$(echo "$line" | sed "s/ ${SEP}.*$//g")
    translated=$(echo "$line" | sed "s/^.*${SEP} //g")
    echo >> "$2"
    echo "#: translation from lua $1" >> "$2"
    echo 'msgid "'"$original"'"' >> "$2"
    echo 'msgstr "'"$translated"'"' >> "$2"
done <<< "$(grep -Po 'translations\[(.*)\].*=.*"(.*)"' tde/lib-tde/translations/nl.lua | awk -F'"' '/"(.*)"/{print $2,"|;;|" ,$4}')"
