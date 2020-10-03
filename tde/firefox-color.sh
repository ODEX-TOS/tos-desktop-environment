#!/bin/bash

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

# usage pass the colors to this file

echo "UPDATING FIREFOX COLORS TO $1 and as bg $2"

for file in "$HOME"/.mozilla/firefox/*/chrome/colors/blurred.css; do
        echo "Updating FIREFOX colors in $file"
        # change all colors in /*START*/ colorcode /*END*/
        sed -i 's:STARTFG.*ENDFG:STARTFG*/ '"$1"' /*ENDFG:' "$file"
        # change all colors in /*STARTBG*/ colorcode /*ENDBG*/
        sed -i 's:STARTBG.*ENDBG:STARTBG*/ '"$2"' /*ENDBG:' "$file"
done

for file in "$HOME"/.mozilla/firefox/*/chrome/userChrome.css; do
        echo "Updating FIREFOX colors in $file"
        # change all colors in /*START*/ colorcode /*END*/
        sed -i 's:STARTFG.*ENDFG:STARTFG*/ '"$1"' /*ENDFG:' "$file"
        # change all colors in /*STARTBG*/ colorcode /*ENDBG*/
        sed -i 's:STARTBG.*ENDBG:STARTBG*/ '"$2"' /*ENDBG:' "$file"
done
