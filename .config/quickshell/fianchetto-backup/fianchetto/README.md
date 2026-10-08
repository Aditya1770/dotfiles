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

The volume OSD supports PipeWire output boost up to 150%. Above 100%, the OSD expands, marks the normal-volume boundary, and uses the theme's violet accent for a clear boost warning.

Preferences are stored in:

```text
~/.local/share/fianchetto/settings.json
```

Custom theme JSON files placed in `themes/` are detected automatically. Importing a file through Settings requires `zenity` or `kdialog`.

### Wallpaper colours with Matugen and skwd-wall

Install Matugen (`sudo pacman -S matugen`), then open **Settings → Appearance** and click **Install Matugen setup**. Select the **Matugen** colour scheme and, in skwd-wall, enable **Theme → Matugen command** and set **Theme → Colour source** to **Matugen**. Wallpaper changes then regenerate `~/.local/share/fianchetto/matugen.json`; Fianchetto watches that file and applies the new palette live.

The installer preserves an existing Matugen configuration, adds only the `templates.fianchetto` entry, and creates a backup before changing it. It can also be run directly:

```bash
~/.config/quickshell/fianchetto/scripts/install-matugen-theme.sh
```

For reliable skwd-wall integration, enable its external Matugen command and use:

```text
/home/USER/.config/quickshell/fianchetto/scripts/skwd-matugen.sh "%path%"
```

Replace `USER` with the account name. The bridge selects the first extracted source colour non-interactively and logs every invocation to `~/.local/state/fianchetto/skwd-matugen.log`.

### Application theme synchronization

The **Application themes** switches under Appearance can synchronize every selected palette—including imported JSON themes and Matugen—with Kitty, Fish, Hyprland, and Spicetify. Fish receives a generated `Fianchetto.theme`, selected through `fish_config`, so Fianchetto does not modify `config.fish` or delete existing themes. Spicetify uses the installed `FianchettoText` theme for every palette and adds a softly tinted `FianchettoDynamic` colour scheme for generated themes. The Neovim switch is Matugen-only: it writes `lua/config/fianchetto.lua` while Matugen is selected, and removes it when another scheme is selected so [Aditya1770/neovim-config](https://github.com/Aditya1770/neovim-config) returns to its regular Night theme and original overrides. Automatic updates are debounced; **Apply now** forces an application refresh.

For Kitty, add this line once to `~/.config/kitty/kitty.conf`:

```conf
include fianchetto-theme.conf
```

Fianchetto applies Hyprland colours live and also writes `~/.config/hypr/fianchetto-theme.conf`. Spicetify integration preserves a one-time backup beside the Text theme's `color.ini`.

The settings window uses the title `Fianchetto Settings` and Wayland class `org.quickshell`. A matching Hyprland rule can be used to float and centre it.

## Notes

- `SUPER + D` opens the launcher. It can order applications by most used or by name from Settings → Launcher. Prefix a query with `>` to run it in Kitty.
- Fianchetto owns `org.freedesktop.Notifications` and stores notifications in Control Center.
- Paired Bluetooth devices can opt into Auto-connect from their expanded device card. Fianchetto remembers the choice and retries quietly when the device becomes available.
- Weather location can be changed in `UserConfig.qml`.
- Calendar events are stored in `~/.local/share/fianchetto/events.tsv`.
- Pinned clipboard entries are stored in `~/.local/share/fianchetto/pinned-clipboard`.
