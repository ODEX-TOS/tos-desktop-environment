# NEWS

<br />

# DRAFT TDE framework version 1.0 changes DRAFT

<center> <img src="https://tos.odex.be/docs/images/logo.png" /> </center>

## Short disclaimer

This draft is not a final version of what will be introduced in the next patch, but merely a suggestion of what can be added

## Features

- [ ] `Package manager agnostic` Allow the package updater to use other package managers than strictly `pacman`
- [ ] `Translations` Support common languages such as: `French`, `Spanish`, `Chinees`

## Packaging

- `TDE` should support other packaging formats than only pacman's, eg debian and rpm


# Patch Notes

## Patch 0.7

### New Features

- Desktop files in `~/.config/tos/autostart` get launched as well on startup
- Set the monitor resolution in the settings application
- Set the monitor refresh rate in the settings application
- `tde-client` now has support for `fzf` with code completions and history

### Bug Fixes

- Fixed theme picker life updating for the tag-list view
- Numerous bug fixes

### Dev Notes

- `stderr` messages get written to `error.log`

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
