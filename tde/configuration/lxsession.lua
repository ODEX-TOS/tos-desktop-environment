--[[
--MIT License
--
--Copyright (c) 2019 manilarome
--Copyright (c) 2020 Tom Meyers
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
]]

-- Since we use the lxsession session manager it makes some assumptions,
-- This file is used to overwrite the lxsession desktop.conf file (Present in ~/.config/lxsession/TDE/desktop.conf)
-- As we set specific data in specific locations (Such as the theme) we need to overwrite the file.
return [[
[Session]
keyring/command=echo
disable_autostart=yes
polkit/command=echo
clipboard/command=echo
xsettings_manager/command=build-in
proxy_manager/command=build-in

[GTK]
iXft/Antialias=1
iXft/Hinting=1
sXft/HintStyle=hintslight
sXft/RGBA=rgb
sNet/ThemeName=Arc-Darker
sNet/IconThemeName=Papirus-Dark
iNet/EnableEventSounds=0
iNet/EnableInputFeedbackSounds=0
sGtk/ColorScheme=
sGtk/FontName=Sans 10
iGtk/ToolbarStyle=3
iGtk/ToolbarIconSize=3
iGtk/ButtonImages=1
iGtk/MenuImages=1
iGtk/CursorThemeSize=0
sGtk/CursorThemeName=Human

[Mouse]
AccFactor=20
AccThreshold=10
LeftHanded=0

[Keyboard]
Delay=500
Interval=30
Beep=1

[State]
guess_default=false

[Dbus]
lxde=false

[Environment]
menu_prefix=tde-
]]