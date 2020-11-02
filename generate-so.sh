if [[ "$1" == "" ]]; then
    echo "Supply lua version eg luajit(5.1) or lua5.3(5.3)"
    read -p "Version: (5.3) " version
fi
if [[ -z "$version" ]]; then
    version="5.1"
fi

[[ -d lua-install ]] && rm -rf lua-install

luarocks --lua-version "$version" install --tree lua-install lua-cjson 2.1.0-1
luarocks --lua-version "$version" install --tree lua-install luasocket
luarocks --lua-version "$version" install --tree lua-install luaposix

# update lib-lua
cp -r lua-install/share/lua/"$version"/* tde/lib-tde/lib-lua/

# update lib-so
cp -r lua-install/lib/lua/"$version"/* tde/lib-tde/lib-so/

# cleanup
[[ -d lua-install ]] && rm -rf lua-install
