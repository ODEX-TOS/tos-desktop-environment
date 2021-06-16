# FAQ

## General

### Why call it TDE?

`TDE` stands for `TOS Desktop Environment`, this is because `TDE` is mainly developed for the `TOS` distribution.
More information can be found on their [website](https://tos.odex.be)


## Common issues

### My screens are not configured correctly

Underlying `TDE`makes use of `autorandr` to safe the screen state

If your screen doesn't work or behaves incorrectly try to verify that your autorandr config is correct:
```bash
autorandr --config
```
If that isn't the case you can issue [xrandr](https://wiki.odex.be/en/Usage/Configuration/X/Xrandr) command, or use graphical interfaces such as `arandr` to fix these screens.

Turning of a weird artifact:
```bash
xrandr --output DP2 --off
```

## Configuration


### How to autostart applications?

All executable shell scripts and desktop files in `~/.config/tos/autostart` get ran on startup.
If you want to launch an application put it there.

If the directory doesn't exist yet you can create it.

## Usage

### Layouts

With the default config, you can cycle through window layouts by pressing
"mod4+space" ("mod4+shift+space" to go back) or clicking the layout button in
the lower left corner of the screen.

### How to restart or quit TDE?

You can use the keybinding "Mod4+Ctrl+r" or by selecting restart in the menu.
You could call `awesome.restart` either from the Lua prompt widget, or via
`tde-client`:

    $ tde-client 'awesome.restart()'

You can also send the `SIGHUP` signal to the TDE process. Find the PID using
`ps`, `pgrep` or use `pkill`:

$ pkill -HUP tde

You can quit TDE by using "Mod4+Shift+q" keybinding or by selecting quit in
the menu. You could call `awesome.quit` either from the Lua prompt widget,
or by passing it to `tde-client`.

    $ echo 'awesome.quit()' | tde-client

You can also send the `SIGINT` signal to the TDE process. Find the PID using `ps`, `pgrep` or use `pkill`:

    $ pkill -INT tde

### Where are logs, error messages or something?

Logs can be found in the `~/.cache/tde/` directory.
Currently we store 2 files `stdout.log` stores all debug messages on stdout
and `error.log` stores all error messages (Both stderr and internal error messages)

### Can I have a client or the system tray on multiple screens at once?

No. This is an X11 limitation and there is no sane way to work around it.

## Development

### How to report bugs?

First, test the development version to check if your bug is still there. If the
bug is an unexpected behavior, please explain what you expected instead. If the
bug is a segmentation fault, please include a full backtrace (use gdb).

In any case, please try to explain how to reproduce it.

Please report any issues you may find on [our
bugtracker](https://github.com/ODEX-TOS/tos-desktop-environment/issues).

### Do you accept patches and enhancements?

Yes, we do.
You can submit pull requests on the [github repository](https://github.com/ODEX-TOS/tos-desktop-environment).
Please read the [contributing guide](https://github.com/ODEX-TOS/tos-desktop-environment/CONTRIBUTING.md)
for any coding, documentation or patch guidelines.
