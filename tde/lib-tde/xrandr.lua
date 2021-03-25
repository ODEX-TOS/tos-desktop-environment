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
-- Separating Multiple Monitor functions as a separated module (taken from awesome wiki)
local gtable = require("gears.table")

local naughty = require("naughty")
local apps = require("configuration.apps")

-- A path to a fancy icon
local icon_path = "/etc/xdg/tde/theme/icons/laptop.svg"

-- Get active outputs
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

-- Build available choices
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

return {
   outputs = outputs,
   arrange = arrange,
   menu = menu,
   xrandr = xrandr
}
