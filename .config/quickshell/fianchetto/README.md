# Quickshell bar — Phase 1

A minimal modular Hyprland shell modeled after the supplied references. It includes clickable workspace indicators, a centered Spotlight-style launcher, Spotify controls, unified quick settings, battery, calendar, tray, and a native notification server.

Quick settings includes native Wi-Fi and Bluetooth lists with manual scanning, connected SSID/device names, combined sound and brightness faders, an expandable Hyprsunset night-light control, and live CPU, RAM, and root-disk usage. The Spotify-only player has rounded asynchronous artwork and a seekable waveform that updates once per second only while its popup is open.

The clock popup combines 24-hour time, current weather, upcoming events, and the month calendar. Select a date and type into the event field to add an event; click an event's close icon to remove it. Events persist in `~/.local/share/fianchetto/events.tsv`. Fixed-date Indian national days and common international observances are supplied automatically by `HolidayService.qml`. Edit `UserConfig.qml` to change the weather location.

Notifications appear as animated top-right cards, expose application-provided action buttons, and remain available from the Notifications page in quick settings. DND suppresses popup cards while continuing to collect notifications. `start.sh` stops SwayNC so only one notification server owns the D-Bus interface; also remove the `swaync` autostart line from Hyprland.

The horizontal Material You OSD can be driven instantly from media-key bindings with `qs -c fianchetto ipc call osd volumeUp`, `volumeDown`, `volumeMute`, `brightnessUp`, or `brightnessDown`.

The centered Clipboard/Emoji picker uses cliphist, renders stored image thumbnails, and restores text or binary image entries through wl-copy. Open it with `qs -c fianchetto ipc call picker clipboard` or open the emoji tab with `qs -c fianchetto ipc call picker emoji`.

Keep `wl-paste --watch cliphist store` running from Hyprland. Pinned text and image entries are protected under `~/.local/share/fianchetto/pinned-clipboard`, survive Clear All, and can be unpinned by clicking the blue pin again.

Edit `Typography.qml` to change the text font, icon font, or their global sizes.

Start the shell through `start.sh` to make Qt platform menus follow your GTK3 theme and force Papirus-Dark icon-name lookup:

```bash
~/.config/quickshell/fianchetto/start.sh
```

## Install

Arch packages used by this phase:

```bash
sudo pacman -S quickshell upower networkmanager wireplumber brightnessctl hyprsunset papirus-icon-theme wl-clipboard cliphist curl
```

Copy the folder into Quickshell's config directory:

```bash
mkdir -p ~/.config/quickshell
cp -r fianchetto ~/.config/quickshell/fianchetto
qs -c fianchetto
```

Autostart it from Hyprland after removing the Waybar autostart line:

```lua
-- use the equivalent exec-once call in your hyprland.lua setup
exec_once("qs -c fianchetto")
```

Bind the launcher in current Lua-based Hyprland:

```lua
hl.bind("SUPER + D", hl.dsp.exec_cmd("qs -c fianchetto ipc call launcher toggle"))
```

Test the IPC command directly with `qs -c fianchetto ipc call launcher toggle`.

## Customize

All visual values are in `Theme.qml`. Typography is configured in `Typography.qml`; icons use `Symbols Nerd Font Mono`.

## Controls

- Workspace dot: switch workspace; filled means occupied, outlined means empty
- Scroll workspace pill: previous/next workspace
- Click Spotify: open player controls
- Right-click/two-finger tap Spotify: toggle play or pause immediately
- Click the grouped volume/Wi-Fi/Bluetooth pill to open quick settings
- Open Notifications from quick settings to view the stack, dismiss cards, clear all, or toggle DND
- Quick settings contains Wi-Fi and Bluetooth toggles, network/device pages, volume, and brightness
- Click clock: open time, weather, events, and calendar
- Click launcher icon or press `SUPER+D`: toggle the centered launcher
- Type arithmetic such as `(120 + 30) / 5`: Enter copies the result
- Only one module popup remains open at a time; clicking elsewhere dismisses it
- Tray left/middle/right click: activate/secondary action/menu
- Power icon: open the anchored 2×2 Logout, Sleep, Reboot, and Power Off menu

## Notes

- The launcher searches desktop-entry names, generic names, comments, and keywords.
- The launcher exposes the full result list; use the wheel or Up/Down to scroll it.
