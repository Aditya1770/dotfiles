#!/bin/sh
set -eu

data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fianchetto"
favorites_file="$data_dir/favorite-emojis"
mkdir -p "$data_dir"
touch "$favorites_file"

case "${1:-list}" in
    list)
        sed '/^$/d' "$favorites_file"
        ;;
    toggle)
        glyph=${2:?missing emoji}
        temporary_file=$(mktemp "$data_dir/favorite-emojis.XXXXXX")
        if grep -Fqx -- "$glyph" "$favorites_file"; then
            grep -Fvx -- "$glyph" "$favorites_file" > "$temporary_file" || true
        else
            cp "$favorites_file" "$temporary_file"
            printf '%s\n' "$glyph" >> "$temporary_file"
        fi
        mv "$temporary_file" "$favorites_file"
        ;;
    *)
        exit 2
        ;;
esac
