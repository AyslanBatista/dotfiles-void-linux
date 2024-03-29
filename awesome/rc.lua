-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

------------------------------------------------
------------------ LIBRARIES -------------------
------------------------------------------------

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local lain = require("lain")
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local temperature = require('temperature')
local net_widgets = require("net_widgets")
local watch = require("awful.widget.watch")
local vicious = require("vicious")
require("vicious.helpers")
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

------------------------------------------------
------------------- ERRORS ---------------------
------------------------------------------------

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

------------------------------------------------
------------------- OPTIONS --------------------
------------------------------------------------

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "blue/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "cool-retro-term"
editor = os.getenv("EDITOR") or "code-oss"
editor_cmd = terminal .. " -e " .. editor
browser = "brave-browser-stable"
chrome = "google-chrome-stable"
fm = "nautilus"
vscode = "code-oss"
screenshot = "gnome-screenshot"
flame = "flameshot gui"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
  --  awful.layout.suit.max,
  --  awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}
-- }}}


------------------------------------------------
------------------- MENU -----------------------
------------------------------------------------

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()


------------------------------------------------
----------------- WIDGETS ----------------------
------------------------------------------------




--------- Texto--------
tbox_separator = wibox.widget.textbox (" | ")
tbox_CPU = wibox.widget.textbox (" CPU")
tbox_NET = wibox.widget.textbox (" NET")


--------- NET ----------
net_wired = net_widgets.indicator({
    interfaces  = {"enp2s0", "another_interface", "and_another_one"},
    timeout     = 5
})


-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

--------- Calendario--------
local cw = calendar_widget({
    theme = 'nord',
    placement = 'top_right',
    start_sunday = true,
    radius = 8,
-- with customized next/previous (see table above)
    previous_month_button = 1,
    next_month_button = 3,
})
mytextclock:connect_signal("button::press",
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
    end)

datewidget = wibox.widget.textbox()

vicious.register(datewidget,vicious.widgets.date, " %A %d %b, %R")





-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))
local show_volume_notification = function()
    local command = "sleep 0.09 ; pacmd list-sinks | grep -zo --color=never '* index:.*base volume' | grep -oaE '[0-9]+\\%' | awk -v RS= '{$1= $1}1'"
    awful.spawn.easy_async_with_shell(command, function(out) naughty.notify({ text = "Volume: " .. out, timeout = 1, replaces_id = -1}) end)
end

                                       

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

------------------------------------------------
--------------------- TAGS ---------------------
------------------------------------------------

    -- Each screen has its own tag table.
    awful.tag({ "", "", "" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.focused,
        }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, bg = beautiful.bg_normal .. "55" })

------------------------------------------------
------------- WIDGETS DO PAINEL ----------------
------------------------------------------------

    -- Add widgets to the wibox -- 
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
	    s.mylayoutbox,
            s.mytaglist,
	    tbox_separator,
            s.mypromptbox,
	    },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
	    tbox_CPU,
	    cpu_widget({
            width = 50,
            step_width = 2,
            step_spacing = 0,
            color = '#02d2f7'
        }),
        ram_widget(),
        temperature,
        tbox_NET,
        net_wired,
	    mytextclock,
	    wibox.widget.systray(),
            },
    }
end)
-- }}}

-- {{{ Mouse bindings
--root.buttons(gears.table.join(
--    awful.button({ }, 3, function () mymainmenu:toggle() end),
--    awful.button({ }, 4, awful.tag.viewnext),
--    awful.button({ }, 5, awful.tag.viewprev)
--))
-- }}}

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
        awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)


------------------------------------------------
----------------- KEYBINDINGS ------------------
------------------------------------------------

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),


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

 -------***** BARRA DE MENU *****-------
    awful.key({           }, "F10", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

 -------***** ACPI Audio Control *****-------
   awful.key({}, "XF86AudioPlay", function()
    awful.spawn.with_shell("playerctl play-pause", false)
  end),
  awful.key({}, "XF86AudioNext", function()
    awful.spawn.with_shell("playerctl next", false)
  end),
  awful.key({}, "XF86AudioPrev", function()
    awful.spawn.with_shell("playerctl previous", false)
  end),
  awful.key({}, "XF86AudioPrev", function()
    awful.spawn.with_shell("playerctl previous", false)
  end),

 -------***** Volume Keys *****-------
     awful.key({}, "XF86AudioLowerVolume", function ()
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
        show_volume_notification()
end),
awful.key({}, "XF86AudioRaiseVolume", function ()
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
        show_volume_notification()
end),
awful.key({}, "XF86AudioMute", function ()
        awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
        show_volume_notification()
end),

awful.key({modkey_alt, modkey }, "-", function ()
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
        show_volume_notification()
end),
awful.key({modkey_alt, modkey }, "=", function ()
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
        show_volume_notification()
end),

awful.key({modkey}, "d", function ()
        awful.spawn.with_shell("xdotool click --repeat 5 --delay 0 5") -- emulate scroll down
end),


    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Tab", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ "Mod1" }, "Tab", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "a",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
end
        end,
        {description = "go back", group = "client"}),

    ------------------------**** START PROGRAMS **** ---------------------------------------
    awful.key({           }, "F11", function () awful.spawn(alsamixer) end,
                {description = "open volume", group = "launcher"}), 
    awful.key({           }, "Print", function () awful.spawn(screenshot) end,
                {description = "print tela", group = "launcher"}), 
    awful.key({"Shift"   }, "Print", function () awful.spawn(flame) end,
                {description = "print tela e recorte", group = "launcher"}), 
    awful.key({ modkey,           }, "e", function () awful.spawn(vscode) end,
             {description = "open a vscode", group = "launcher"}),
    awful.key({ modkey,           }, "F2", function () awful.spawn(chrome) end,
             {description = "open a chrome", group = "launcher"}),       
    awful.key({ modkey,           }, "w", function () awful.spawn(browser) end,
              {description = "open a brave", group = "launcher"}),    
    awful.key({ modkey,           }, "q", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),	
    awful.key({ modkey,           }, "F1", function () awful.spawn(fm) end,
              {description = "open a nautilus", group = "launcher"}),	
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

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

    ------------------------**** SCRIPTS **** ---------------------------------------
    awful.key({         },   "F5",      function () awful.spawn("/home/ayslan/.config/Scripts/ram") end,
	          {description = "exec ram", group = "Personal launchers"}),
    awful.key({        },   "F6",      function () awful.spawn("/home/ayslan/.config/Scripts/cpu") end,
              {descrition = "exec cpu", group = "Personal launchers"}),
    awful.key({        },   "F7",      function () awful.spawn("/home/ayslan/.config/Scripts/time") end,
              {descrition = "exec time", group = "Personal launchers"}),
    awful.key({        },   "F12",      function () awful.spawn("/home/ayslan/.config/Scripts/power-menu.sh") end,
              {descrition = "exec menu", group = "Personal launchers"}),
    awful.key({ modkey,        },   "F3",      function () awful.spawn("/home/ayslan/.config/Scripts/rofi-files") end,
              {descrition = "exec file", group = "Personal launchers"}),
    awful.key({ modkey,        },   "F4",      function () awful.spawn("/home/ayslan/.config/Scripts/rofi-search") end,
              {descrition = "exec search", group = "Personal launchers"}),
    awful.key({ modkey,        },   "F8",      function () awful.spawn("/home/ayslan/.config/Scripts/Rofi-Playlist") end,
              {descrition = "exec search", group = "Personal launchers"}),
    awful.key({        },   "F8",      function () awful.spawn("/home/ayslan/.config/Scripts/Rofi-Playlist-RL") end,
              {descrition = "exec search", group = "Personal launchers"}),
    awful.key({        },   "F9",      function () awful.spawn("/home/ayslan/.config/Scripts/Rofi-Scripts") end,
              {descrition = "exec search", group = "Personal launchers"}),

 
          
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

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
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,"Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "Tab",      function (c) c:move_to_screen()               end,
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
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}


------------------------------------------------
-------------------- RULES ---------------------
------------------------------------------------

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 1,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-------------------------------------------------
-------------------- SIGNALS --------------------
-------------------------------------------------


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
-- client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )
--
--    awful.titlebar(c) : setup {
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
--       },
--        { -- Right
--            awful.titlebar.widget.floatingbutton (c),
--            awful.titlebar.widget.maximizedbutton(c),
--            awful.titlebar.widget.stickybutton   (c),
--            awful.titlebar.widget.ontopbutton    (c),
--            awful.titlebar.widget.closebutton    (c),
--            layout = wibox.layout.fixed.horizontal()
--        },
--        layout = wibox.layout.align.horizontal
--}
-- end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--
-------------------------------------------------
--------------------- GAPS ----------------------
-------------------------------------------------

beautiful.useless_gap = 4
beautiful.gap_single_client = false

------------------------------------------------
-------------------- START ---------------------
------------------------------------------------
--awful.spawn.with_shell('pulseaudio --kill')
awful.spawn.with_shell('pulseaudio --start')
awful.spawn.with_shell('start-pulseaudio-x11')
awful.spawn.with_shell('nitrogen --restore')
awful.spawn.with_shell('xset s off')
awful.spawn.with_shell('xset -dpms')
awful.spawn.with_shell('picom --experimental-backends')
awful.spawn.with_shell('numlockx on')
awful.spawn.with_shell('xrandr --output HDMI-0 --mode 1920x1080 --rate 120 --primary --output DVI-D-0 --mode 1920x1080 --rate 60 --right-of HDMI-0')