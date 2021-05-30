----------------------------------------------------------------------------
--- A notification content message.
--
-- This widget is a specialized `wibox.widget.textbox` with the following extra
-- features:
--
-- * Honor the `beautiful` notification variables.
-- * React to the `naughty.notification` object message changes.
--
--@DOC_wibox_nwidget_message_simple_EXAMPLE@
--
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @copyright 2017 Emmanuel Lepage Vallee
-- @widgetmod naughty.widget.message
-- @see wibox.widget.textbox
----------------------------------------------------------------------------
local textbox = require("wibox.widget.textbox")
local gtable  = require("gears.table")
local beautiful = require("beautiful")
local markup  = require("naughty.widget._markup").set_markup

local message = {}

--- The attached notification.
-- @property notification
-- @tparam naughty.notification notification
-- @propemits true false

function message:set_notification(notif)
    if self._private.notification == notif then return end

    if self._private.notification then
        self._private.notification:disconnect_signal("property::message",
            self._private.message_changed_callback)
        self._private.notification:disconnect_signal("property::fg",
            self._private.message_changed_callback)
    end

    markup(self, notif.message, notif.fg, notif.font)

    self._private.notification = notif

    notif:connect_signal("property::message", self._private.message_changed_callback)
    notif:connect_signal("property::fg"     , self._private.message_changed_callback)
    self:emit_signal("property::notification", notif)
end

--- Create a new naughty.widget.message.
-- @tparam table args
-- @tparam naughty.notification args.notification The notification.
-- @constructorfct naughty.widget.message
-- @usebeautiful beautiful.notification_fg
-- @usebeautiful beautiful.notification_font

local function new(args)
    args = args or {}
    local tb = textbox()
    tb:set_wrap("word")
    tb:set_font(beautiful.notification_font)

    gtable.crush(tb, message, true)

    function tb._private.message_changed_callback()
        markup(
            tb,
            tb._private.notification.message,
            tb._private.notification.fg,
            tb._private.notification.font
        )
    end

    if args.notification then
        tb:set_notification(args.notification)
    end

    return tb
end

--@DOC_widget_COMMON@

--@DOC_object_COMMON@

return setmetatable(message, {__call = function(_, ...) return new(...) end})
