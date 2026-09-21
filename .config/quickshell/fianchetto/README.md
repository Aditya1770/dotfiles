# Quickshell

Fianchetto is my Quickshell configuration for Hyprland. It provides the bar, application launcher, Control Center, notifications, OSDs, calendar, media controls, clipboard manager, emoji picker, and settings app.

## Requirements

Install the required packages on Arch Linux:

```bash
sudo pacman -S quickshell upower networkmanager bluez-utils pipewire wireplumber \
  brightnessctl hyprsunset papirus-icon-theme wl-clipboard cliphist \
  curl python kitty ttf-nerd-fonts-symbols-mono
```

The screenshot shortcut uses `grimblast`. Importing theme files requires either `zenity` or `kdialog`. Performance-mode controls are only available on supported Acer Predator laptops with Linuwu-Sense.

Make sure NetworkManager, Bluetooth, PipeWire, and WirePlumber are running. Fianchetto provides its own notification server, so disable other notification daemons such as SwayNC, Mako, or Dunst.

## Installation

Clone the dotfiles and copy the shell:

```bash
git clone https://github.com/Aditya1770/dotfiles.git
mkdir -p ~/.config/quickshell
cp -r dotfiles/.config/quickshell/fianchetto ~/.config/quickshell/
chmod +x ~/.config/quickshell/fianchetto/start.sh
chmod +x ~/.config/quickshell/fianchetto/scripts/*.sh
```

Start it with:

```bash
~/.config/quickshell/fianchetto/start.sh
```

## Hyprland

Autostart Fianchetto from `hyprland.conf`:

```ini
exec-once = ~/.config/quickshell/fianchetto/start.sh
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
```

Remove old Waybar, SwayNC, SwayOSD, and launcher autostart entries when Fianchetto replaces them.

Useful bindings:

```ini
bind = SUPER, D, exec, qs -c fianchetto ipc call launcher toggle
bind = SUPER, V, exec, qs -c fianchetto ipc call picker clipboard
bind = SUPER, PERIOD, exec, qs -c fianchetto ipc call picker emoji
```

For a Lua-based Hyprland configuration, use the equivalent commands with your `exec_once` and binding helpers.

## Settings

Open Settings from Control Center. Settings cover appearance, fonts, themes, Control Center modules, bar layout, OSD and notification placement, Wi-Fi, Bluetooth, Night Light, and media animation.

Preferences are stored in:

```text
~/.local/share/fianchetto/settings.json
```

Custom theme JSON files placed in `themes/` are detected automatically. Importing a file through Settings requires `zenity` or `kdialog`.

The settings window uses the title `Fianchetto Settings` and Wayland class `org.quickshell`. A matching Hyprland rule can be used to float and centre it.

## Notes

- `SUPER + D` opens the launcher. Prefix a query with `>` to run it in Kitty.
- Fianchetto owns `org.freedesktop.Notifications` and stores notifications in Control Center.
- Weather location can be changed in `UserConfig.qml`.
- Calendar events are stored in `~/.local/share/fianchetto/events.tsv`.
- Pinned clipboard entries are stored in `~/.local/share/fianchetto/pinned-clipboard`.
