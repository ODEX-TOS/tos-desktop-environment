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

local beautiful = require("beautiful")
local signals = require("lib-tde.signals")
local get_screen = require("lib-tde.function.common").focused_screen
local dpi = beautiful.xresources.apply_dpi

local card = require("lib-widget.card")
local separator = require("lib-widget.separator")(dpi(5), "vertical")

local wibox = require("wibox")
local gears = require("gears")

local delegator = require("module.prompt_completions")


local promptPage

local prompt = wibox.widget.textbox("Default text")

local height = dpi(230)
local width = dpi(500)
local padding = dpi(2)

local results = wibox.layout.fixed.vertical()

screen.connect_signal(
  "request::desktop_decoration",
  function(s)
    promptPage =
        wibox {
        bg = beautiful.background.hue_800 .. beautiful.background_transparency,
        visible = false,
        ontop = true,
        type = "normal",
        height = height,
        width = width,
        x = s.geometry.x + s.geometry.width / 2 - (width / 2),
        y = s.geometry.y + s.geometry.height / 2 - (height / 2)
        }

    promptPage:setup {
        {
            wibox.container.margin(prompt, dpi(10)),
            nil,
            results,
            layout = wibox.layout.fixed.vertical
        },
        -- The real background color
        bg = beautiful.background.hue_800 .. beautiful.background_transparency,
        -- The real, anti-aliased shape
        shape = function(cr, shapeWidth, shapeHeight)
          gears.shape.rounded_rect(cr, shapeWidth, shapeHeight, dpi(24))
        end,
        widget = wibox.container.background()
      }
end)

signals.connect_refresh_screen(
  function()
    local s = get_screen()
    print("Refreshing prompt page")
    if not s.valid or promptPage == nil then
      return
    end
    -- the action center itself
    promptPage.x = s.geometry.x + s.geometry.width / 2 - (width / 2)
    promptPage.y = s.geometry.y + s.geometry.height / 2 - (height / 2)
  end
)

signals.connect_background_theme_changed(
  function(new_theme)
    promptPage.bg = new_theme.hue_800 .. beautiful.background_transparency
  end
)

local _index = 1
-- amount of items to show at once
local _list_amount = 5
-- what item in the _list_amount is the active one
local _selected_list_index = 0

local function update_rows()
  for i, child in ipairs(results.children) do
    if i == _selected_list_index + 1 then
      child.widget.highlight()
    else
      child.widget.unhighlight()
    end
  end
end

local _results = {}

local function create_result_selection(result)
  local _card = card()
  results:add(wibox.container.margin(_card, padding, padding, padding, padding) )

  local ratio = wibox.widget{
    wibox.widget {
      image = result.icon,
      resize = true,
      width = dpi(50),
      widget = wibox.widget.imagebox
    },
    wibox.widget {
      text = result.text,
      font = beautiful.font,
      widget = wibox.widget.textbox
    },
    separator,
    wibox.widget {
      text = result.action_name,
      widget = wibox.widget.textbox
    },
    layout = wibox.layout.ratio.horizontal
  }

  ratio.forced_height = (height / 6) - (padding * 2)

  ratio:adjust_ratio(2, 0.15, 0.55, 0.30)

  _card.update_body(ratio)
end

local function down()
  if _selected_list_index < _list_amount - 1 then
    _selected_list_index = _selected_list_index + 1
    return
  end
  _index = _index + 1
  if _index > #_results - _list_amount then
    _index = #_results - _list_amount + 1
  end
end

local function up()
  if _selected_list_index > 0 then
    _selected_list_index = _selected_list_index - 1
    return
  end
  _index = _index - 1
  if _index < 1 then
    _index = 1
  end
end
_G.root.prompt = function()
    if promptPage == nil then
        return
    end

    _index = 1


    promptPage.visible = true
    results.children = {}

    awful.prompt.run{
        prompt = "<b>" .. i18n.translate("Search") .. "</b>: ",
        bg = beautiful.bg_modal,
        bg_cursor = beautiful.primary.hue_700,
        textbox = prompt,
        text = "",
        keypressed_callback  = function(mod, key, cmd) --luacheck: no unused args
          if key == 'Down' then
            down()
            update_rows()
          elseif key == 'Up' then
            up()
            update_rows()
          elseif key == 'Escape' then
            _index = -1
            _selected_list_index = 0
          end
        end,
        changed_callback = function(input_text)
            if not input_text or #input_text == 0 then return end
            _results = delegator.get_completions(input_text)

            results.children = {}
            -- we render only the selected list of items
            if _index > 0 and _index <= #_results then
              for index, result in ipairs(_results) do
                if index >= _index and index < (_index + _list_amount) then
                  create_result_selection(result)
                end
              end
            end

            update_rows()
        end,
        -- make sure that cancelling the prompt also cleanly stops
        done_callback = function()
            promptPage.visible = false

            -- we found our match
            if _results[_index + _selected_list_index] ~= nil then
              delegator.perform_actions(_results[_index + _selected_list_index].payload, _results[_index + _selected_list_index].action_name)
            end
        end
    }
end
