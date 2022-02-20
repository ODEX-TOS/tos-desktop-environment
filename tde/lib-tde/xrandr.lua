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

-- Separating Multiple Monitor functions as a separated module (taken from tde wiki)
local gtable = require("gears.table")

local naughty = require("naughty")
local apps = require("configuration.apps")
local split = require("lib-tde.function.common").split
local mergesort = require("lib-tde.sort.mergesort")

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

local function get_cmd_from_output(output, use_save_state)
   local cmd = " --output " .. output .. " --panning 0x0 --scale 1x1 --auto"

   -- we have a non default resolution and refresh rate stored
   if use_save_state == true and _G.save_state ~= nil and _G.save_state.display ~= nil and _G.save_state.display[output] ~= nil then
      cmd = " --output " .. output .. " --panning 0x0 --scale 1x1 --mode " .. tostring(_G.save_state.display[output].resolution) .. " --rate " .. tostring(_G.save_state.display[output].refresh_rate)
   end

   return cmd
end

local function gen_cmd(out, choice, use_save_state)
   local cmd = "xrandr"
   for i, o in pairs(choice) do
      -- set resolution, refresh_rate and disable panning (in case it is on)
      cmd = cmd .. get_cmd_from_output(o, use_save_state == true)
      if i > 1 then
         cmd = cmd .. " --right-of " .. choice[i - 1]
      end
   end
   -- Disabled outputs
   for _, o in pairs(out) do
      if not gtable.hasitem(choice, o) then
         cmd = cmd .. " --output " .. o .. " --off"
      end
   end

   return cmd
end

--- Build available screen orientations with accompanying xrandr commands
-- @treturn table A list of tables with the following signature: {label, cmd, choice, cmd_no_save_state}
-- @staticfct lib-tde.xrandr.menu
-- @usage -- Get all list of all permutations with labels, command and choice
-- lib-tde.xrandr.menu({'eDP1', 'DP2'})
local function menu()
   local menu_tbl = {}
   local out = outputs()
   local choices = arrange(out)

   for _, choice in pairs(choices) do
      local cmd = gen_cmd(out, choice, true)

      local label = ""
      if #choice == 1 then
         label = i18n.translate("Only") .. ' <span weight="bold">' .. choice[1] .. "</span>"
      else
         for i, o in pairs(choice) do
            if i > 1 then
               label = label .. " + "
            end
            label = label .. '<span weight="bold">' .. o .. "</span>"
         end
      end

      menu_tbl[#menu_tbl + 1] = {label, cmd, choice, gen_cmd(out, choice, false)}
   end

   menu_tbl[#menu_tbl + 1] = {
      i18n.translate("Duplicate Smallest Screen"),
      apps.default.duplicate_screens,
      {i18n.translate("Smallest")},
   }


   menu_tbl[#menu_tbl + 1] = {
      i18n.translate("Duplicate Largest Screen"),
      apps.default.duplicate_screens_largest,
      {i18n.translate("Largest")},
   }

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
            awful.spawn("sh -c 'which autorandr && autorandr --save tde --force'", false)
            --_G.tde.restart()
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
      label = i18n.translate("Keep the current configuration")
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

--- Get a list of all existing screens with their resolutions, refresh rates and position in the screen XY space
-- @treturn table A table of tables with the following signature: {'eDP1': {position: '0+0', resolution: '1920x1080', '1920x1080': {'60'}, '1080x720': {'60', '59.98', '29.99'}, ...}, 'DP2': {position: '1920+1080', resolution: '1920x1080', '1920x1080': {'60'} ...}...}
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
         local output, active_res, location = line:match("^([%w-]+) connected.* ([0-9]+x[0-9]+)%+([0-9]+%+[0-9]+)")
         if output ~= nil  then
            activeOutput = output
            data_tbl[activeOutput] = {
               position = location,
               resolution = active_res
            }
            active = true
         end

         -- check for disconnected screens, don't scan/populate it
         local isDisconnected = line:match("^([%w-]+) disconnected")
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
      xrandr_out:close()
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

local function _sort_monitors_in_x_screen_space(_outputs)
   -- lets find the monitors from left to right
   local mon_tbl = {}
   for key, output in pairs(_outputs) do
       if output.position then
       local x_component = tonumber(split(output.position, '+')[1])
       table.insert(mon_tbl, {x = x_component, output = key})
       end
   end

   return mergesort(mon_tbl, function(a, b)
       return a.x < b.x
   end)
end

--- Find the current monitor positions and make sure they are next to eachother
-- @tparam[opt] table _outputs the output of lib-tde.xrandr.output_data, if not given this will call it for you
-- @staticfct lib-tde.xrandr.reposition_monitors
-- @usage -- If 2 or more monitors are connected and not duplicating, reposition them next to eachother
-- lib-tde.xrandr.reposition_monitors()
local function reposition_monitors(_outputs)
  local cmd = "xrandr "
  _outputs = _outputs or output_data()

  local monitor_positions = _sort_monitors_in_x_screen_space(_outputs)

  local total_x = 0

  for i, mon in ipairs(monitor_positions) do
      -- we are the first monitor
      if i == 1 then
       local output = _outputs[mon.output]
       local resolution = output.resolution
       cmd = cmd .. " --output " .. mon.output .. ' --mode ' .. resolution .. " --scale 1x1 --pos 0x0"
      else
       local output = _outputs[mon.output]
       local prev_output = _outputs[monitor_positions[i - 1].output]

       local x_component = split(prev_output.resolution, 'x')[1]
       local y_component = split(output.position, '+')[2]

       -- Only add then up if the positions are different (e.g. not duplicating)
       if prev_output.position ~= output.position then
           total_x = math.floor(x_component + total_x)
       end

       cmd = cmd .. " --output " .. mon.output .. ' --mode ' .. output.resolution .. " --scale 1x1 --pos " .. total_x .. "x" .. y_component
      end
  end

  return cmd
end

return {
   outputs = outputs,
   inactive = inactive,
   arrange = arrange,
   menu = menu,
   xrandr = xrandr,
   output_data = output_data,
   reposition_monitors = reposition_monitors,
   highest_refresh_rate_from_resolution = highest_refresh_rate_from_resolution,
   highest_refresh_rate = highest_refresh_rate,
   highest_resolution = highest_resolution,
}
