-- Dependencies:
-- acpid, upower, acpi_listens

local naughty = require("naughty")

local icons = require("theme.icons")
local config = require("config")
local battery_function = require("lib-tde.function.battery")
local gears = require("gears")

-- Subscribe to power supply status changes with acpi_listen
local signals = require("lib-tde.signals")

gears.timer {
	timeout = config.battery_timeout,
	call_now = true,
	autostart = true,
	callback = function()
		local value = battery_function.getBatteryPercentage()
		if value then
			signals.emit_battery(value)
		end
	end
}
local emit_charger_info = function()
	signals.emit_battery_charging(battery_function.isBatteryCharging())
end

-- Run once to initialize widgets
emit_charger_info()

-- Battery notification module
-- Depends:
--    - acpi_call
--    - enabled acpid service

local charger_plugged = true
local battery_full_already_notified = true
local battery_low_already_notified = false
local battery_critical_already_notified = false

local last_notification

local function send_notification(title, text, icon, timeout, urgency)
	local args = {
		title = title,
		text = text,
		icon = icon,
		timeout = timeout,
		urgency = urgency,
		app_name = "Power Notification"
	}

	if last_notification and not last_notification.is_expired then
		last_notification.title = args.title
		last_notification.text = args.text
		last_notification.icon = args.icon
	else
		last_notification = naughty.notification(args)
	end

	last_notification = notification
end

-- Full / Low / Critical notifications
signals.connect_battery(
	function(battery)
		local text
		local icon
		local timeout
		if not charger_plugged then
			icon = icons.batt_discharging

			if battery < 6 and not battery_critical_already_notified then
				battery_critical_already_notified = true
				text = "Battery Critical!"
				timeout = 0
				urgency = "critical"
			elseif battery < 16 and not battery_low_already_notified then
				battery_low_already_notified = true
				text = "Battery is low!"
				timeout = 6
				urgency = "critical"
			end
		else
			icon = icons.batt_charging
			if battery ~= nil then
				if battery > 99 and not battery_full_already_notified then
					battery_full_already_notified = true
					text = "Battery Full!"
					timeout = 6
					urgency = "normal"
				end
			end
		end

		-- If text has been initialized, then we need to send a
		-- notification
		if text then
			send_notification("Battery status", text, icon, timeout, urgency)
		end
	end
)

-- Charger notifications
local charger_first_time = true
signals.connect_battery_charging(
	function(plugged)
		charger_plugged = plugged
		local text
		local icon
		-- TODO if charger is plugged and battery is full, then set
		-- battery_full_already_notified to true
		if plugged then
			battery_critical_already_notified = false
			battery_low_already_notified = false
			text = "Plugged"
			icon = icons.batt_charging
			urgency = "normal"
		else
			battery_full_already_notified = false
			text = "Unplugged"
			icon = icons.batt_discharging
			urgency = "normal"
		end

		-- Do not send a notification the first time (when AwesomeWM (re)starts)
		if charger_first_time then
			charger_first_time = false
		else
			send_notification("Charger Status", text, icon, 3, urgency)
		end
	end
)
