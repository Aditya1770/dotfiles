#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
shell_dir=$(dirname "$script_dir")

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

install -Dm0755 \
    "$script_dir/fianchetto-power-profile-helper" \
    /usr/local/libexec/fianchetto-power-profile

install -Dm0644 \
    "$shell_dir/data/49-fianchetto-power-profile.rules" \
    /etc/polkit-1/rules.d/49-fianchetto-power-profile.rules

printf '%s\n' "Fianchetto power-profile helper installed."
