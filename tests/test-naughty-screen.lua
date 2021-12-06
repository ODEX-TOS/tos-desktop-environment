--- This test suite focuses on the AwesomeWM v4.4+ notification API and
-- specifically how the `naughty.layout.box` popup widgets handle multi-screen
-- scenario.
local steps = {}

local naughty = require("naughty")
local grect   = require("gears.geometry").rectangle
local rnotif  = require("ruled.notification")

-- Do not use whatever `rc.lua` has. This avoids having to update the test
-- every time.

naughty._reset_display_handlers()

local called = 0

naughty.connect_signal("request::display", function(n)
    called = called + 1
    n._private._box_wibox = naughty.layout.box { notification = n }
end)

local positions = {
    "top_left"    , "top_middle"    , "top_right"     ,
    "bottom_left" , "bottom_middle" , "bottom_right"  ,
}

local objs = {}

local s1, s2 = mouse.screen, nil

for _, p in ipairs(positions) do
    objs[p] = setmetatable({},{
        __index = function(t,k)
            t[k] = setmetatable({}, {__mode = "kv"})
            return t[k]
        end,
        __mode = "k"
    })
end

local function cleanup(n)
    -- Wait until there is no notifications left.
    for _, pos in ipairs(positions) do
        for s, notifs in pairs(objs[pos]) do
            for k, n2 in ipairs(notifs) do
                if n == n2 then
                    table.remove(notifs, k)
                    if #notifs == 0 then
                        objs[pos][s] = nil
                    end
                    return
                end
            end
        end
    end
end

naughty.connect_signal("property::screen", cleanup)
naughty.connect_signal("destroyed", cleanup)

local function add_many(s)
    for _, pos in ipairs(positions) do
        for i=1, 5 do
            table.insert(objs[pos][s], naughty.notification {
                message  = pos..i,
                position = pos,
                screen   = s,
            })
        end
    end
end

local function remove_at(s, idx)
    -- This will be validated with many asserts in the code.
    for _, pos in ipairs(positions) do
        local n = table.remove(objs[pos][s], idx)
        assert(n)

        n:destroy()
        assert(n._private.is_destroyed)
    end
end

local function check_screen(s)
    for _, pos in ipairs(positions) do
        for _, n in pairs(objs[pos][s]) do
            assert(n.screen == s)
            assert(n._private._box_wibox)
            assert(grect.is_inside(
                n._private._box_wibox:geometry(),
                s.geometry
            ))
        end
    end
end

for _, legacy_preset in ipairs {true, false} do

    -- Create notifications in each position.
    table.insert(steps, function()
        function naughty.get__has_preset_handler()
            return legacy_preset
        end

        rnotif._clear()
        add_many(s1)

        return true
    end)

    -- Make sure removing notification works.
    table.insert(steps, function()

        remove_at(s1, 2)

        -- Split the screen
        s1:split()

        s2 = screen[2]
        assert(s1 ~= s2)

        return true
    end)

    -- Make sure the notification moved as the screen shrunk.
    table.insert(steps, function()
        check_screen(s1)

        -- Make sure we can still remove them without errors.
        remove_at(s1, 2)

        -- Add more!
        add_many(s2)

        -- Make sure none got moved to the wrong position due to a fallback code
        -- path triggered by accident. The first few iteration were prone to this.
        check_screen(s1)
        check_screen(s2)

        return true
    end)

    -- Remove everything and see what happens.
    table.insert(steps, function()

        for _=1, 3 do
            for _, s in ipairs {s1,s2} do
                remove_at(s, 1)
            end
        end

        for _=1, 2 do
            remove_at(s2, 1)
        end

        -- And add them again.
        add_many(s1)
        add_many(s2)

        return true
    end)

    local weak = nil

    -- Delete a screen and make sure it gets GCed.
    table.insert(steps, function()
        s2:fake_remove()

        return true
    end)

    -- Check if notifications are moved.
    table.insert(steps, function()
        -- Wait until there is no notifications left.
        for _, pos in ipairs(positions) do
            if #objs[pos][s2] > 0 then
                collectgarbage("collect")
                return
            end
        end

        -- Drop our string reference to s2.
        weak, s2 = setmetatable({s2}, {__mode="v"}), nil

        return true
    end)


    table.insert(steps, function()
        if weak[1] == nil then return true end

        for _=1, 10 do
            collectgarbage("collect")
        end
    end)

end

require("_runner").run_steps(steps)
