#!/bin/bash

if [[ -d 'build' ]]; then
    rm -rf build
fi

make clean ldoc || { echo "Building documentation failed, aborting" ; exit 1 ; }

if [[ -f "build/doc/index.html" ]]; then
    open "build/doc/index.html"
    echo "View browser to see documentation"
    exit 0
fi

echo "Couldn't find index.html in the build/doc directory"
exit 1