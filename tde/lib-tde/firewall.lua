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
-- This module allows controlling the firewall (ufw)
--
--    -- You can do some interesting things
--    firewall.is_installed() -- returns if the firewall is installed or if the package is missing
--    firewall.set_active(true) -- enable/disable the firewall
--
--    firewall.get_rules(function(rules) print(rules) end) -- returns a table of active rules in a callback function
--    firewall.add_rule({direction=firewall.direction.OUT, state=firewall.state.DENY, port=22, ip_range=nil }) -- block the outgoing port 22 on all ip adresses
--    firewall.add_rule({direction=firewall.direction.IN, state=firewall.state.ALLOW, port=22, ip_range='10.0.0.0/8' }) -- Allow ssh login from the 10.0.0.0/8 network
--
--    firewall.add_rule({direction=firewall.direction.OUT, state=firewall.state.DENY, default=true }) -- By default deny all outgoing traffic

--    firewall.remove_rul(rules[1])
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.firewall
---------------------------------------------------------------------------

local hardware = require("lib-tde.hardware-check")
local split = require("lib-tde.function.common").split

local direction = {}
direction["IN"] = "IN"
direction["OUT"] = "OUT"

local state = {}
state["DENY"] = "deny"
state["ALLOW"] = "allow"

local function __add_default_rule(rule)
    -- either default deny or default allow
    local cmd = "pkexec ufw default " .. rule.state
    awful.spawn.easy_async(cmd)
end

local function _populate(rule)
    rule.default = rule.default or false
    rule.direction = rule.direction or direction.OUT
    rule.state = rule.state or state.DENY
    rule.port = tostring(rule.port or "") or ""
    rule.ip = rule.ip or ""

    return rule
end

local function _gen_cmd(rule)
    -- it is not default, so lets build the ufw command
    -- all elements exist
    if rule.direction == direction.IN and rule.ip ~= "" and rule.port ~= "" then
        return string.format("%s from %s to any port %s", rule.state, rule.ip, rule.port)
    elseif rule.direction == direction.OUT and rule.ip ~= "" and rule.port ~= "" then
        return string.format("%s from any port %s to %s", rule.state, rule.port, rule.ip)

    -- all elements except for the port exist
    elseif rule.direction == direction.IN and rule.ip ~= "" and rule.port == "" then
        return string.format("%s from %s to any", rule.state, rule.ip)
    elseif rule.direction == direction.OUT and rule.ip ~= "" and rule.port == "" then
        return string.format("%s from any to %s", rule.state, rule.ip)

    -- all elements except for the ip exist
    elseif rule.direction == direction.IN and rule.ip == "" and rule.port ~= "" then
        return string.format("%s to any port %s", rule.state, rule.port)
    elseif rule.direction == direction.OUT and rule.ip == "" and rule.port ~= "" then
        return string.format("%s from any port %s", rule.state, rule.port)
    else
        print("Unknown rule")
        print(rule)
        return ""
    end
end

local function _parse_ufw_output_line(line)
    local splitted = split(line, '%s')

    local _state
    local _direction
    local _ip = ""
    local _port = ""
    local _default = false

    local function _get_ip_or_port(val)
        local _ip_split = split(val, '.')
        if #_ip_split == 4 then
            return val, true
        end
        return val, false
    end

    local to = splitted[1]
    if to ~= "Anywhere" then
        -- it is either a port or an ip
        local value, bIsIp = _get_ip_or_port(to)
        if bIsIp then
            _ip = value
        else
            _port = value
        end
    end

    local from = splitted[3]
    if from ~= "Anywhere" then
        -- it is either a port or an ip
        local value, bIsIp = _get_ip_or_port(from)
        if bIsIp then
            _ip = value
            _direction = direction.IN
        else
            _port = value
            _direction = direction.OUT
        end
    else
        _direction = direction.IN
    end

    -- all that is left to do is the action
    local action = split(splitted[2], "%s")
    _state = state[action[1]] or state.ALLOW

    return {
        state = _state,
        direction = _direction,
        ip = _ip,
        port = _port,
        default = _default
    }
end

--- Check if UFW (The firewall that is supported) is installed
-- @treturn bool True if the firewall is installed
-- @staticfct is_installed
-- @usage -- This will return true if ufw (firewall) and "pkexec" (Polkit privilege escalation) tools are installed
-- lib-tde.firewall.is_installed()
local function is_installed()
    local exists, _ = hardware.is_in_path("ufw")
    -- we use pkexec to do privilege escalation to root
    local pk_exists, _ = hardware.is_in_path("pkexec")

    -- the ufw firewall doesn't exists or pkexec doesn't exist
    return exists and pk_exists
end

local function is_active(stdout)
    local exists = is_installed()

    if not exists then
        return false
    end

    -- the firewall package exists
    local inactive = stdout:find("^Status: inactive")
    return inactive == nil

end

--- Enable/Disable the firewall
-- @tparam bool active If we should activate/deactivate the firewall
-- @tparam[opt] function callback A callback function to trigger after finishing execution
-- @staticfct set_active
-- @usage -- Enable the firewall (Will ask for user password)
-- lib-tde.firewall.set_active(true, function() print("Done executing") end)
local function set_active(active, callback)
    local _state = "enable"
    if not active then
        _state = "disable"
    end
    awful.spawn.easy_async("pkexec ufw " .. _state, function ()
        if callback then
            callback()
        end
    end)
end

--- Enable/Disable the firewall (Will ask for permissions)
-- @tparam function callback A callback function to trigger after finishing execution, returns a list of rules back and if the firewall is active
-- @staticfct get_rules
-- @usage -- Get the currently active rules
-- lib-tde.firewall.get_rules(function(rules, is_active) print(rules) end)
local function get_rules(callback)
    awful.spawn.easy_async("pkexec ufw status", function(stdout)
        local lines = split(stdout, "\n")
        local result = {}
        -- the first 4 lines are the status, header and splitter
        -- afterwards the list of actions starts
        if #lines < 4 then
            callback(result, is_active(stdout))
        end
        for i = 4, #lines do
            local line = lines[i]
            -- filter out the (v6) version as we always use ipv4 and ipv6
            if line:find("%(v6%)") == nil then
                table.insert(result, _parse_ufw_output_line(line))
            end
        end
        callback(result, is_active(stdout))
    end)
end

--- Add a given rule to the firewall (Will ask for permissions)
-- @tparam rule table The given rule
-- @tparam rule.direction string @see direction - Either "IN" or "OUT" for incoming traffic or outgoing trafic
-- @tparam rule.state string @see state  - Either "ALLOW" or "DENY" to allow a connection or block one
-- @tparam[opt] rule.default bool If this is a default firewall rule that applies if no other rule matches
-- @tparam[opt] rule.ip string The ip adress or range of addresses to use in the given rule
-- @tparam[opt] rule.port number|string The port or range of ports to use in the given rule
-- @tparam[opt] function callback A callback function to trigger after finishing execution
-- @staticfct add_rule
-- @usage -- Add a rule to allow ssh to this machine
-- lib-tde.firewall.add_rule({direction = firewall.direction.IN, state = firewall.state.ALLOW, port=22})
local function add_rule(rule, callback)
    if type(rule) ~= "table" then
        return
    end
    -- set default values
    rule = _populate(rule)

    if rule.default then
        return __add_default_rule(rule)
    end

    local _rule = _gen_cmd(rule)

    if _rule == "" then
        if callback then
            callback()
        end
        return
    end

    local cmd = "pkexec ufw " .. _rule
    print(cmd)
    awful.spawn.easy_async(cmd, function ()
        if callback then
            callback()
        end
    end)
end

--- Remove a given rule from the firewall (Will ask for permissions)
-- @tparam rule table The given rule
-- @tparam rule.direction string @see direction - Either "IN" or "OUT" for incoming traffic or outgoing trafic
-- @tparam rule.state string @see state  - Either "ALLOW" or "DENY" to allow a connection or block one
-- @tparam[opt] rule.default bool If this is a default firewall rule that applies if no other rule matches
-- @tparam[opt] rule.ip string The ip adress or range of addresses to use in the given rule
-- @tparam[opt] rule.port number|string The port or range of ports to use in the given rule
-- @tparam[opt] function callback A callback function to trigger after finishing execution
-- @staticfct remove_rule
-- @usage -- Remove a rule to allow ssh to this machine
-- lib-tde.firewall.remove_rule({direction = firewall.direction.IN, state = firewall.state.ALLOW, port=22})
local function remove_rule(rule, callback)
    rule = _populate(rule)
    local _cmd = _gen_cmd(rule)
    if _cmd == "" then
        callback()
        return
    end
    local cmd = "pkexec ufw delete " .. _cmd
    print(cmd)
    awful.spawn.easy_async(cmd, function ()
        if callback then
            callback()
        end
    end)
end

return {
    -- enums
    direction = direction,
    state = state,
    -- functions
    is_installed = is_installed,
    set_active = set_active,
    get_rules = get_rules,
    add_rule = add_rule,
    remove_rule = remove_rule
}