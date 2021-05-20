# Plugin Intro

## Example plugins
First of all example plugins can be found in the `/etc/skel/.config/tde` directory.

For a fun example of what a plugin can do take a look at the snake game:

```sh
cat /etc/skel/.config/tde/snake/init.lua | tde-client
```

> Note: To stop the game press escape

## Plugin location

Before writing your first plugin you need to understand where they need to be located.
Plugins are located in the `~/.config/tde` directory.

If the directory doesn't exist yet then create one.

```sh
mkdir -p "$HOME/.config/tde"
```

Each subdirectory in this directory is one plugin

## Plugin configuration file

The configuration file to enable/disable plugins can be found in the following location `~/.config/tos/plugins.conf`

By default it looks like this:
```sh
# Notification widget plugins will be added in the notification center
notification="widget.user-profile"
notification="widget.social-media"
notification="widget.weather"
notification="widget.sars-cov-2"
notification="widget.calculator"

#module="hello-world"

#settings="hello-world-widget"


#topbar-right="icon_button"

# topbar-left="icon_button"

# topbar-center="icon_button"

#settings="settings-app-widget"
```

As you can see by default tde already makes use of some plugins.

> NOTE: plugins starting with `widget` are threated as internal widget implemented directly into `TDE`

## Plugin Types

1. `Modules`:
These plugins are simple scripts written in `lua` that are ran in the background under the same process as widgets (thus they can manipulate widgets and more). 
Users usually don't see these plugins working. 

Examples are: 

- low battery notifier
- keybindings
- settings modifiers
- file watchers 
- and many more. 

You can compair then with [daemons](https://en.wikipedia.org/wiki/Daemon_(computing)).

2. `Widgets`:
Next you have widgets, these are the plugins you see every day. 
They are the GUI representation of a certain object.
You can see them all over the place.
Starting from the clock, package updater, wifi widget, workspaces, settings app and more.
When writting a plugin you must take into consideration which one to use.
Everything is allowed in a Module, however when writing a Widget you must inherit wibox and return such an object to be consumed by TDE.

This will be explained below

### Plugin Widgets
Plugins widgets can be placed in multiple locations around the user interface.
In the configuration file you can specify where the widget should be placed.
Here are the current widget locations.

1. `settings` - The widget will be placed at the bottom of the settings app (left menu)
2. `topbar` - The widget will be placed in the topbar on the right side next to all the buttons
3. `notification center` - The widget will be put in the notification center under the widget tab


# My First Plugin

This part is interactive, it will guide you to make both a `Module` and a `Widget`, how to debug, testing out etc.

Follow this tutorial if you have never build a plugin before.

## Setting up development environment

First of all, make sure you have [wm-launch](https://github.com/ODEX-TOS/wm-debug) installed.
This will create a mock `TDE` instance that you can test without messing up your real desktop environment.
It is highly recommended you use this and this tutorial will make great use of it.

> Note: The above is not a hard requirement but makes debugging a lot more easily

To test if you installed wm-launch correctly execute the following command:

```sh
wm-launch -r 1080x1080
```

> Note: the `1080x1080` option creates a window of size 1080 pixels x 1080 pixels, if your monitor is sufficiently large increase this number

### IDE

Having autocompletion for `TDE` is really usefull and makes developing a lot easier.
Currently `TDE` only support autocomplete in VS Code using the following [docs](https://wiki.odex.be/en/Developer/vscode-tde)

## Module

### Setup

Lets get started with your first module.

Firstly create a new directory in `~/.config/tde/` called `my-first-module`

```sh
mkdir -p "$HOME/.config/tde/my-first-module"
```

This directory will house everything related to your project.

Next we tell `TDE` that we want to enable this module called `my-first-module`

Edit the following file `~/.config/tos/plugins.conf` and add the following:

```ini
module="my-first-module"
```

The above line will make `tde` use your module.


### Code

Next we will create the `lua` file that is your plugins entrypoint

The file is located in `~/.config/tde/my-first-module/init.lua`

Write the following into that file

```lua
print("Hello, World!")
print("This is executed from my plugin")
```

In essence you should have the following directory structure:
```txt
.config/
├─ tos/
│  ├─ plugins.conf
├─ tde/
│  ├─ my-first-module/
│  │  ├─ init.lua

```

### Run Your Plugin

Now lets run your plugin!

#### wm-launch

wm-launch is your best bet
Since you created the plugin and enabled it can simply launch the `wm-launch` command.

Look at your terminal and wait a few seconds until you see the `Hello, World!` and the `This is executed from my plugin` lines appear somewhere in the output

#### In current session

> Note: running arbitrary code in the current session could potentially break the system, make sure nothing wrong can happen
> The code you run can potentially contain leaks making the active session slow. This simple example couldn't hurt, but larger plugins can

First of all open 2 terminal.

1. The first monitors the log file from the active session
2. The second starts/activates your plugin.

Executed this command in the first terminal:
```sh
tail -f "$HOME/.cache/tde/stdout.log"
```

Executed this command in the seconds terminal:
```sh
cat "$HOME/.config/tde/my-first-module/init.lua" | tde-client
```

Afterwards check the first terminal, you should see your `Hello, World!` and `This is executed from my plugin` messages appear in the output.


> Note: `tde-client` is an interface into the active session, it allows sending `commands` to the interpreter so that you can modify the behaviour of `TDE`


## More advanced example

Great you created your first module, of course you can do more than printing to `stdout`
Since you are writing `lua` you have full control over the plugin.

Lets take a more advanced example.
A plugin that performs 2 simple tasks.
1. Execute a shell script
2. Plays a sound once the script finished

Open your `init.lua` file and add the following content
```lua
-- include some required modules
local spawn = awful.spawn

-- this is an example of the default 'pop' sound that tos uses, change the file to your liking
local function play_sound()
    spawn("paplay /etc/xdg/tde/sound/audio-pop.wav")
end 

-- This function gets called when our shell script is done executing
-- In our example we don't make use of the parameters
local function done_callback(stdout, stderr, reason, exitcode)
    print("Done executing shell script")
    print("STDOUT:")
    print(stdout)

    play_sound()
end

-- start of this plugin
print('Plugin Loaded')
play_sound() -- pop sound

-- lets execute a simple shell script
local cmd = [[
    echo 'Script started'
    sleep 5
    echo 'Script stopped'
]]
-- and execute it, we 'bind' the done_callback function to this shell script
spawn.easy_async_with_shell(cmd, done_callback)
```

The only build in module we use is called `awful.spawn`

Now execute your plugin as noted in the last section and see what happens.

## Widget

This section will be explained in the future

## Docs

Now that you have followed the tutorial and created both a basic `Module` and `Widget` you can explore the documentation.
Learn about the api and what `TDE` directly has to offer.

Some useful resources:

1. `Lua` [getting started](https://www.lua.org/pil/1.html)
2. `Example plugins` [Official plugins](https://github.com/ODEX-TOS/tos-desktop-environment/tree/master/plugins)
3. `This documentation` [site](../index.html)
4. `Recommended patterns` [Plugin recommended patterns](https://wiki.odex.be/en/Usage/Plugin)
5. `lib-widget` [contains useful widgets](../tde%20widget/lib-widget.button.html)
