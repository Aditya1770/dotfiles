-- Nemo
hl.window_rule({
    name = "nemo-float",
    match = { class = "^(nemo)$" },
    float = true,
    size = "1038 609",
})


-- Feh
hl.window_rule({
    name = "feh-float",
    match = { class = "^(feh)$" },
    float = true,
    center = true,
})

-- FIle opener/selector
hl.window_rule({
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    center = true,
    size = "1040 644",
})


-- File roller
hl.window_rule({
    name = "file-roller-float",
    match = { class = "^(file-roller)$" },
    float = true,
    center = true,
})


-- Picture in Picture
hl.window_rule({
    name = "pip-float",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
})

hl.window_rule({
    name = "pip-pin",
    match = { title = "^(Picture-in-Picture)$" },
    pin = true,
})


-- GTK utilities
hl.window_rule({
    name = "nwg-look-float",
    match = { class = "^(nwg-look)$" },
    float = true,
})

hl.window_rule({
    name = "dconf-editor-float",
    match = { class = "^(dconf-editor)$" },
    float = true,
})


-- Center every window
-- hl.window_rule({
--     name = "center-windows",
--     match = { class = ".*" },
--     center = true,
-- })
--

-- Smart gaps
hl.workspace_rule({
    workspace = "w[tv1]",
    gaps_out = 0,
    gaps_in = 0,
})

hl.workspace_rule({
    workspace = "f[1]",
    gaps_out = 0,
    gaps_in = 0,
})




-- Brave
hl.window_rule({
    name = "brave-float",
    match = { class = "Brave-browser" },
    float = true,
    center = true,
    size = "1200 680",
})


-- Zen Browser
hl.window_rule({
    name = "zen-float",
    match = { class = "zen" },
    float = true,
    size = "1200 680",
})


-- Blueman
hl.window_rule({
    name = "blueman-float",
    match = { class = "blueman-manager" },
    float = true,
    size = "920 800",
})


-- File roller GNOME
hl.window_rule({
    name = "gnome-file-roller",
    match = { class = "org.gnome.FileRoller" },
    float = true,
})


-- Nemo terminal
hl.window_rule({
    name = "nemo-terminal",
    match = { class = "nemo_terminal" },
    float = true,
})


-- Image viewers
hl.window_rule({
    name = "loupe-float",
    match = { class = "org.gnome.Loupe" },
    float = true,
    size = "45% 49%",
})


hl.window_rule({
    name = "swayimg-float",
    match = { class = "swayimg" },
    float = true,
})


-- Rofi
hl.window_rule({
    name = "rofi-title",
    match = { title = "rofi" },
    float = true,
})


hl.window_rule({
    name = "rofi-float",
    match = { class = "Rofi" },
    float = true,
    pin = true,
})


-- Waydroid
hl.window_rule({
    name = "waydroid-fullscreen",
    match = { class = "Waydroid" },
    fullscreen = true,
})
