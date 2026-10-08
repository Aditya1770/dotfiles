#!/bin/sh
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
shell_dir=$(CDPATH= cd "$script_dir/.." && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
matugen_dir="$config_home/matugen"
template_dir="$matugen_dir/templates"
config_file="$matugen_dir/config.toml"

if ! command -v matugen >/dev/null 2>&1; then
    printf 'Fianchetto: matugen is not installed. On Arch: sudo pacman -S matugen\n' >&2
    exit 1
fi

mkdir -p "$template_dir" "$data_home/fianchetto"
cp "$shell_dir/matugen/fianchetto.json" "$template_dir/fianchetto.json"
touch "$config_file"

# Recent Matugen releases require the top-level config table even when all
# defaults are used. Older releases accepted a templates-only file.
if ! grep -Eq '^\[config\][[:space:]]*$' "$config_file"; then
    config_tmp=$(mktemp "$matugen_dir/config.toml.XXXXXX")
    {
        printf '[config]\n\n'
        sed -n '1,$p' "$config_file"
    } > "$config_tmp"
    mv "$config_tmp" "$config_file"
fi

if ! grep -Eq '^\[templates\.fianchetto\][[:space:]]*$' "$config_file"; then
    cp "$config_file" "$config_file.fianchetto-backup"
    {
        printf '\n[templates.fianchetto]\n'
        printf "input_path = '%s'\n" "$template_dir/fianchetto.json"
        printf "output_path = '%s'\n" "$data_home/fianchetto/matugen.json"
    } >> "$config_file"
fi

printf 'Fianchetto Matugen template installed.\n'
printf 'In skwd-wall, enable Theme > Matugen command and set Theme > Colour source to Matugen.\n'
