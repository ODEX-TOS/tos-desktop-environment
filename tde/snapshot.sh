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
# ----------------------------------------------------------------------------
# --- Simple screenshot script using maim
# --
# -- Accepts `area` and `full` string args
# --
# -- For more details check `man maim`
# --
# -- @author manilarome &lt;gerome.matilla07@gmail.com&gt;
# -- @author Tom Meyers &lt;tom@odex.begt;
# -- @copyright 2020 manilarome
# -- @copyright 2020 Tom Meyers
# -- @script snapshot
# ----------------------------------------------------------------------------


screenshot_dir="$HOME/Pictures/Screenshots/"
COLOR="${2:-none}"
PADDING="3%"

echo "Selected color: $COLOR"

# Check save directory
# Creates it if it doesn't exist
check_dir() {
	if [ ! -d "$screenshot_dir" ];
	then
		mkdir -p "$screenshot_dir"
	fi
}

window() {
	check_dir

	file_loc="${screenshot_dir}$(date +%Y%m%d_%H%M%S).png"
	file_loc_tmp="${screenshot_dir}$(date +%Y%m%d_%H%M%S)tmp.png"

	
	maim_command="$1"
	notif_message="$2"

	# Execute maim command if a third option is provided maim will be piped into it
	${maim_command} | $3 "${file_loc}"
	cp "${file_loc}" "${file_loc_tmp}"
	convert "${file_loc_tmp}" -gravity west -background "$COLOR" -splice "$PADDING"x0 "${file_loc_tmp}"
	convert "${file_loc_tmp}" -gravity east -background "$COLOR" -splice "$PADDING"x0 "${file_loc_tmp}"
	convert "${file_loc_tmp}" -gravity north -background "$COLOR" -splice 0x"$PADDING" "${file_loc_tmp}"
	convert "${file_loc_tmp}" -gravity south -background "$COLOR" -splice 0x"$PADDING" "${file_loc_tmp}"

	mv "$file_loc_tmp" "$file_loc"
    
    # compress the image
    mogrify -quality 20 "${file_loc}"

	# Exit if the user cancels the screenshot
	# So it means there's no new screenshot image file
	if [ ! -f "${file_loc}" ]; then
		exit
	fi

	# Copy to clipboard
	# shellcheck disable=SC2012
	xclip -selection clipboard -t image/png -i "${screenshot_dir}"/"$(ls -1 -t "${screenshot_dir}" | head -1)" &

	notify-send 'Snap!' "${notif_message}" -a 'Screenshot tool' -i "${file_loc}"
}

# Main function
shot() {

	check_dir

	file_loc_tmp="${screenshot_dir}$(date +%Y%m%d_%H%M%S)tmp.png"
	file_loc="${screenshot_dir}$(date +%Y%m%d_%H%M%S).png"

	
	maim_command="$1"
	notif_message="$2"

	# Execute maim command if a third option is provided maim will be piped into it
	if [[ -n "$3" ]]; then
		${maim_command} | $3 "${file_loc}"
	else
		${maim_command} "${file_loc_tmp}"
		convert "${file_loc_tmp}" "${file_loc}"
        # compress the image
        mogrify -quality 20 "${file_loc}"
		rm "${file_loc_tmp}"
	fi

	# Exit if the user cancels the screenshot
	# So it means there's no new screenshot image file
	if [ ! -f "${file_loc}" ]; then
		exit
	fi

	# Copy to clipboard
	# shellcheck disable=SC2012
	xclip -selection clipboard -t image/png -i "${screenshot_dir}"/"$(ls -1 -t "${screenshot_dir}" | head -1)" &

	notify-send 'Snap!' "${notif_message}" -a 'Screenshot tool' -i "${file_loc}"
}


# Check the args passed
if [ -z "$1" ] || { [ "$1" != 'full' ] && [ "$1" != 'full_blank' ] && [ "$1" != 'area' ] && [ "$1" != 'area_blank' ] && [ "$1" != 'window' ] && [ "$1" != 'window_blank' ] ; };
then
	echo "
	Requires an argument:
	area 	- Area screenshot
	full 	- Fullscreen screenshot
	window  - Take a screenshot of a window (optionaly provide a color for the background)
	window_blank - Don't add any fancy shadow and background to the window screenshot

	Example:
	./snapshot area
	./snapshot full
	./snapshot window
	./snapshot window #FFFFFF
	./snapshot window_blank

	"
elif [ "$1" = 'full' ];
then
	msg="Full screenshot saved and copied to clipboard!"
	window 'maim -u -m 1' "${msg}" "convert - ( +clone -background black -shadow 80x3+8+8 ) +swap -background $COLOR -layers merge +repage"
elif [ "$1" = 'full_blank' ];
then
	msg="Full screenshot saved and copied to clipboard!"
	shot 'maim -u -m 1' "${msg}"
elif [ "$1" = 'area' ];
then
	msg='Area screenshot saved and copied to clipboard!'
	window 'maim -u -s -n -m 1' "${msg}" "convert - ( +clone -background black -shadow 80x3+8+8 ) +swap -background $COLOR -layers merge +repage"
elif [ "$1" = 'area_blank' ];
then
	msg='Area screenshot saved and copied to clipboard!'
	shot 'maim -u -s -n -m 1' "${msg}"

elif [ "$1" = 'window' ];
then
	msg='Window screenshot saved and copied to clipboard!'
	# TODO: add a margin around the window so that the background is better visible
	window 'maim -st 9999999 -B -m 1 -u' "${msg}" "convert - ( +clone -background black -shadow 80x3+8+8 ) +swap -background $COLOR -layers merge +repage"
elif [ "$1" = "window_blank" ];
then
	msg='Window screenshot saved and copied to clipboard!'
	shot 'maim -st 9999999 -B -m 1 -u' "${msg}"
fi

