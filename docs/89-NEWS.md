# NEWS

<a name="v10"></a>

# DRAFT TDE framework version 1.0 changes DRAFT

<center> <img src="../images/logo.png" /> </center>

## Short disclaimer

This draft is not a final version of what will be introduced in the next patch, but merely a sugestion of what can be added

## Features

* [] `Package manager agnostic` Allow the package updater to use other package managers that strictly `pacman`
* [] `Translations` Support common languages such as: `French`, `Spanish`, `Chinees`

## Packaging

* `TDE` should support other packaging formats that only pacman's, eg debian and rpm


# Patch Notes

## Patch 0.7

### New Features
* Desktop files in `~/.config/tos/autostart` get launched as well on startup

### Bug Fixes
* Numerous bug fixes

### Dev Notes
* `stderr` messages get written to `error.log`

## Patch 0.6

### New Features
* Multi Monitor detection
* Translations
* Error logging
* Settings application
* Bluetooth connectivity settings
* Network connectivity settings
* Wallpaper picker
* User pictures
* Overhaul of the notification widgets

### Bug Fixes
* Fixed numerous bugs

### Dev Notes
* Unit Testing
* Integration Testing
* Widget hot reloader
* lib-widget
* Improved lib-tde
