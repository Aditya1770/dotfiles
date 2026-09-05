#!/bin/sh

# Make Qt platform menus follow the current GTK3 theme and force Papirus-Dark
# for freedesktop icon-name lookups.
export QT_QPA_PLATFORMTHEME=gtk3
export QS_ICON_THEME=Papirus-Dark

# Preserve data created by releases that used the old shell name.
data_root="${XDG_DATA_HOME:-$HOME/.local/share}"
if [ -d "$data_root/aditya-shell" ] && [ ! -e "$data_root/fianchetto" ]; then
    cp -a "$data_root/aditya-shell" "$data_root/fianchetto"
fi

# Kill an older instance of this shell. Its executable is named `qs`, so
# `pkill quickshell` does not release the notification D-Bus service.
pkill -x qs 2>/dev/null || true
attempt=0
while pgrep -x qs >/dev/null 2>&1 && [ "$attempt" -lt 20 ]; do
    sleep 0.05
    attempt=$((attempt + 1))
done

# This shell provides the org.freedesktop.Notifications server itself.
# SwayNC cannot own the same D-Bus service at the same time.
pkill -x swaync 2>/dev/null || true

exec qs -c fianchetto "$@"
