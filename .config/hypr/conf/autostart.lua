
hl.on("hyprland.start", function()

    -- Media daemon
    hl.exec_cmd("playerctld daemon")

    hl.exec_cmd("~/.config/quickshell/fianchetto/start.sh")

    -- Wayland environment
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    )

    -- Clipboard manager
    hl.exec_cmd(
        "wl-paste --type text --watch cliphist store"
    )

    hl.exec_cmd(
        "wl-paste --type image --watch cliphist store"
    )

    -- Polkit agent
    hl.exec_cmd(
        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
    )

    -- Browser
    hl.exec_cmd("brave")

    -- Wallpaper daemon
    hl.exec_cmd("awww-daemon")

    -- GTK settings
    hl.exec_cmd("nwg-look -a")

end)
