# Github Contributions Widget

Shows the contribution graph, similar to the one on the github profile page:

## Customization

It is possible to customize the widget by providing a table with all or some of the following config parameters:

| Name          | Default               | Description                                              |
| ------------- | --------------------- | -------------------------------------------------------- |
| `username`    | 'streetturtle'        | Username                                                 |
| `days`        | `365`                 | Number of days in the past, more days - wider the widget |
| `empty_color` | `beautiful.bg_normal` | Color of the days with no contributions                  |
| `with_border` | `true`                | Should the graph contains border or not                  |
| `margin_top`  | `1`                   | Top margin                                               |

## Installation

Clone/download repo to `~/.config/tde/`:

modify the plugin `init.lua`

```lua
return worker(
    {
		-- change the username to your github user
        username = "F0xedb"
    }
)
```

Activate the plugin by adding the following to `~/.config/tos/plugins.conf`

```ini
topbar-right_1="jira_widget"
```
