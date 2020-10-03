-- This module loads in backend plugins found under .config/tde/*/.init.lua

-- we don't need to do anything since the plugin loader automatically requires said plugins
local plugins = require("helper.plugin-loader")("module")
