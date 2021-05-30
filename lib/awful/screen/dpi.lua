---------------------------------------------------------------------------
--                          DPI detection code.                          --
---------------------------------------------------------------------------

local capi    = {screen = screen}
local gtable  = require("gears.table")
local grect   = require("gears.geometry").rectangle
local gdebug  = require("gears.debug")

local module = {}

local ascreen, data = nil, nil

-- Metric to Imperial conversion constant.
local mm_per_inch = 25.4

local xft_dpi, fallback_dpi

local function get_fallback_dpi()
    -- Following Keith Packard's whitepaper on Xft,
    -- https://keithp.com/~keithp/talks/xtc2001/paper/xft.html#sec-editing
    -- the proper fallback for Xft.dpi is the vertical DPI reported by
    -- the X server. This will generally be 96 on Xorg, unless the user
    -- has configured it differently
    if not fallback_dpi then
        local _, h = root.size()
        local _, hmm = root.size_mm()
        fallback_dpi = hmm ~= 0 and h * mm_per_inch / hmm
    end

    return fallback_dpi or 96
end

local function dpi_for_output(viewport, output)
    local dpi = nil
    local geo = viewport.geometry

    -- Ignore outputs with width/height 0
    if output.mm_width ~= 0 and output.mm_height ~= 0 then
        local dpix = geo.width * mm_per_inch / output.mm_width
        local dpiy = geo.height * mm_per_inch / output.mm_height
        dpi = math.min(dpix, dpiy, dpi or dpix)
    elseif ascreen._get_xft_dpi() then
        dpi = ascreen._get_xft_dpi()
    end

    return dpi or get_fallback_dpi()
end

local function dpis_for_outputs(viewport)
    local max_dpi, min_dpi, max_size, min_size = 0, math.huge, 0, math.huge

    for _, o in pairs(viewport.outputs) do
        local dpi = dpi_for_output(viewport, o)
        o.dpi = dpi

        max_dpi = math.max(max_dpi, dpi)
        min_dpi = math.min(min_dpi, dpi)

        -- Compute the diagonal size.
        if o.mm_width and o.mm_height then
            o.mm_size   = math.sqrt(o.mm_width^2 + o.mm_height^2)
            o.inch_size = o.mm_size/mm_per_inch
            max_size    = math.max(max_size, o.mm_size)
            min_size    = math.min(min_size, o.mm_size)
        end
    end

    -- When there is no output.
    if min_dpi == math.huge then
        min_dpi = get_fallback_dpi()
        max_dpi = min_dpi
    end

    --TODO Some output may have a lower resolution than the viewport, so their
    -- DPI is currently wrong. Once fixed, the preferred DPI can become
    -- different from the minimum one.
    local pref_dpi = min_dpi

    viewport.minimum_dpi   = min_dpi
    viewport.maximum_dpi   = max_dpi
    viewport.preferred_dpi = pref_dpi

    -- Guess the diagonal size using the DPI.
    if min_size == math.huge then
        for _, o in pairs(viewport.outputs) do
            local geo = o.geometry
            if geo then
                o.mm_size = math.sqrt(geo.width^2 + geo.height^2)/o.dpi
                max_size  = math.max(max_size, o.mm_size)
                min_size  = math.min(min_size, o.mm_size)
            end
        end

        -- In case there is no output information.
        if min_size == math.huge then
            local geo  = viewport.geometry
            local size = math.sqrt(geo.width^2 + geo.height^2)/max_dpi

            max_size, min_size = size, size
        end
    end

    viewport.mm_minimum_size   = min_size
    viewport.mm_maximum_size   = max_size
    viewport.inch_minimum_size = min_size/mm_per_inch
    viewport.inch_maximum_size = max_size/mm_per_inch

    return max_dpi, min_dpi, pref_dpi
end

local function update_outputs(old_viewport, new_viewport)
    gtable.diff_merge(
        old_viewport.outputs,
        new_viewport.outputs,
        function(o)
            return o.name or (
                (o.mm_height or -7)*9999 * (o.mm_width or 5)*123
            )
        end,
        gtable.crush
    )
end

-- Fetch the current viewports and compare them to the caches ones.
--
-- The idea is to keep whatever metadata kept within the existing ones and know
-- what is added and removed.
local function update_viewports(force)
    if #ascreen._viewports > 0 and not force then return ascreen._viewports end

    local new = ascreen._get_viewports()

    local _, add, rem = gtable.diff_merge(
        ascreen._viewports,
        new,
        function(a) return a.id end,
        update_outputs
    )

    for _, viewport in ipairs(ascreen._viewports) do
        dpis_for_outputs(viewport)
    end

    assert(#ascreen._viewports > 0 or #new == 0)

    return ascreen._viewports, add, rem
end

-- Compute more useful viewport metadata frrom_sparse(add)om the list of output.
-- @treturn table An viewport with more information.
local function update_screen_viewport(s)
    local viewport = s._private.viewport

    if #ascreen._viewports == 0 then
        ascreen._viewports = update_viewports(false)
    end

    -- The maximum is equal to the screen viewport, so no need for many loops.
    if not viewport then
        local big_a, i_size = nil, 0

        for _, a in ipairs(ascreen._viewports) do
            local int = grect.get_intersection(a.geometry, s.geometry)

            if int.width*int.height > i_size then
                big_a, i_size = a, int.width*int.height
            end

            if i_size == s.geometry.width*s.geometry.height then break end
        end

        if big_a then
            viewport, s._private.viewport = big_a, big_a
        end
    end

    if not viewport then
        gdebug.print_warning("Screen "..tostring(s)..
            " doesn't overlap a known physical monitor")
    end
end

function module.create_screen_handler(viewport)
    local geo = viewport.geometry

    local s = capi.screen.fake_add(
        geo.x,
        geo.y,
        geo.width,
        geo.height,
        {_managed = true}
    )

    update_screen_viewport(s)

    s:emit_signal("request::desktop_decoration")
    s:emit_signal("request::wallpaper")

    -- Will call all `connect_for_each_screen`.
    s:emit_signal("added")
end

function module.remove_screen_handler(viewport)
    for s in capi.screen do
        if s._private.viewport and s._private.viewport.id == viewport.id then
            s:fake_remove()
            return
        end
    end
end

function module.resize_screen_handler(old_viewport, new_viewport)
    for s in capi.screen do
        if s._private.viewport and s._private.viewport.id == old_viewport.id then
            local ngeo = new_viewport.geometry
            s:fake_resize(
                ngeo.x, ngeo.y, ngeo.width, ngeo.height
            )
            s._private.viewport = new_viewport
            return
        end
    end
end

-- Xft.dpi is explicit user configuration, so honor it.
-- (It isn't a local function to allow the tests to replace it)
function module._get_xft_dpi()
    if not xft_dpi then
        xft_dpi = tonumber(awesome.xrdb_get_value("", "Xft.dpi")) or false
    end

    return xft_dpi
end

-- Some of them may be present twice or a giant viewport may exist which
-- encompasses everything.
local function deduplicate_viewports(vps)
    local min_x, min_y, max_x, max_y = math.huge, math.huge, 0, 0

    -- Sort the viewports by `x`.
    for _, vp in ipairs(vps) do
        local geo = vp.geometry
        min_x = math.min(min_x, geo.x)
        max_x = math.max(max_x, geo.x+geo.width)
        min_y = math.min(min_y, geo.y)
        max_y = math.max(max_y, geo.y+geo.height)
    end

    -- Remove the "encompass everything" viewport (if any).
    if #vps > 1 then
        for k, vp in ipairs(vps) do
            local geo = vp.geometry
            if geo.x == min_x and geo.y == min_y
            and geo.x+geo.width == max_x and geo.y+geo.height == max_y then
                table.remove(vps, k)
                break
            end
        end
    end

    --TODO when the rules are added, mark the viewports that are embedded into
    -- each other so the rules can decide to use the smaller or larger viewport
    -- when creating the screen. This happens a lot then connecting to
    -- projectors when doing presentations.

    return vps
end

-- Provide a way for the tests to replace `capi.screen._viewports`.
function module._get_viewports()
    assert(type(capi.screen._viewports()) == "table")
    return deduplicate_viewports(capi.screen._viewports())
end

local function get_dpi(s)
    if s._private.dpi or s._private.dpi_cache then
        return s._private.dpi or s._private.dpi_cache
    end

    if not s._private.viewport then
        update_screen_viewport(s)
    end

    -- Pick a DPI (from best to worst).
    local dpi = ascreen._get_xft_dpi()
        or (s._private.viewport and s._private.viewport.preferred_dpi or nil)
        or get_fallback_dpi()

    -- Pick the screen DPI depending on the `autodpi` settings.
    -- Historically, AwesomeWM size unit was the pixel. This assumption is
    -- present in a lot, if not most, user config and is why this cannot be
    -- enable by default for existing users.
    s._private.dpi_cache = data.autodpi and dpi
        or ascreen._get_xft_dpi()
        or get_fallback_dpi()

    return s._private.dpi_cache
end

local function set_dpi(s, dpi)
    s._private.dpi = dpi
end

screen.connect_signal("request::create", module.create_screen_handler)
screen.connect_signal("request::remove", module.remove_screen_handler)
screen.connect_signal("request::resize", module.resize_screen_handler)

-- Create some screens when none exist. This can happen when AwesomeWM is
-- started with `--screen manual` and no handler is used.
capi.screen.connect_signal("scanned", function()
    if capi.screen.count() == 0 then
        -- Private API to scan for screens now.
        if #ascreen._get_viewports() == 0 then
            capi.screen._scan_quiet()
        end

        local cur_viewports = ascreen._get_viewports()

        if #cur_viewports > 0 then
            for _, viewport in ipairs(cur_viewports) do
                module.create_screen_handler(viewport)
            end
        else
            capi.screen.fake_add(0, 0, 640, 480)
        end

        assert(capi.screen.count() > 0, "Creating screens failed")
    end
end)

-- This is the (undocumented) signal sent by capi.
capi.screen.connect_signal("property::_viewports", function(a)
    if capi.screen.automatic_factory then return end

    assert(#a > 0)

    local _, added, removed = update_viewports(true)

    local resized = {}

    -- Try to detect viewports being replaced or resized.
    for k2, viewport in ipairs(removed) do
        local candidate, best_size, best_idx = {}, 0, nil

        for k, viewport2 in ipairs(added) do
            local int = grect.get_intersection(viewport.geometry, viewport2.geometry)

            if (int.width*int.height) > best_size then
                best_size, best_idx, candidate = (int.width*int.height), k, viewport2
            end
        end

        if candidate and best_size > 0 then
            table.insert(resized, {removed[k2], added[best_idx]})
            removed[k2] = nil
            table.remove(added  , best_idx)
        end
    end

    gtable.from_sparse(removed)

    -- Drop the cache.
    for s in capi.screen do
        s._private.dpi_cache = nil
    end

    capi.screen.emit_signal("property::viewports", ascreen._get_viewports())

    -- First, ask for screens for these new viewport.
    for _, viewport in ipairs(added) do
        capi.screen.emit_signal("request::create", viewport, {context="viewports_changed"})
    end

    -- Before removing anything, make sure to resize existing screen as it may
    -- affect where clients will go when the screens are removed.
    for _, p in ipairs(resized) do
        capi.screen.emit_signal("request::resize", p[1], p[2], {context="viewports_changed"})
    end

    -- Remove the now out-of-view screens.
    for _, viewport in ipairs(removed) do
        capi.screen.emit_signal("request::remove", viewport, {context="viewports_changed"})
    end

end)

-- Add the DPI related properties
return function(screen, d)
    ascreen, data = screen, d

    -- "Lua" copy of the CAPI viewports. It has more metadata.
    ascreen._viewports = {}
    gtable.crush(ascreen, module, true)

    ascreen.object.set_dpi = set_dpi
    ascreen.object.get_dpi = get_dpi

    for _, prop in ipairs {"minimum_dpi"       , "maximum_dpi"       ,
                           "mm_maximum_width"  , "mm_minimum_width"  ,
                           "inch_maximum_width", "inch_minimum_width",
                           "preferred_dpi"                           } do

        screen.object["get_"..prop] = function(s)
            if not s._private.viewport then
                update_screen_viewport(s)
            end

            local a = s._private.viewport or {}

            return a[prop] or nil
        end
    end
end
