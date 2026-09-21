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

# Ask Quickshell to stop its instances first, then fall back to signals. A
# process left inside Qt's crash path may ignore TERM, so use KILL only after a
# short grace period.
qs kill >/dev/null 2>&1 || true
pkill -TERM -x qs 2>/dev/null || true
pkill -TERM -x quickshell 2>/dev/null || true
attempt=0
while { pgrep -x qs >/dev/null 2>&1 || pgrep -x quickshell >/dev/null 2>&1; } \
    && [ "$attempt" -lt 20 ]; do
    sleep 0.05
    attempt=$((attempt + 1))
done
pkill -KILL -x qs 2>/dev/null || true
pkill -KILL -x quickshell 2>/dev/null || true

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
