---------------------------------------------------------------------------
--- Keep track of the urgent clients.
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @submodule client
---------------------------------------------------------------------------

local urgent = {}

local capi =
{
    client = client,
}

local client
do
    client = setmetatable({}, {
        __index = function(_, k)
            client = require("awful.client")
            return client[k]
        end,
        __newindex = error -- Just to be sure in case anything ever does this
    })
end

local data = setmetatable({}, { __mode = 'k' })

--- Get the first client that got the urgent hint.
--
-- @function awful.urgent.get
-- @treturn client.object The first urgent client.
function urgent.get()
    if #data > 0 then
        return data[1]
    else
        -- fallback behaviour: iterate through clients and get the first urgent
        local clients = capi.client.get()
        for _, cl in pairs(clients) do
            if cl.urgent then
                return cl
            end
        end
    end
end

--- Jump to the client that received the urgent hint first.
--
-- @function awful.urgent.jumpto
-- @tparam bool|function merge If true then merge tags (select the client's
--   first tag additionally) when the client is not visible.
--   If it is a function, it will be called with the client as argument.
function urgent.jumpto(merge)
    local c = client.urgent.get()
    if c then
        c:jump_to(merge)
    end
end

--- Adds client to urgent stack.
--
-- @function awful.urgent.add
-- @tparam client c The client object.
-- @param prop The property which is updated.
-- @request client border active granted When a client becomes active and is no
--  longer urgent.
-- @request client border inactive granted When a client stop being active and
--  is no longer urgent.
-- @request client border urgent granted When a client stop becomes urgent.
function urgent.add(c, prop)
    assert(
        c.urgent ~= nil,
        "`awful.client.urgent.add()` takes a client as first parameter"
    )

    if prop == "urgent" and c.urgent then
        table.insert(data, c)
    end

    if c.urgent then
        c:emit_signal("request::border", "urgent", {})
    else
        c:emit_signal(
            "request::border",
            (c.active and "" or "in").."active",
            {}
        )
    end
end

--- Remove client from urgent stack.
--
-- @function awful.urgent.delete
-- @tparam client c The client object.
function urgent.delete(c)
    for k, cl in ipairs(data) do
        if c == cl then
            table.remove(data, k)
            break
        end
    end
end

capi.client.connect_signal("property::urgent", urgent.add)
capi.client.connect_signal("focus", urgent.delete)
capi.client.connect_signal("request::unmanage", urgent.delete)

return urgent

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
