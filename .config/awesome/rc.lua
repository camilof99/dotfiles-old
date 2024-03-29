-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local net_speed_widget = require("awesome-wm-widgets.net-speed-widget.net-speed")
local logout_popup = require("awesome-wm-widgets.logout-popup-widget.logout-popup")
local net_widgets = require("net_widgets")

local xcolors = require("colors")
local colors = xcolors.get_current_theme()

local apps = require("apps")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

--beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "mytheme.lua")


modkey = "Mod4"
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
--myawesomemenu = {
--   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
--   { "manual", terminal .. " -e man awesome" },
--   { "edit config", editor_cmd .. " " .. awesome.conffile },
--   { "restart", awesome.restart },
--   { "quit", function() awesome.quit() end },
--}
--
--mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
--                                    { "open terminal", terminal }
--                                  }
--                        })

mylauncher = awful.widget.launcher({ image = gears.filesystem.get_configuration_dir() .. "icon-hulk2.png",  command = "rofi -show drun -show-icons" })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier,
        awful.layout.suit.corner.nw,
    })
end)
-- }}}

-- {{{ Wallpaper
--screen.connect_signal("request::wallpaper", function(s)
--    awful.wallpaper {
--       screen = s,
--        widget = {
--            {
--                image     = beautiful.wallpaper,
--                upscale   = true,
--                downscale = true,
--                widget    = wibox.widget.imagebox,
--            },
--           valign = "center",
--            halign = "center",
--            tiled  = false,
--            widget = wibox.container.tile,
--        }
--    }
--end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock()

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag({ "", "", "", "ﱘ", "", "", "", ""}, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        style    = {
            spacing = 4,
            shape        = function(cr,w,h)
                             gears.shape.rounded_rect(cr,w,h,4)
                            end,
        },
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        },
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,

        style    = {
            spacing = 5,
            shape        = function(cr,w,h)
                             gears.shape.rounded_rect(cr,w,h,5)
                            end,
        },

        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250, } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        },
    }

    mytaglistcontainer = wibox.container.margin (s.mytaglist, 4, 4, 3, 3)
    mylaunchercontainer = wibox.container.margin (mylauncher, 7, 2, 2, 2)
    mytasklistcontainer = wibox.container.margin (s.mytasklist, 4, 4, 4, 4)
    mylayoutboxcontainer = wibox.container.margin (s.mylayoutbox, 4, 4, 4, 4)

    net_wired = net_widgets.indicator({
        interfaces  = {"eno1", "another_interface", "and_another_one"},
        timeout     = 5
    })

    local container =
        wibox.widget {
        net_speed_widget(),
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        bg = colors.color4,
        fg = colors.color0,
        --fg = "#49B265",
        border_width = (2),
        border_color = '#1b1d2488',
        forced_width = 158
    }

    local container1 =
        wibox.widget {
        net_wired,
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        bg = colors.color4,
        border_width = (2),
        border_color = '#1b1d2488'
    }

    myvolumecontainer = wibox.container.margin (
        volume_widget{
        widget_type = 'arc',
        main_color = colors.color7,
    }, 6, 6, 4, 4)

    local container2 =
        wibox.widget {
        myvolumecontainer,
        forced_width = 35,
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        --bg = colors.color4,
        --border_width = (2),
        --border_color = '#1b1d2488'
    }

    local container3 =
        wibox.widget {
        mylayoutboxcontainer,
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        bg = colors.color4,
        border_width = (2),
        border_color = '#1b1d2488',
    }

    local container4 =
        wibox.widget {
        logout_popup.widget{},
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        bg = colors.color4,
        border_width = (2),
        border_color = '#1b1d2488',
    }

    local clock = wibox.widget({
        font = "HackNerdFont Bold 11",
        format = "%H:%M",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock,
    })

    local container5 =
        wibox.widget {
        clock,
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        bg = colors.color4,
        fg = colors.color0,
        border_width = (2),
        border_color = '#1b1d2488',
        forced_width = 60
    }

    local systray = wibox.widget.systray()
    systray:set_base_size(28)

    mylayoutcontainer1 = wibox.container.margin (container3, 0, 1.5, 1.5, 1.5)
    mylayoutcontainer2 = wibox.container.margin (container4, 0, 0, 1.5, 1.5)
    clockcontainer = wibox.container.margin (container5, 1.5, 0, 1.5, 1.5)
    myvolumecontainer1 = wibox.container.margin (container2, 0, 0, 1.5, 1.5)
    myspeedcontainer = wibox.container.margin (container, 1.5, 0, 1.5, 1.5)
    netcontainer = wibox.container.margin (container1, 1.5, 0, 1.5, 1.5)

    --#246326 #159947

    -- Create the wibox

    s.mywibox0 = awful.wibar {
        position = "top",
        screen   = screen[s],
        stretch  = false,
        width    = 40,
        bg = "#061A23",
        border_color = colors.color3,
        border_width = 1,
        height = 30,
        margins = {
            top = 12,
            left = 14,
        },
        align    = "left",
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylaunchercontainer
            },
            --s.mytasklist, -- Middle widget
            --mytaglistcontainer,
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal
            }
        },
    }

    s.mywibox1 = awful.wibar {
        position = "top",
        screen   = screen[s],
        stretch  = false,
        width    = 244,
        bg = "#061A23",
        border_color = colors.color3,
        border_width = 1,
        height = 30,
        margins = {
            top = -18,
            left = 66,
        },
        align    = "left",
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
            },
            --s.mytasklist, -- Middle widget
            mytaglistcontainer,
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal
            },
        },
    }

    s.mywibox2 = awful.wibar {
        position = "top",
        screen   = screen[s],
        stretch  = false,
        bg = "#061A23",
        border_color = colors.color3,
        border_width = 1,
        width    = 120,
        height = 30,
        margins = {
            top = -48,
            left = -598,
        },
        align    = "center",
        widget   = {
            align  = "center",
            widget = mytasklistcontainer
        },
    }

    s.mywibox3 = awful.wibar {
        position = "top",
        screen   = screen[s],
        stretch  = false,
        width    = 116,
        bg = "#061A23",
        border_color = colors.color3,
        border_width = 1,
        height = 30,
        margins = {
            top = -78,
            right = 14
        },
        align    = "right",
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                clockcontainer,
            },
            --s.mytasklist, -- Middle widget
            layout = wibox.layout.fixed.horizontal,
            mylayoutcontainer2,
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                mylayoutcontainer1,
            },
        }
    }

    s.mywibox4 = awful.wibar {
        position = "top",
        screen   = screen[s],
        stretch  = false,
        width    = 192,
        bg = "#061A23",
        border_color = colors.color3,
        border_width = 1,
        height = 30,
        margins = {
            top = -108,
            right = 142
        },
        align    = "right",
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                --netcontainer
            },
            --s.mytasklist, -- Middle widget
            --clock,
            layout = wibox.layout.fixed.horizontal,
            myspeedcontainer,
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                myvolumecontainer1
            }
        }
    }

    s.mywibox5 = awful.wibar {
        position = "top",
        screen   = screen[s],
        --visible = false,
        stretch  = false,
        width    = 100,
        bg = "#061A23",
        border_color = colors.color3,
        border_width = 1,
        height = 30,
        margins = {
            top = -138,
            right = 346
        },
        align    = "right",
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                --wibox.widget.systray()
                --myspeedcontainer
            },
            --s.mytasklist, -- Middle widget
            --clock,
            layout = wibox.layout.fixed.horizontal,
            systray,
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                -- customized
            }
        }
    }

end)
-- }}}

-- {{{ Mouse bindings
--awful.mouse.append_global_mousebindings({
--    awful.button({ }, 3, function () mymainmenu:toggle() end),
--    awful.button({ }, 4, awful.tag.viewprev),
--    awful.button({ }, 5, awful.tag.viewnext),
--})
-- }}}

-- {{{ Key bindings


-- General Awesome keys
awful.keyboard.append_global_keybindings({

    awful.key({ modkey, "Shift" }, "Up", function() volume_widget:inc(5) end),
    awful.key({ modkey, "Shift" }, "Down", function() volume_widget:dec(5) end),
    awful.key({ modkey }, "\\", function() volume_widget:toggle() end),

    awful.key({ modkey }, "o", function() logout_popup.launch() end, {description = "Show logout screen", group = "custom"}),

    awful.key({}, "Print",     function () awful.spawn("flameshot gui") end ),
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    --awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              --{description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

            awful.key({ modkey }, "Return", function ()
                awful.spawn(apps.default.terminal)
            end, {description = "open a terminal", group = "launcher"}),

            awful.key({ modkey }, "f", function()
                awful.spawn(apps.default.web_browser)
            end, { description = "open web browser", group = "launcher" }),

            awful.key({ modkey }, "v", function()
                awful.spawn(apps.default.code_editor)
            end, { description = "open code", group = "launcher" }),

            awful.key({ modkey }, "d", function()
                awful.spawn(apps.default.app_launcher)
            end, { description = "open rofi", group = "launcher" }),
            awful.key({ modkey, "Control" }, "p", function()
                awful.spawn.with_shell(apps.default.picom_kill)
            end, { description = "status picom", group = "launcher" }),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:activate { raise = true, context = "key.unminimize" }
                  end
              end,
              {description = "restore minimized", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
})


awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                {description = "move to screen", group = "client"}),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                {description = "toggle keep on top", group = "client"}),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    ruled.client.append_rule {
        rule_any    = {
            class = {apps.default.terminal}
        },
        properties = {
            tag = screen[1].tags[2],
        },
    }

end)

-- }}}

---- {{{ Titlebars
---- Add a titlebar if titlebars_enabled is set to true in the rules.
--client.connect_signal("request::titlebars", function(c)
--    -- buttons for the titlebar
--    local buttons = {
--        awful.button({ }, 1, function()
--            c:activate { context = "titlebar", action = "mouse_move"  }
--        end),
--        awful.button({ }, 3, function()
--            c:activate { context = "titlebar", action = "mouse_resize"}
--        end),
--    }
--
--    awful.titlebar(c).widget = {
--        { -- Left
--            awful.titlebar.widget.iconwidget(c),
--            buttons = buttons,
--            layout  = wibox.layout.fixed.horizontal
--        },
--        { -- Middle
--            { -- Title
--                align  = "center",
--                widget = awful.titlebar.widget.titlewidget(c)
--            },
--            buttons = buttons,
--            layout  = wibox.layout.flex.horizontal
--        },
--        { -- Right
--            awful.titlebar.widget.floatingbutton (c),
--            awful.titlebar.widget.maximizedbutton(c),
--            awful.titlebar.widget.stickybutton   (c),
--            awful.titlebar.widget.ontopbutton    (c),
--            awful.titlebar.widget.closebutton    (c),
--            layout = wibox.layout.fixed.horizontal()
--        },
--        layout = wibox.layout.align.horizontal
--    }
--end)

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)

-- Autostart Apps
awful.spawn.with_shell("~/.config/awesome/scripts/autostart.sh")
