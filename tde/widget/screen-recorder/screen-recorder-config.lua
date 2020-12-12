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
local user_preferences = {}

local user_resolution = "1920x1080" -- Screen 	WIDTHxHEIGHT
local user_offset = "0,0" -- Offset 	x,y
local user_audio = false -- bool   	true or false
local user_save_directory = "$HOME/Videos/Recordings/" -- String 	$HOME
local user_mic_lvl = "20" -- String
local user_fps = "30" -- String

user_preferences.user_resolution = user_resolution
user_preferences.user_offset = user_offset
user_preferences.user_audio = user_audio
user_preferences.user_save_directory = user_save_directory
user_preferences.user_mic_lvl = user_mic_lvl
user_preferences.user_fps = user_fps

return user_preferences
