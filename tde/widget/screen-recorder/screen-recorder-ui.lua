local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local dpi = require("beautiful").xresources.apply_dpi

local clickable_container = require("widget.material.clickable-container")

local widget_icon_dir = "/etc/xdg/awesome/widget/screen-recorder/icons/"
local theme = require("theme.icons.dark-light")

local record_tbl = {}

-- Panel UI

screen_rec_toggle_imgbox =
	wibox.widget {
	image = theme(widget_icon_dir .. "start-recording-button" .. ".svg"),
	resize = true,
	widget = wibox.widget.imagebox
}

screen_rec_toggle_button =
	wibox.widget {
	{
		screen_rec_toggle_imgbox,
		margins = dpi(7),
		widget = wibox.container.margin
	},
	widget = clickable_container
}

screen_rec_countdown_txt =
	wibox.widget {
	id = "countdown_text",
	font = "SF Pro Text Bold 64",
	text = "4",
	align = "center",
	valign = "bottom",
	opacity = 0.0,
	widget = wibox.widget.textbox
}

screen_rec_main_imgbox =
	wibox.widget {
	image = theme(widget_icon_dir .. "recorder-off" .. ".svg"),
	resize = true,
	widget = wibox.widget.imagebox
}

screen_rec_main_button =
	wibox.widget {
	{
		{
			{
				screen_rec_main_imgbox,
				margins = dpi(24),
				widget = wibox.container.margin
			},
			widget = clickable_container
		},
		forced_width = dpi(200),
		forced_height = dpi(200),
		bg = beautiful.groups_bg,
		shape = gears.shape.circle,
		widget = wibox.container.background
	},
	margins = dpi(24),
	widget = wibox.container.margin
}

screen_rec_audio_imgbox =
	wibox.widget {
	image = theme(widget_icon_dir .. "audio" .. ".svg"),
	resize = true,
	widget = wibox.widget.imagebox
}

screen_rec_audio_button =
	wibox.widget {
	{
		nil,
		{
			{
				screen_rec_audio_imgbox,
				margins = dpi(16),
				widget = wibox.container.margin
			},
			widget = clickable_container
		},
		nil,
		expand = "none",
		layout = wibox.layout.align.vertical
	},
	forced_width = dpi(60),
	forced_height = dpi(60),
	bg = beautiful.groups_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background
}

screen_rec_close_imgbox =
	wibox.widget {
	image = theme(widget_icon_dir .. "close-screen" .. ".svg"),
	resize = true,
	widget = wibox.widget.imagebox
}

screen_rec_close_button =
	wibox.widget {
	{
		nil,
		{
			{
				screen_rec_close_imgbox,
				margins = dpi(16),
				widget = wibox.container.margin
			},
			widget = clickable_container
		},
		nil,
		expand = "none",
		layout = wibox.layout.align.horizontal
	},
	forced_width = dpi(60),
	forced_height = dpi(60),
	bg = beautiful.groups_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background
}

screen_rec_settings_imgbox =
	wibox.widget {
	image = theme(widget_icon_dir .. "settings" .. ".svg"),
	resize = true,
	widget = wibox.widget.imagebox
}

screen_rec_settings_button =
	wibox.widget {
	{
		nil,
		{
			{
				screen_rec_settings_imgbox,
				margins = dpi(16),
				widget = wibox.container.margin
			},
			widget = clickable_container
		},
		nil,
		expand = "none",
		layout = wibox.layout.align.vertical
	},
	forced_width = dpi(60),
	forced_height = dpi(60),
	bg = beautiful.groups_bg,
	shape = gears.shape.circle,
	widget = wibox.container.background
}

-- Settings UI

screen_rec_back_imgbox =
	wibox.widget {
	image = theme(widget_icon_dir .. "back" .. ".svg"),
	resize = true,
	widget = wibox.widget.imagebox
}

screen_rec_back_button =
	wibox.widget {
	{
		nil,
		{
			{
				screen_rec_back_imgbox,
				margins = dpi(16),
				widget = wibox.container.margin
			},
			widget = clickable_container
		},
		nil,
		expand = "none",
		layout = wibox.layout.align.vertical
	},
	forced_width = dpi(48),
	forced_height = dpi(48),
	bg = beautiful.groups_bg,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
	end,
	widget = wibox.container.background
}

local screen_rec_back_txt =
	wibox.widget {
	{
		text = "Back",
		font = "SF Pro Display Bold 16",
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox
	},
	margins = dpi(5),
	widget = wibox.container.margin
}

local screen_rec_res_txt =
	wibox.widget {
	{
		text = "Resolution",
		font = "SF Pro Display Bold 16",
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox
	},
	margins = dpi(5),
	widget = wibox.container.margin
}

screen_rec_res_txtbox =
	wibox.widget {
	{
		{
			{
				id = "res_tbox",
				markup = '<span foreground="#FFFFFF66">' .. "1920x1080" .. "</span>",
				font = "SF Pro Display Bold 16",
				align = "left",
				valign = "center",
				widget = wibox.widget.textbox
			},
			margins = dpi(5),
			widget = wibox.container.margin
		},
		widget = clickable_container
	},
	forced_width = dpi(60),
	forced_height = dpi(60),
	bg = beautiful.groups_bg,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
	end,
	widget = wibox.container.background
}

local screen_rec_fps_txt =
	wibox.widget {
	{
		text = "FPS",
		font = "SF Pro Display Bold 16",
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox
	},
	margins = dpi(5),
	widget = wibox.container.margin
}

screen_rec_fps_txtbox =
	wibox.widget {
	{
		{
			{
				id = "fps_tbox",
				markup = '<span foreground="#FFFFFF66">' .. "30" .. "</span>",
				font = "SF Pro Display Bold 16",
				align = "left",
				valign = "center",
				widget = wibox.widget.textbox
			},
			margins = dpi(5),
			widget = wibox.container.margin
		},
		widget = clickable_container
	},
	forced_width = dpi(60),
	forced_height = dpi(60),
	bg = beautiful.groups_bg,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
	end,
	widget = wibox.container.background
}

local screen_rec_offset_txt =
	wibox.widget {
	{
		text = "Offset",
		font = "SF Pro Display Bold 16",
		align = "left",
		valign = "center",
		widget = wibox.widget.textbox
	},
	margins = dpi(5),
	widget = wibox.container.margin
}

screen_rec_offset_txtbox =
	wibox.widget {
	{
		{
			{
				id = "offset_tbox",
				markup = '<span foreground="#FFFFFF66">' .. "0,0" .. "</span>",
				font = "SF Pro Display Bold 16",
				ellipsize = "start",
				align = "left",
				valign = "center",
				widget = wibox.widget.textbox
			},
			margins = dpi(5),
			widget = wibox.container.margin
		},
		widget = clickable_container
	},
	forced_width = dpi(60),
	forced_height = dpi(60),
	bg = beautiful.groups_bg,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
	end,
	widget = wibox.container.background
}

screen.connect_signal(
	"request::desktop_decoration",
	function(s)
		s.recorder_screen =
			wibox(
			{
				ontop = true,
				screen = s,
				type = "normal",
				height = s.geometry.height,
				width = s.geometry.width,
				x = s.geometry.x,
				y = s.geometry.y,
				bg = beautiful.background.hue_800,
				fg = beautiful.fg_normal
			}
		)

		s.recorder_screen:setup {
			layout = wibox.layout.stack,
			{
				id = "recorder_panel",
				visible = true,
				layout = wibox.layout.align.vertical,
				expand = "none",
				nil,
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					nil,
					{
						layout = wibox.layout.fixed.vertical,
						screen_rec_countdown_txt,
						{
							layout = wibox.layout.align.horizontal,
							screen_rec_settings_button,
							screen_rec_main_button,
							screen_rec_audio_button
						},
						screen_rec_close_button
					},
					nil
				},
				nil
			},
			{
				id = "recorder_settings",
				visible = false,
				layout = wibox.layout.align.vertical,
				expand = "none",
				nil,
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					nil,
					{
						layout = wibox.layout.fixed.vertical,
						forced_width = dpi(240),
						spacing = dpi(10),
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = dpi(10),
							screen_rec_back_button,
							screen_rec_back_txt
						},
						screen_rec_res_txt,
						screen_rec_res_txtbox,
						screen_rec_fps_txt,
						screen_rec_fps_txtbox,
						screen_rec_offset_txt,
						screen_rec_offset_txtbox
					},
					nil
				},
				nil
			}
		}
	end
)

-- Panel UIs

record_tbl.screen_rec_toggle_imgbox = screen_rec_toggle_imgbox
record_tbl.screen_rec_toggle_button = screen_rec_toggle_button
record_tbl.screen_rec_countdown_txt = screen_rec_countdown_txt
record_tbl.screen_rec_main_imgbox = screen_rec_main_imgbox
record_tbl.screen_rec_main_button = screen_rec_main_button
record_tbl.screen_rec_audio_imgbox = screen_rec_audio_imgbox
record_tbl.screen_rec_audio_button = screen_rec_audio_button
record_tbl.screen_rec_settings_button = screen_rec_settings_button
record_tbl.screen_rec_close_button = screen_rec_close_button

-- Settings UI
record_tbl.screen_rec_back_button = screen_rec_back_button
record_tbl.screen_rec_res_txtbox = screen_rec_res_txtbox
record_tbl.screen_rec_fps_txtbox = screen_rec_fps_txtbox
record_tbl.screen_rec_offset_txtbox = screen_rec_offset_txtbox

return record_tbl
