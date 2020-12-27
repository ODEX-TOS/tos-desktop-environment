# Jira widget

The widget shows the number of tickets assigned to the user and when clicked shows them in the list with some additional information. When item in the list is clicked - it opens the issue in browser.

![git](./out.gif)

## How it works

Widget uses cURL to query Jira's [REST API](https://developer.atlassian.com/server/jira/platform/rest-apis/). In order to be authenticated, widget uses a [netrc](https://ec.haxx.se/usingcurl/usingcurl-netrc) feature of the cURL, which is basically to store basic auth credentials in a .netrc file in home folder.

If you are on Atlassian Cloud, then instead of providing a password in netrc file you can set an [API token](https://confluence.atlassian.com/cloud/api-tokens-938839638.html) which is a safer option, as you can revoke/change the token at any time.

## Customization

It is possible to customize widget by providing a table with all or some of the following config parameters:

| Name    | Default                                                                        | Description                      |
| ------- | ------------------------------------------------------------------------------ | -------------------------------- |
| `host`  | Required                                                                       | Ex: _https://support.idalko.com_ |
| `query` | `jql=assignee=currentuser() AND resolution=Unresolved`                         | JQL query                        |
| `icon`  | `~/.config/awesome/awesome-wm-widgets/jira-widget/jira-mark-gradient-blue.svg` | Path to the icon                 |

## Installation

Create a .netrc file in you home directory with following content:

```bash
machine <your_jira_url>
login <your_user_name>
password <your_password>
```

Then change file's permissions to 600 (so only you can read/write it):

```bash
chmod 600 ~/.netrc
```

And test if it works by calling the API:

```bash
curl -s -n 'https://<your_url>/rest/api/2/search?jql=assignee=currentuser()+AND+resolution=Unresolved'
```

Clone/download repo to `~/.config/tde/`:

modify the plugin `init.lua`

```lua
return worker(
    {
		-- change host to your jira instance
        host = "https://support.idalko.com"
    }
)
```

Activate the plugin by adding the following to `~/.config/tos/plugins.conf`

```ini
topbar-right_1="jira_widget"
```
