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
- [ ] `Key binding config` Allow setting the keybinding from the settings application


## Packaging

- `TDE` should support other packaging formats than only pacman's, eg debian and rpm


# Patch Notes

## Patch 0.8

### Release Notes

Patch version 0.8 introduces a lot of new stability bugfixes.
The goal for this patch-set was to fix long awaited bugfixes as well as introducing a few new UI elements

This patch introduced the new prompt, accessible through <span font_weight="bold">Mod+F2</span> keyboard shortcut.

As well as a TODO list and a countdown timer plugin for the topbar.

### New Features

- Todo list allows editing existing entries
- The settings application can now be moved using the mouse
- Tag state now gets saved as well
- Allow changing microphone volume in the settings
- Add support to configure countdown timers/clocks
- Add a prompt with support for completing: ssh, browser searching, tde docs, plugins, calculator and more

### Bug Fixes

- Todo list prompt now works after aborting it
- Reduced repaint event when arranging tiled windows, causing faster repaints
- Pinentry-gtk-2 now renders properly
- Todo widget is now readable over a white background
- Users with the default shell as fish won't break specific shell scripts
- When using the floating layout, render the titlebars
- Don't show software volume osd slider when hardware only volume is active
- Data views now show their data directly when starting
- Fix empty todo list creation
- Todo list now disappears on focus loss
- Top bar hover is now uniform
- The countdown timer now doesn't trigger when in a fullscreen application (only the sound triggers)
- Animation slider in the settings is now inverted making the UX more coherent

### Dev Notes

- We lazily load modules that are by default not loaded in. This decreases the initial load time


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
