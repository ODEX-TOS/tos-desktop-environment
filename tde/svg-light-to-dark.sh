light="$1"
[[ ! -f "$light" ]] && exit
path=$(dirname "$light")
name=$(basename --suffix=.svg "$light")
cp "$light" "$path/$name.dark.svg"
sed -i "s/#ffffff/#000000/g" "$path/$name.dark.svg"
sed -i "s/#fff/#000000/g" "$path/$name.dark.svg"
sed -i "s/#FFF/#000000/g" "$path/$name.dark.svg"
sed -i "s/#FFFFFF/#000000/g" "$path/$name.dark.svg"