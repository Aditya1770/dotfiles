#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
shell_dir=$(dirname "$script_dir")
group_name=fianchetto-shell

usage() {
    printf '%s\n' \
        "Usage: $0 --install" \
        "" \
        "Opt-in installation of the restricted Fianchetto performance-mode helper." \
        "This is never run by Fianchetto, Stow, or the normal dotfiles setup."
}

[ "${1:-}" = "--install" ] || {
    usage
    exit 2
}

if [ "$(id -u)" -ne 0 ]; then
    target_user=$(id -un)
    exec sudo "$0" --install --user "$target_user"
fi

if [ "${2:-}" = "--user" ] && [ -n "${3:-}" ]; then
    target_user=$3
elif [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ]; then
    target_user=$SUDO_USER
else
    printf '%s\n' "Fianchetto: cannot determine the desktop user." >&2
    printf '%s\n' "Run this script as that user, without a leading sudo." >&2
    exit 2
fi

id "$target_user" >/dev/null 2>&1 || {
    printf 'Fianchetto: user does not exist: %s\n' "$target_user" >&2
    exit 2
}

if ! getent group "$group_name" >/dev/null 2>&1; then
    groupadd --system "$group_name"
fi

install -Dm0755 \
    "$script_dir/fianchetto-power-profile-helper" \
    /usr/local/libexec/fianchetto-power-profile

install -Dm0644 \
    "$shell_dir/data/49-fianchetto-power-profile.rules" \
    /etc/polkit-1/rules.d/49-fianchetto-power-profile.rules

usermod -aG "$group_name" "$target_user"

printf '%s\n' \
    "Fianchetto power-profile helper installed for $target_user." \
    "Log out and back in once so the new $group_name group membership takes effect."
