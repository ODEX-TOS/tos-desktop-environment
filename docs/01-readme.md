[![Build Status repo][repo-build]][repo-url]
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url] [![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GPL License][license-shield]][license-url]


<center> <img src="../images/logo.png" /> </center>

### TOS Desktop Environment
A desktop environment build ontop of awesome wm

**[Explore the docs »](https://tos.odex.be/docs/)**

<center> <a href="https://wiki.odex.be">View wiki</a> - <a href="https://github.com/ODEX-TOS/tos-desktop-environment/issues">Report Bug</a> - <a href="https://github.com/ODEX-TOS/tos-desktop-environment/issues">Request Feature</a> </center>


<!-- ABOUT THE PROJECT -->

## About The Project

### Built By

- [F0xedb](https://www.odex.be)

<!-- GETTING STARTED -->

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

> TDE depends on a lot of different tools and projects. A list can be found
> [here](https://github.com/ODEX-TOS/tos-live/blob/master/repo/BUILD/PKGBUILD_AWESOME)

![desktop](https://github.com/ODEX-TOS/tos-desktop-environment/blob/master/images/desktop.png?raw=true)

### Installation

1. Install dependencies

```sh
sudo tos -S tde xorg-server-xephyr
```

if you are using an arch based distro that is not tos add the following repo to `/etc/pacman.conf`

```ini
[tos]
Server = https://repo.odex.be
```

2. Clone the repo

```sh
git clone https://github.com/ODEX-TOS/tos-desktop-environment.git
```

3. Set the required files in the appropriate locations

```sh
sudo mkdir -p /etc/xdg/tde
sudo cp -r tos-desktop-environment/tde/* /etc/xdg/tde
```

4. Use wm-debug for easier development

```sh
git clone https://github.com:ODEX-TOS/wm-debug.git
cd wm-debug
# prepare the wm-launch settings etc
sudo ./wm-launch -i

# you can now access wm-launch from everywhere
# the -r 100x720 will create a screen of that size with TDE inside of it
wm-launch -r 1080x720
```

## Usage

`TDE` has an entire wiki which explains most in detail. It can be found
[here](https://wiki.odex.be) The README helps you into figuring out how to help
and how to get started

We have three major directories

- `tos` contains the configuration files of TDE - this directory contains
  example conf files (the real once are stored in `~/.config/tos`)
- `plugins` contains example plugins for TDE (the real once are stored in
  `~/.config/tde`)
- `tde` the source code of the desktop environment

### Unit Test

You can run unit tests by executing the following command in the root project
directory

```sh
bash test-runner.sh
```

You can also get the JUNIT output by executing the following (t will be saved in
result.xml)

```sh
bash test-runner.sh result.xml
```

Alternative unit testing output is also available

```sh
RUNNER="tap" bash test-runner.sh
```

#### Docker

You can also run the test suite using the `tos` docker image We have provided an
image on top of that located in `tests/Dockerfile`` You can build and run it
like this:

```sh
# build the image
docker build -t "tde-test-suite" tests

# run the test suite
docker run -v "$(pwd):/data" tde-test-suite
```

Alternatively we have provided a docker-compose file that does this all for you

```sh
docker-compose up
```

### Profiling

When developing you can also perform some profiling.
The `TDE profiler` listens for function calls and counts how many times the happen. For each function call we measure the time it took.
This way we can have educated guesses where the time gets spent the most.
Thus improving performance in the most critical parts of the system.

Profiling can be done by executing the following command:

```bash
bash profiler.sh --help
# for example profile tde (for 10 seconds) and return the top 100 functions (in terms of cpu time)
bash profiler.sh -t 10 -F 100
# Same as above but use realtime instead of cpu time
bash profiler.sh -t 10 -F 100 -r

# Save the result to tde-functions.result
bash profiler.sh -t 10 -o tde-functions.result

# Run the profiler on a file
bash profiler.sh -f tests/scripts/full

```

### Hot Reload Widgets

You can also quickly develop widgets for `tde` this can be done through the `hot-reload-widget.sh` file
Note that you need to have `inotify-tools` installed.
If you are using the `TOS` operating system, this script will auto download it for you.

Development using this script is as followed:

1. create a `.lua` file in our example we will use `hello.lua`
2. The bare minimum for this file should be the following:

```lua
local wibox = require("wibox")
return wibox.widget.textbox("hello")
```

3. Run the script on this file

```bash
bash scripts/hot-reload-widget.sh hello.lua # replace hello.lua with your file
```

4. develop your widget/plugin

> NOTE: The file you are developing on needs to return a `wibox.widget` object
> Otherwise `TDE` doesn't know how to display it

> Second NOTE: the script listens for filesystem event and reloads your widget each time it is changed

Some people don't like that the hot-reloaded widget consumes the entire space.
If that is the case then use the `-s` option this will make the widget consume 50% of the screen instead of everything. (This issue is not present with multi monitor setups)

#### closing the widget

We don't use the Escape key to close the widget
This is because we would need to consume the Escape key.
This would result it the underlying widget from not being able to capture this event.
Thus we decided to strictly use the backdrop/close button to close the widget.

### Commit hooks

Before creating commits you need to setup commit hooks.
These commit hooks perform a series of checks to make sure you didn't forget something important

This ranges from linting, license checks, correct usage of branching etc

It is not mandatory to use this feature, however it will make it more likely to be allowed.

Setting the commit hooks is as easy as executing the following commands from the project root:

```bash
ln -s "$PWD"/hooks/pre-commit .git/hooks/pre-commit
ln -s "$PWD"/hooks/commit-msg .git/hooks/commit-msg
ln -s "$PWD"/hooks/pre-push .git/hooks/pre-push

```

<!-- ROADMAP -->

## Roadmap

See the
[open issues](https://github.com/ODEX-TOS/tos-desktop-environment/issues) for a
list of proposed features (and known issues).

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to
be learn, inspire, and create. Any contributions you make are **greatly
appreciated**. First ensure you have read the [wiki](https://wiki.odex.be)
especially the [style guide](https://wiki.odex.be/Developer/style-guide) page

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- CONTACT -->

## Contact

Tom Meyers - tom@odex.be

Project Link:
[https://github.com/ODEX-TOS/tos-desktop-environment](https://github.com/ODEX-TOS/tos-desktop-environment)

<!-- ACKNOWLEDGEMENTS -->

## Acknowledgments

- [F0xedb](https://www.odex.be)
- [TOS Homepage](https://tos.odex.be)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[repo-build]: https://jenkins.odex.be/buildStatus/icon?job=tos-repo&style=flat-square&subject=tde-build
[repo-url]: https://jenkins.odex.be/job/tos-repo/
[contributors-shield]: https://img.shields.io/github/contributors/ODEX-TOS/tos-desktop-environment.svg?style=flat-square
[contributors-url]: https://github.com/ODEX-TOS/tos-desktop-environment/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ODEX-TOS/tos-desktop-environment.svg?style=flat-square
[forks-url]: https://github.com/ODEX-TOS/tos-desktop-environment/network/members
[stars-shield]: https://img.shields.io/github/stars/ODEX-TOS/tos-desktop-environment.svg?style=flat-square
[stars-url]: https://github.com/ODEX-TOS/tos-desktop-environment/stargazers
[issues-shield]: https://img.shields.io/github/issues/ODEX-TOS/tos-desktop-environment.svg?style=flat-square
[issues-url]: https://github.com/ODEX-TOS/tos-desktop-environment/issues
[license-shield]: https://img.shields.io/github/license/ODEX-TOS/tos-desktop-environment.svg?style=flat-square
[license-url]: https://github.com/ODEX-TOS/tos-desktop-environment/blob/master/LICENSE.txt
[product-screenshot]: https://tos.odex.be/images/logo.svg