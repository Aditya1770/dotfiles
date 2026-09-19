#!/bin/sh

# Make Qt platform menus follow the current GTK3 theme and force Papirus-Dark
# for freedesktop icon-name lookups.
export QT_QPA_PLATFORMTHEME=gtk3
export QS_ICON_THEME=Papirus-Dark

# Ensure pkexec requests appear graphically in a bare Hyprland session.
if ! pgrep -f 'polkit.*authentication-agent\|hyprpolkitagent' >/dev/null 2>&1; then
    for agent in \
        /usr/lib/hyprpolkitagent/hyprpolkitagent \
        /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
        /usr/lib/polkit-kde-authentication-agent-1
    do
        if [ -x "$agent" ]; then
            "$agent" >/dev/null 2>&1 &
            break
        fi
    done
fi

# Preserve data created by releases that used the old shell name.
data_root="${XDG_DATA_HOME:-$HOME/.local/share}"
if [ -d "$data_root/aditya-shell" ] && [ ! -e "$data_root/fianchetto" ]; then
    cp -a "$data_root/aditya-shell" "$data_root/fianchetto"
fi
mkdir -p "$data_root/fianchetto"

# Kill an older instance of this shell. Its executable is named `qs`, so
# `pkill quickshell` does not release the notification D-Bus service.
pkill -x qs 2>/dev/null || true
attempt=0
while pgrep -x qs >/dev/null 2>&1 && [ "$attempt" -lt 20 ]; do
    sleep 0.05
    attempt=$((attempt + 1))
done

# Fianchetto owns org.freedesktop.Notifications. Stop competing notification
# daemons before startup so its original notification manager can claim D-Bus.
systemctl --user stop swaync.service mako.service dunst.service 2>/dev/null || true
for daemon in swaync mako dunst; do
    pkill -x "$daemon" 2>/dev/null || true
done

attempt=0
while busctl --user --list 2>/dev/null | grep -q '^org.freedesktop.Notifications[[:space:]]' \
    && [ "$attempt" -lt 30 ]; do
    sleep 0.05
    attempt=$((attempt + 1))
done

exec qs -c fianchetto "$@"
