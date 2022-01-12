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
local client_keys = require("configuration.client.keys")
local client_buttons = require("configuration.client.buttons")
local config = tags
local config_float = floating

local ruled = require("ruled")

local function getItem(item)
  return config[item] or nil
end

local function getItemFloat(item)
  return config_float[item] or nil
end

local function getApplicationsPerTag(number)
  local screen = "screen_" .. number
  local iterator = {}
  local item = getItem(screen)
  if item ~= nil and type(item) == "table" then
    for _, value in ipairs(item) do
      table.insert(iterator, value)
    end
  elseif item ~= nil and type(item) == "string" then
    table.insert(iterator, item)
  end
  return iterator
end

local function getFloatingWindow()
  local name = "float"
  -- Add default applications that are always floating
  local iterator = {"Steam"}
  local item = getItemFloat(name)
  if  item ~= nil and type(item) == "table" then
    for _, value in ipairs(item) do
      table.insert(iterator, value)
    end
  elseif item ~= nil and type(item) == "string" then
    table.insert(iterator, item)
  end
  return iterator
end

local function getTitlebarWindow()
  local name = "no_titlebar"
  -- Add default applications that are always floating
  local iterator = {"Steam"}
  local item = getItem(name)
  if  item ~= nil and type(item) == "table" then
    for _, value in ipairs(item) do
      table.insert(iterator, value)
    end
  elseif item ~= nil and type(item) == "string" then
    table.insert(iterator, item)
  end
  return iterator
end

local floater = getFloatingWindow()
local no_titlebar = getTitlebarWindow()

ruled.client.connect_signal("request::rules", function()

  ruled.client.append_rule {
    rule = {},
    except_any = {
      instance = {
        "nm-connection-editor",
        "file_progress",
        "Pinentry",
        "pinentry"
      },
      class = {

      }
    },
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      buttons = client_buttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_offscreen,
      floating = false,
      maximized = false,
      above = false,
      below = false,
      ontop = false,
      sticky = false,
      maximized_horizontal = false,
      maximized_vertical = false,
      titlebars_enabled = false
    }
  }

  -- All clients will match this rule.
  ruled.client.append_rule {
    rule_any = {name = {"QuakeTerminal"}},
    properties = {skip_decoration = true, titlebars_enabled = false}
  }
  -- Terminals
  ruled.client.append_rule {
    rule_any = {
      class = getApplicationsPerTag(2)
    },
    properties = {
      tag = "2",
    }
  }
  -- Browsers
  ruled.client.append_rule {
    rule_any = {
      class = getApplicationsPerTag(1)
    },
    properties = {tag = "1"}
  }
  -- Editors
  ruled.client.append_rule {
    rule_any = {
      class = getApplicationsPerTag(3)
    },
    properties = {tag = "3"}
  }
  -- File Managers
  ruled.client.append_rule {
    rule_any = {
      class = getApplicationsPerTag(4)
    },
    properties = {tag = "4"}
  }
  -- Multimedia
  ruled.client.append_rule {
    rule_any = {
      class = getApplicationsPerTag(5)
    },
    properties = {tag = "5"}
  }
  -- Games
  ruled.client.append_rule {
    rule_any = {
      class = getApplicationsPerTag(6)
      --s  instance = { 'SuperTuxKart' }
    },
    properties = {
      screen = 1,
      tag = "6",
    }
  }
  -- Multimedia Editing
  ruled.client.append_rule {
    rule_any = {
      class = getApplicationsPerTag(7)
    },
    properties = {tag = "7"}
  }
  -- Custom
  ruled.client.append_rule {
    rule_any = {
      class = {
        "feh",
        "Lxpolkit"
      }
    },
    properties = {
      skip_decoration = false,
      titlebars_enabled = true,
      floating = true,
      placement = awful.placement.centered,
      ontop = true
    }
  }
  -- Dialogs
  ruled.client.append_rule {
    rule_any = {type = {"dialog"}, class = {"Wicd-client.py", "calendar.google.com"}},
    except_any = {
      class = {
        "Pinentry-gtk-2",
        "pinentry-gtk-2",
      }
    },
    properties = {
      placement = awful.placement.centered,
      ontop = true,
      floating = true,
      drawBackdrop = false, -- TRUE if you want to add blur backdrop
      skip_decoration = true
    }
  }
  -- Instances
  -- Network Manager Editor
  ruled.client.append_rule {
    rule = {
      instance = "nm-connection-editor"
    },
    properties = {
      skip_decoration = true,
      ontop = true,
      floating = true,
      drawBackdrop = false,
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      buttons = client_buttons
    }
  }
  -- For nemo progress bar when copying or moving
  ruled.client.append_rule {
    rule = {
      instance = "file_progress"
    },
    properties = {
      skip_decoration = true,
      ontop = true,
      floating = true,
      drawBackdrop = false,
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      buttons = client_buttons
    }
  }
  -- General settings for applications who should be floating.
  -- TODO: add a config file where users can add custom applications as floating
  ruled.client.append_rule {
    rule_any = {
      class = floater
    },
    properties = {
      skip_decoration = true,
      floating = true,
      placement = awful.placement.centered,
      ontop = false,
      titlebars_enabled = true
    }
  }
  ruled.client.append_rule {
    rule_any = {
      class = {"Xephyr"}
    },
    properties = {
      skip_decoration = true,
      floating = true,
      placement = awful.placement.centered,
      ontop = true
    }
  }
  ruled.client.append_rule {
    rule_any = {
      class = {"Toolkit"},
      name = {"Picture-in-Picture", "Picture in picture"}
    },
    properties = {
      floating = true,
      skip_decoration = true,
      placement = awful.placement.centered,
      ontop = true,
      sticky = true
    }
  }
  ruled.client.append_rule {
    rule_any = {
      class = no_titlebar,
      properties = {
        titlebars_enabled = false
      }
    }
  }
  ruled.client.append_rule {
    rule_any = {
      class = {"Onboard", "onboard"},
      properties = {
        titlebars_enabled = false,
        focusable = false,
        focus = awful.client.focus.filter,
        ontop = true,
        above = true,
        sticky = true
      }
    }
  }
  -- Polkit
  -- TODO: Detect the polkit type automatically
  ruled.client.append_rule {
    rule_any = {class = {"lxpolkit", "Lxpolkit"}},
    except_any = {type = {"dialog"}},
    properties = {
      skip_decoration = false,
      floating = true,
      placement = awful.placement.centered,
      ontop = true,
      drawBackdrop = true
    }
  }
  -- Dialog with blurred background
  ruled.client.append_rule {
    rule_any = {
      class = {
        "Pinentry-gtk",
        "pinentry-gtk",
        "pinentry-qt",
        "Pinentry-qt"
      }
    },
    properties = {
      floating = true,
      ontop = true,
      drawBackdrop = true
    }
  }
  ruled.client.append_rule {
    rule_any = {
      class = {
        "Pinentry-gtk-2",
        "pinentry-gtk-2",
      }
    },
    properties = {
      placement = awful.placement.centered,
      ontop = true,
      floating = true,
      drawBackdrop = true, -- TRUE if you want to add blur backdrop
      skip_decoration = false
    }
  }
  -- For Firefox Popup when you install extension and others
  ruled.client.append_rule {
    rule_any = {
      role = "Popup",
      class = {
        "mini panel",
        "Popup",
        "popup",
        "dialog",
        "Dialog"
      },
      type = "utility"
    },
    properties = {
      skip_decoration = false,
      ontop = true,
      floating = true,
      drawBackdrop = false,
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      buttons = client_buttons
    }
  }
end)


-- Edge case for windows that don't want to properly tile
-- e.g. google meets screen share, zoom preview box, etc
client.connect_signal("request::manage", function(c)
  if c.size_hints == nil then
    return
  end

  if c.size_hints["max_width"] == nil or c.size_hints["max_height"] == nil then
    return
  end

  local max_w = c.size_hints["max_width"]
  local max_h = c.size_hints["max_height"]

  local screen_geo = c.screen.workarea

  if max_w < screen_geo.width or max_h < screen_geo.height then
    c.floating = true
    awful.placement.no_offscreen(c)
  end
end)
