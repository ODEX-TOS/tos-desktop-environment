# Installation

Install this plugin by adding this directory to `~/.config/tde/desktop-widgets`

Add the widget to the plugin config found at `~/.config/tos/plugins.conf`

```ini
module_1="desktop-widgets"
```

## Change the widget location

You can change the widget size and location in `~/.config/tde/desktop-widgets/config.lua`

You can inspect the default config file
It should look something like the following:

```lua
local widgets = {}

widgets[1] = {
    x = 0.77,
    y = 0.05,
    width = 0.2,
    height = 0.4,
    type = "chart",
    resource = "CPU",
    title = "CPU Chart"
}

widgets[2] = {
    x = 0.77,
    y = 0.50,
    width = 0.2,
    height = 0.4,
    type = "radial",
    resource = "RAM",
    title = "RAM Widget"
}

return widgets
```

You can add extra widgets by adding the following table:

```lua
widgets[3] = {
    x = 0.54,
    y = 0.50,
    width = 0.2,
    height = 0.4,
    type = "chart",
    resource = "RAM",
    title = "RAM Widget"
}
```

The elements of the widget are described in the table below

| Option   | Description                                                              | Default value | Possible values |
| -------- | ------------------------------------------------------------------------ | ------------- | --------------- |
| x        | The top left point of the widget relative to the left side of the screen | 0             | 0-1             |
| y        | The top left point of the widget relative to the top side screen         | 0             | 0-1             |
| width    | The width of the widget relative to the width of the screen              | 0             | 0-1             |
| height   | The height of the widget relative to the height of the screen            | 0             | 0-1             |
| title    | The title of the widget                                                  | type          | string          |
| type     | the type of the widget                                                   | radial        | chart or radial |
| resource | Which resource to monitor                                                | RAM           | CPU or RAM      |
