#!/bin/sh
# Bridge skwd-wall's wallpaper hook to Fianchetto's Matugen template.
# Keeping only the wallpaper placeholder avoids version-specific scheme/mode
# placeholder expansion and guarantees a non-interactive source colour.
set -u

wallpaper=${1:-}
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
config_file="$config_home/matugen/config.toml"
log_dir="$state_home/fianchetto"
log_file="$log_dir/skwd-matugen.log"

mkdir -p "$log_dir"

if [ -z "$wallpaper" ]; then
    printf '%s ERROR: skwd-wall supplied no wallpaper path\n' "$(date --iso-8601=seconds)" >> "$log_file"
    exit 2
fi

if [ ! -f "$wallpaper" ]; then
    printf '%s ERROR: wallpaper does not exist: %s\n' "$(date --iso-8601=seconds)" "$wallpaper" >> "$log_file"
    exit 2
fi

printf '%s Applying: %s\n' "$(date --iso-8601=seconds)" "$wallpaper" >> "$log_file"
matugen -c "$config_file" image "$wallpaper" -m dark -i 0 >> "$log_file" 2>&1
status=$?
printf '%s Exit status: %s\n' "$(date --iso-8601=seconds)" "$status" >> "$log_file"
exit "$status"
