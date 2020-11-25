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
