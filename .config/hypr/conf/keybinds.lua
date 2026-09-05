local mainMod = "SUPER"
local browser = "brave"

-- Applications
hl.bind(mainMod .. " + Return",
    hl.dsp.exec_cmd("kitty"))

hl.bind(mainMod .. " + SHIFT + Return",
    hl.dsp.exec_cmd("[float] kitty"))

hl.bind(mainMod .. " + B",
    hl.dsp.exec_cmd(browser))

hl.bind(mainMod .. " + Q",
    hl.dsp.window.close())

hl.bind(mainMod .. " + SHIFT + Escape",
    hl.dsp.exit())

hl.bind(mainMod .. " + E",
    hl.dsp.exec_cmd("nemo"))

hl.bind(mainMod .. " + SHIFT + E",
    hl.dsp.exec_cmd("[float] nemo"))

hl.bind(mainMod .. " + Space",
    hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + D",
    hl.dsp.exec_cmd("qs -c fianchetto ipc call launcher toggle"))

hl.bind(mainMod .. " + P",
    hl.dsp.window.pseudo())

hl.bind(mainMod .. " + J",
    hl.dsp.layout("togglesplit"))


-- Focus movement

hl.bind(mainMod .. " + left",
    hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + right",
    hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + up",
    hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + down",
    hl.dsp.focus({ direction = "down" }))


-- Workspaces

for i = 1, 10 do
    local key = i % 10

    hl.bind(mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i }))

    hl.bind(mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i }))
end


-- Swap windows

hl.bind("SUPER + SHIFT + left",
    hl.dsp.window.move({ direction = "left" }))

hl.bind("SUPER + SHIFT + right",
    hl.dsp.window.move({ direction = "right" }))

hl.bind("SUPER + SHIFT + up",
    hl.dsp.window.move({ direction = "up" }))

hl.bind("SUPER + SHIFT + down",
    hl.dsp.window.move({ direction = "down" }))


-- Workspace scrolling

hl.bind(mainMod .. " + mouse_down",
    hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + mouse_up",
    hl.dsp.focus({ workspace = "e-1" }))


-- Mouse move / resize

hl.bind(mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true })

hl.bind(mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true })


-- Volume

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("qs -c fianchetto ipc call osd volumeUp")
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("qs -c fianchetto ipc call osd volumeDown")
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("qs -c fianchetto ipc call osd volumeMute")
)

hl.bind("XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"))

hl.bind("XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"))

hl.bind("XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"))

hl.bind("XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"))


-- Screenshots

hl.bind("Print",
    hl.dsp.exec_cmd("grimblast copy area"))

hl.bind(mainMod .. " + Print",
    hl.dsp.exec_cmd("grimblast copy"))


-- Brightness

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("qs -c fianchetto ipc call osd brightnessUp")
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("qs -c fianchetto ipc call osd brightnessDown")
)

-- Clipboard

hl.bind("SUPER + V",
    hl.dsp.exec_cmd(
        "qs -c fianchetto ipc call picker clipboard"
    ))


-- Misc

hl.bind("SUPER + L",
    hl.dsp.exec_cmd("[float] /home/aditya/scripts/powermenu.sh"))

hl.bind("SUPER + F",
    hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + SHIFT + C",
    hl.dsp.exec_cmd("hyprpicker | wl-copy"))

hl.bind(mainMod .. " + SHIFT + N",
    hl.dsp.exec_cmd("swaync-client -t -sw"))

hl.bind(mainMod .. " + C",
    hl.dsp.window.center())


-- Scripts

hl.bind(mainMod .. " + SHIFT + R",
    hl.dsp.exec_cmd("sh /home/aditya/scripts/waybar"))

hl.bind(mainMod .. " + SHIFT + M",
    hl.dsp.exec_cmd("sh /home/aditya/scripts/mouse"))

hl.bind(mainMod .. " + period",
    hl.dsp.exec_cmd("qs -c fianchetto ipc call picker emoji"))

hl.bind("SUPER + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    local function resize(keys, x, y)
        hl.bind(keys, hl.dsp.window.resize({
            x = x,
            y = y,
            relative = true,
        }), { repeating = true })
    end

    -- Straight directions
    resize("left",  -40,    0)
    resize("right",  40,    0)
    resize("up",      0,  -40)
    resize("down",    0,   20)

    -- Diagonals
    resize("up + left",     40,  40)
    resize("up + right",   -40,  40)
    resize("down + left",   40, -40)
    resize("down + right", -40, -40)

    -- Since keysym order matters, handle reverse order too
    resize("left + up",     -40, -40)
    resize("right + up",     40, -40)
    resize("left + down",   -40,  40)
    resize("right + down",   40,  40)

    hl.bind("escape", hl.dsp.submap("reset"))
end)
