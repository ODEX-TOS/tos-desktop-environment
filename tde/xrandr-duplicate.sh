#!/bin/bash

# get all screens
screens=$(xrandr | grep ' connected' | cut -f1 -d' ')

# get the smallest resolution
small=$(xrandr | grep " connected" | cut -f1,3 -d ' ' | cut -f1 -d '+' | awk 'BEGIN{small=999999999}{split($2,a,"x"); b=(a[1] * a[2]); if(b < small){small=b; print $1, $2}}' | sort | tail -n1)
name=$(echo "$small" | cut -f1 -d ' ')
res=$(xrandr | grep -A 1 "$name connected" | tail -n1 | awk '{print $1}')

# if $1 is a screen then update small res and name
if [[ "$1" != "" ]]; then
	out=$(xrandr | grep -A 1 "$1 connected")
	res=$(echo "$out" | tail -n1 | awk '{print $1}')
	name=$(echo "$out" | head -n1 | cut -f1 -d ' ')
	# supplied name was not valid
	[[ "$name" == "" || "$res" == "" ]] && exit 1
fi

old="$IFS"
IFS=$'\n'
xrandrCalc=""
for screen in $screens; do
	if [[ "$screen" != "$name" ]]; then
		resolution=$(xrandr | grep -A 1 "$screen connected" | tail -n1 | awk '{print $1}')
		# if the screen monitor is smaller than the duplicated screen then we enable panning
		# aka resolution < res
		if [[ $(echo "$resolution"x"$res" | awk -F'x' '{if(($1*$2) < ($3*$4)){printf "smaller"}}') == "smaller" ]]; then
			PANNING="1"
			xrandrCalc="$xrandrCalc--output $screen --panning $res* --mode $resolution --same-as $name"
		else
			# otherwise we enable stretching
			echo "enabling stretching"
			xrandrCalc="$xrandrCalc--output $screen --mode $res --same-as $name"
		fi
	fi
done
IFS="$old"

if [[ "$PANNING" == "1" ]]; then
	xrandr --output $name --rate 60 --mode $res --fb $res $xrandrCalc
else
	xrandr --output $name --rate 60 --mode $res --fb $res --panning "$res*" $xrandrCalc
fi
