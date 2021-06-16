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

---------------------------------------------------------------------------
-- Lua bindings for the xrandr interface/cli
--
-- xrandr is an official configuration utility to the RandR (Resize and Rotate) X Window System extension.
-- It can be used to set the size, orientation or reflection of the outputs for a screen.
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdedatamod lib-tde.xrandr
---------------------------------------------------------------------------

-- Separating Multiple Monitor functions as a separated module (taken from awesome wiki)
local gtable = require("gears.table")

local naughty = require("naughty")
local apps = require("configuration.apps")
local split = require("lib-tde.function.common").split

local LOG_ERROR = "\27[0;31m[ ERROR "
-- A path to a fancy icon
local icon_path = "/etc/xdg/tde/theme/icons/laptop.svg"

--- Get all connected screen outputs
-- @treturn table A list containing the names of all screens
-- @staticfct lib-tde.xrandr.outputs
-- @usage -- Get all active screens
-- lib-tde.xrandr.outputs() -- Returns (For example) {'eDP1', 'DP1', 'DP2'}
local function outputs()
   local output_tbl = {}
   local xrandr = io.popen("xrandr -q --current")

   if xrandr then
      for line in xrandr:lines() do
         local output = line:match("^([%w-]+) connected ")
         if output then
            output_tbl[#output_tbl + 1] = output
         end
      end
      xrandr:close()
   end

   return output_tbl
end

--- Get the inactive screen outputs
-- @treturn table A list containing the names of all inactive screens
-- @staticfct lib-tde.xrandr.inactive
-- @usage -- Get all the inactive screens
-- lib-tde.xrandr.inactive() -- Returns (For example) {'eDP1', 'DP1', 'DP2'}
local function inactive()
   local output_tbl = {}
   local xrandr = io.popen("xrandr -q --current")

   if xrandr then
      for line in xrandr:lines() do
         -- active screens have text between connected and (...) that note the location and size of the screen
         local output = line:match("^([%w-]+) connected %(")
         if output then
            output_tbl[#output_tbl + 1] = output
         end
      end
      xrandr:close()
   end

   return output_tbl
end

--- Arrange all possible permutations of a given list of screens
-- @tparam table list A list of screen outputs
-- @treturn table A list containing all screen permutations
-- @staticfct lib-tde.xrandr.arrange
-- @usage -- Get all list of all permutations
-- lib-tde.xrandr.arrange({'eDP1', 'DP2'}) -- Returns {1: {'eDP1'}, 2: {'DP2'}, 3: {'eDP1', 'DP2'}, 4: {'DP2', 'eDP1'}}
local function arrange(out)
   -- We need to enumerate all permutations of horizontal outputs.

   local choices = {}
   local previous = {{}}
   for _ = 1, #out do
      -- Find all permutation of length `i`: we take the permutation
      -- of length `i-1` and for each of them, we create new
      -- permutations by adding each output at the end of it if it is
      -- not already present.
      local new = {}
      for _, p in pairs(previous) do
         for _, o in pairs(out) do
            if not gtable.hasitem(p, o) then
               new[#new + 1] = gtable.join(p, {o})
            end
         end
      end
      choices = gtable.join(choices, new)
      previous = new
   end

   return choices
end

--- Build available screen orientations with accompanying xrandr commands
-- @treturn table A list of tables with the following signature: {label, cmd, choice}
-- @staticfct lib-tde.xrandr.menu
-- @usage -- Get all list of all permutations with labels, command and choice
-- lib-tde.xrandr.menu({'eDP1', 'DP2'})
local function menu()
   local menu_tbl = {}
   local out = outputs()
   local choices = arrange(out)

   for _, choice in pairs(choices) do
      local cmd = "xrandr"
      -- Enabled outputs
      for i, o in pairs(choice) do
         -- set default resolution and disable panning (in case it is on)
         cmd = cmd .. " --output " .. o .. " --panning 0x0 --auto"
         if i > 1 then
            cmd = cmd .. " --right-of " .. choice[i - 1]
         end
         -- duplicate command due to xrandr bug?
         --cmd = cmd .. "; sleep 1; " .. cmd
      end
      -- Disabled outputs
      for _, o in pairs(out) do
         if not gtable.hasitem(choice, o) then
            cmd = cmd .. " --output " .. o .. " --off"
         end
      end

      local label = ""
      if #choice == 1 then
         label = 'Only <span weight="bold">' .. choice[1] .. "</span>"
      else
         for i, o in pairs(choice) do
            if i > 1 then
               label = label .. " + "
            end
            label = label .. '<span weight="bold">' .. o .. "</span>"
         end
      end

      menu_tbl[#menu_tbl + 1] = {label, cmd, choice}
      if #choice == 1 then
         menu_tbl[#menu_tbl + 1] = {
            'Duplicate <span weight="bold">' .. choice[1] .. "</span>",
            apps.default.duplicate_screens .. " " .. choice[1],
            choice
         }
      end
   end

   return menu_tbl
end

-- Display xrandr notifications from choices
local state = {cid = nil}

local function naughty_destroy_callback(_)
   local action = state.index and state.menu[state.index - 1][2]
   if action then
      awful.spawn.easy_async_with_shell(
         action,
         function()
            awful.spawn("sh -c 'which autorandr && autorandr --save tde --force'")
            --_G.awesome.restart()
         end
      )
      state.index = nil
   end
end

-- This should only be shown in the (keys) global.lua file
-- Don't expose it to the plugin api, as it has state that changes on each call
-- See the `state` variable
local function xrandr()
   -- Build the list of choices
   if not state.index then
      state.menu = menu()
      -- append extra options to the end
      -- state.menu[#state.menu + 1] = {'Duplicate screens', apps.default.duplicate_screens}
      state.index = 1
   end

   -- Select one and display the appropriate notification
   local label
   local next = state.menu[state.index]
   state.index = state.index + 1

   if not next then
      label = "Keep the current configuration"
      state.index = nil
   else
      label = next[1]
   end
   print("Display mode: " .. label)
   local noti =
      naughty.notify(
      {
         title = i18n.translate("Screen System"),
         text = label,
         icon = icon_path,
         timeout = 4,
         screen = mouse.screen,
         replaces_id = state.cid
      }
   )
   noti:connect_signal("destroyed", naughty_destroy_callback)
   state.cid = noti.id
end

--- Get a list of all existing screens with their resolutions and refresh rates
-- @treturn table A table of tables with the following signature: {'eDP1': {resolution: {'Refresh Rate 1', 'Refresh Rate 2', ...}, '1920x1080': {'60'}, ...}, ...}
-- @staticfct lib-tde.xrandr.output_data
-- @usage -- Get a list of all screens
-- local xrandr_data = lib-tde.xrandr.output_data()
local function output_data()
   -- get the current screen output
   local xrandr_out = io.popen("xrandr -q --current")

   local activeOutput = ""
   local active = false
   local data_tbl = {}

   if xrandr_out then
      for line in xrandr_out:lines() do
         local output = line:match("^([%w-]+) connected ")
         if output ~= nil  then
            activeOutput = output
            data_tbl[activeOutput] = {}
            active = true
         end

         -- check for disconnected screens, don't scan/populate it
         local isDisconnected = line:match("^([%w-]+) disconnected ")
         if isDisconnected ~= nil then
            data_tbl[isDisconnected] = {}
            active = false
         end

         -- This is a resolution line for the active screen (1920x1080 60.00 + 59.95 45.00)
         if (string.sub(line, 1, 1) == " " or string.sub(line, 1, 1) == "\t") and active then
            local splitted = split(line, "%s")
            data_tbl[activeOutput][splitted[1]] = {}
            for i, v in ipairs(splitted) do
               if i ~= 1 and v ~= '+' then
                  v = v:match('(%d+%.%d+).*')
                  table.insert(data_tbl[activeOutput][splitted[1]], v)
               end
            end
         end
      end
   end

   return data_tbl
end

--- Find the highest resolution of a given monitor with all possible refresh rates
-- @tparam table|string output A screen table from lib-tde.xrandr.output_data or the string representation of an randr screen
-- @treturn string A string representation of the highest resolution of a given monitor eg 1920x1080
-- @treturn table The seconds return element is a table of possible refresh rates
-- @staticfct lib-tde.xrandr.highest_resolution
-- @usage -- Get back the highest resolution of the 'eDP1' monitor
-- local xrandr_data = lib-tde.xrandr.highest_resolution('eDP1') -- Returns for example: 1920x1080, {'60', '120', '144'}
local function highest_resolution(output)
   if output == nil or (type(output) ~= "string" and type(output) ~= "table") then
      return
   end

   local lookup_table = output
   -- if the output is a string, then we fetch the lookup table
   if type(lookup_table) == "string" then
      lookup_table = output_data()
      lookup_table = lookup_table[output]
   end

   -- invalid monitor has been supplied
   if lookup_table == nil then
      print(tostring(output) .. 'is an invalid monitor', LOG_ERROR)
      return
   end

   local largest_res_key = '1x1'
   local larget_res_pixels = 0

   for key, _ in pairs(lookup_table) do
      local splitted = split(key, 'x')
      local value = (tonumber(splitted[1]) or 1) * (tonumber(splitted[2]) or 1)
      if value > larget_res_pixels then
         larget_res_pixels = value
         largest_res_key = key
      end
   end
   return largest_res_key, lookup_table[largest_res_key]
end

--- Find the highest refresh rate of a given monitor with the accompanying resolution
-- @tparam table|string output A screen table from lib-tde.xrandr.output_data or the string representation of an randr screen
-- @treturn number The highest refresh rate found in Hertz
-- @treturn string The seconds return element is a string representation of the resolution linked to this refresh rate
-- @treturn table The third return element is a table of possible refresh rates linked to the resolution
-- @staticfct lib-tde.xrandr.highest_refresh_rate
-- @usage -- Get back the highest refresh rate of the 'eDP1' monitor
-- local xrandr_data = lib-tde.xrandr.highest_refresh_rate('eDP1') -- Returns for example: 144, '1920x1080', {'60', '120', '144'}
local function highest_refresh_rate(output)
   if output == nil or (type(output) ~= "string" and type(output) ~= "table") then
      return
   end

   local lookup_table = output
   -- if the output is a string, then we fetch the lookup table
   if type(lookup_table) == "string" then
      lookup_table = output_data()
      lookup_table = lookup_table[output]
   end

   -- invalid monitor has been supplied
   if lookup_table == nil then
      print(tostring(output) .. 'is an invalid monitor', LOG_ERROR)
      return
   end

   local res_key = '1x1'
   local largest_refresh_value = 0

   for res, value in pairs(lookup_table) do
      for _, refresh_rate in ipairs(value) do
         refresh_rate = tonumber(refresh_rate) or 0
         if refresh_rate > largest_refresh_value then
            largest_refresh_value = refresh_rate
            res_key = res
         end
      end
   end
   return largest_refresh_value, res_key, lookup_table[res_key]
end

--- Find the highest refresh rate of a given resolution
-- @tparam table res_tbl A resolution table from lib-tde.xrandr.output_data, the reolsution table must be taken from a given screen
-- @treturn number The highest refresh rate found in Hertz
-- @staticfct lib-tde.xrandr.highest_refresh_rate_from_resolution
-- @usage -- Get back the highest refresh rate of the 'eDP1' monitor with resolution '1920x1080'
-- local xrandr_data = lib-tde.xrandr.highest_refresh_rate_from_resolution(output['eDP1']['1920x1080']) -- Returns for example 144
-- local xrandr_data = lib-tde.xrandr.highest_refresh_rate_from_resolution({'60', '120', 144'}) -- Returns for example 144
local function highest_refresh_rate_from_resolution(res_tbl)
   if type(res_tbl) ~= "table" then
      return
   end

   local largest_rate = 0

   for _, rate in ipairs(res_tbl) do
      rate = tonumber(rate) or 0
      if rate > largest_rate then
         largest_rate = rate
      end
   end

   return largest_rate
end

return {
   outputs = outputs,
   inactive = inactive,
   arrange = arrange,
   menu = menu,
   xrandr = xrandr,
   output_data = output_data,
   highest_refresh_rate_from_resolution = highest_refresh_rate_from_resolution,
   highest_refresh_rate = highest_refresh_rate,
   highest_resolution = highest_resolution
}
