originalPrint = print

print = function(str)
end

require("tde.rc")

local hasNotificationCenter = false
local panel = nil
for s in screen do
    if not (s.right_panel == nil) then
        hasNotificationCenter = true
        panel = s.right_panel
    end
end

assert(panel)

originalPrint("Notification center exists!")

local panelClosed = not panel.visible

originalPrint("Notification panel is closed? " .. tostring(panelClosed))

-- this should open the panel
panel:toggle()
local panelOpened = panel.visible
originalPrint("Notification panel is opened? " .. tostring(panelOpened))

panel:HideDashboard()
panel:toggle()
panel:HideDashboard()
local panelHideFunctionWorks = not panel.visible
originalPrint("Notification panel hide works? " .. tostring(panelHideFunctionWorks))

-- when suplying nothing it should return the default state
local notifications, widgets = panel:switch_mode()
-- check if we are in the notifications
local panelStartNotification = notifications.visible and not widgets.visible
notifications, widgets = panel:switch_mode("widgets_mode")
-- check if we are at the widget
local panelEndWidgets = not notifications.visible and widgets.visible

originalPrint("Notification panel starts with notification tab? " .. tostring(panelStartNotification))
originalPrint("Notification panel transition to widget tab? " .. tostring(panelEndWidgets))

panel:HideDashboard()
panel:toggle()
notifications, widgets = panel:switch_mode()
local rememberStateAfterCloseAndReopen = not notifications.visible and widgets.visible
originalPrint(
    "Notification panel remebers state after closing and reopening? " .. tostring(rememberStateAfterCloseAndReopen)
)

originalPrint(
    "IT-test-result:" ..
        tostring(
            hasNotificationCenter and panelClosed and panelOpened and panelHideFunctionWorks and panelStartNotification and
                panelEndWidgets and
                rememberStateAfterCloseAndReopen
        )
)
