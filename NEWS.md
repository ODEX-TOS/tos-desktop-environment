# NEWS

<br />

# DRAFT TDE framework version 1.0 changes DRAFT

<center> <img src="https://tos.odex.be/docs/images/logo.png" /> </center>

## Short disclaimer

This draft is not a final version of what will be introduced in the next patch, but merely a suggestion of what can be added

## Features

- [ ] `Package manager agnostic` Allow the package updater to use other package managers than strictly `pacman`
- [ ] `Translations` Support common languages such as: `French`, `Spanish`, `Chinees`
- [ ] `accessibility Visual` Accessability settings for color impaired people (High contrast)
- [X] `Auto-Hide-Panels` Allow automatically hiding of the top-bar and bottom-bar when not using them (Usefull for oled screen not having burn in)
- [ ] `Default Applications` Allow setting the default application from the settings


## Packaging

- `TDE` should support other packaging formats than only pacman's, eg debian and rpm


# Patch Notes

## Patch 0.8

### New Features

- Todo list allows editing existing entries

### Bug Fixes

- Todo list prompt now works after aborting it

### Dev Notes


## Patch 0.7

### New Features

- Desktop files in `~/.config/tos/autostart` get launched as well on startup
- Set the monitor resolution in the settings application
- Set the monitor refresh rate in the settings application
- `tde-client` now has support for `fzf` with code completions and history
- Support for configuring tags in the settings application
- Config options for tag `master width` and `master count`
- Added support for changing the port settings of your sources and sinks
- Persist bluetooth status on reboot
- Allow changing dpi from the settings (Scaling)
- You can now Auto-Hide Panels on hover (Auto Hide option in general settings)
- OLED mode automatically enables 'fading' to reduce screen burn

### Bug Fixes

- Audio profiles now get detected more robustly
- Fixed theme picker life updating for the tag-list view
- Taking screenshots now uses the theme color that is active (When changing the theme color life the screenshot tool uses that color scheme)
- Fixed rendering issue of `lib-widget` card titles with newlines
- Only show system usage with a precision of 2 characters after the decimal point instead of 8 (Too noisy)
- Now we show a meaningful `tde version` in the about page
- Numerous bug fixes

### Dev Notes

- `stderr` messages get written to `error.log`
- `card` has support for highlighting

## Patch 0.6

### New Features

- Multi Monitor detection
- Translations
- Error logging
- Settings application
- Bluetooth connectivity settings
- Network connectivity settings
- Wallpaper picker
- User pictures
- Overhaul of the notification widgets

### Bug Fixes

- Fixed numerous bugs

### Dev Notes

- Unit Testing
- Integration Testing
- Widget hot reloader
- lib-widget
- Improved lib-tde
