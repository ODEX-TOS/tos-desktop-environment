# Translations

This directory contains translation files
These are used to specify the translation to use for `TDE`

The translation file to be used depends on the `$LANG` env variable

Thus English maps to -> 'en'
Dutch to 'nl'
French to 'fr'
etc

The format of the language files is as followed:

```lua
local translations = {}
translation["original"] = "translated"
translation["original2"] = "translated2"
return translations
```

Please follow this format as our `.po` scripts depend on them

In the directory `scripts/` you can find helper scripts to convert between our translation file to `.po` files

We can convert between `lua` <==> `.po`

PO is used as a translation file in many applications and a lot of tooling exists around the platform.
If you are unfamiliar with the extension please use software such as `poedit`
You can install it on `TOS` by using the command `tos -Syu poedit`

## Converting between formats

Let's take a quick look at how to convert between both formats
In case you don't have a .po file lets generate one from lua

```bash
# generate a file called nl.po containing our translations
bash ./scripts/lua-to-po.sh "tde/lib-tde/translations/nl.lua" "nl.po"
```

Now you can open the translation file in `poedit` don't forget to change the language and of course change the translations 😉

Once you are done you can convert the translations back by using the other provided script

```bash
# Convert the po file back to lua
bash ./scripts/po-to-lua.sh "nl.po" "tde/lib-tde/translations/nl.lua"
```
