-- Hyprland Lua configuration migrated from hyprland.conf
-- Refer to https://wiki.hypr.land/Configuring/Start/ for more information

local mocha = require("themes.catppuccin-mocha")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Keywords/
local terminal    = "kitty"
local fileManager = "thunar"
local lockScreen  = "hyprlock"
local menu        = "fuzzel"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function ()
    -- hl.exec_cmd(terminal)
    hl.exec_cmd("nm-applet & dunst")
    hl.exec_cmd("systemctl --user start plasma-polkit-agent")
    hl.exec_cmd("waybar & hyprpaper")
    hl.exec_cmd("hyprswitch init &")
    hl.exec_cmd("clipcatd &")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 5,

        border_size = 2,

        col = {
            active_border   = { colors = { mocha.mauve, mocha.lavender }, angle = 45 },
            inactive_border = mocha.surface0,
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
    dwindle = {
        preserve_split = true,
    },

    binds = {
        allow_workspace_cycles = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },

    input = {
        kb_layout  = "us,de",
        kb_variant = "",
        kb_model   = "",
        kb_options = "caps:swapescape",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity   = -0.4, -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.3,
        },
    },
})


-- Remove gaps for workspaces with exactly one visible tiled window (smart gaps)
-- Disable borders and rounding for non-floating windows on such workspaces
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name        = "no-gaps-wtv1",
    match       = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})



---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for more
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds
hl.bind(mainMod .. " + RETURN",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + Q",    hl.dsp.exec_cmd("instantshutdown"))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + M",   hl.dsp.exit())
hl.bind(mainMod .. " + E",           hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + CTRL + L",    hl.dsp.exec_cmd(lockScreen))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE",       hl.dsp.exec_cmd("ins launch"))
hl.bind(mainMod .. " + CTRL + S",    hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mainMod .. " + A",           hl.dsp.exec_cmd("ins assist"))
hl.bind(mainMod .. " + P",           hl.dsp.window.pseudo())
hl.bind(mainMod .. " + W",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + Y",           hl.dsp.exec_cmd("instantmenu_smartrun"))
hl.bind(mainMod .. " + SHIFT + V",   hl.dsp.exec_cmd("clipcat-menu"))

-- TODO: wait till hyprswitch or equivalent is added to official repo
-- hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("hyprswitch gui --mod-key super --key tab"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Switch to adjacent workspaces with Ctrl+Super+Left/Right
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))

-- Switch between two most recently used workspaces
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Plugin example (e.g. hyprexpo)
-- hl.bind(mainMod .. " + g", hl.dsp.layout("hyprexpo:expo"), { action = "toggle" })
