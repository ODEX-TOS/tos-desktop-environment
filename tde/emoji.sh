EMOJI="/etc/xdg/awesome/emoji"
THEME="/etc/xdg/awesome/configuration/rofi/appmenu/drun.rasi"
DPI="${1:-100}"

result=$(cat "$EMOJI" | cut -d';' -f1 | rofi -dmenu -p "Copy an emoji " -dpi "$DPI" -theme "$THEME")

if [[ ! -z "$result" ]]; then
    result=$(grep "$result" "$EMOJI")
    chosen=$(echo "$result" | sed "s/ .*//")
    echo "$chosen" | tr -d '\n' | xclip -selection clipboard
    notify-send "Emoji" "'$chosen' copied to clipboard." -a "Emoji Keybind"
fi
