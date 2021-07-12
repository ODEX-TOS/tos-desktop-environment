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

# First check if svgo is installed

if [[ "$(command -v svgo)" == "" ]]; then
    echo "Installing svgo"
    yay -S svgo
fi

function human_print() {
    while read -r KB _; do
    KB="$(awk -v "KB=$KB" 'BEGIN{print int(KB)}')"
    [[ "$KB" -lt 1024 ]] && echo "${KB} KiB" && break
    MB="$(((KB+512)/1024))"
    
    [[ "$MB" -lt 1024 ]] && echo "${MB} MiB" && break
    GB="$(((MB+512)/1024))"
    
    [[ "$GB" -lt 1024 ]] && echo "${GB} GiB" && break
    echo "$(((GB+512)/1024)) TiB"
    
    done
}

# svgo should be installed, lets detect all svg files
# shellcheck disable=SC2044
for file in $(find tde -type f -iname "*.svg" -not -path "./build/*" ); do
    out=$(svgo "$file" -o "$file" | tail -n1)

    original_size="$(echo "$out" | awk '{print $1}')"
    new_size="$(echo "$out" | awk '{print $(NF-1)}')"

    diff_size="$(awk -v "begin=$original_size" -v "end=$new_size" 'BEGIN{print begin - end}')"
    
    saved="$(awk -v "saved=$saved" -v "diff=$diff_size" 'BEGIN{print saved + diff}')"
    total_original_size="$(awk -v "saved=$total_original_size" -v "diff=$original_size" 'BEGIN{print saved + diff}')"
    total_new_size="$(awk -v "saved=$total_new_size" -v "diff=$new_size" 'BEGIN{print saved + diff}')"

    echo "$file: $out"
done

computed_save="$(echo "$saved" | human_print )"
computed_total="$(echo "$total_original_size" | human_print )"
computed_new="$(echo "$total_new_size" | human_print )"

echo "Saved: $computed_save"
echo "Previous size: $computed_total"
echo "Current size on disk: $computed_new"
