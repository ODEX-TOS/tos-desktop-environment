#! /usr/bin/env lua
local hardware = require("lib-tde.hardware-check")

print(hardware.getDefaultIP())
