#!/bin/sh
set -eu

interface=${1:?missing Wi-Fi interface}
ssid=${2:?missing SSID}
identity=${3:?missing identity}
connection_name="Fianchetto · $ssid"

IFS= read -r password
[ -n "$password" ] || { printf '%s\n' 'A password is required.' >&2; exit 2; }

command -v nmcli >/dev/null 2>&1 || {
    printf '%s\n' 'NetworkManager (nmcli) is not installed.' >&2
    exit 127
}

# Only replace profiles created by this shell. Existing user-managed profiles
# with the college SSID are left untouched.
if nmcli -t -f NAME connection show | grep -Fxq "$connection_name"; then
    nmcli connection delete "$connection_name" >/dev/null
fi

nmcli connection add \
    type wifi \
    ifname "$interface" \
    con-name "$connection_name" \
    ssid "$ssid" \
    wifi-sec.key-mgmt wpa-eap \
    802-1x.eap peap \
    802-1x.identity "$identity" \
    802-1x.phase2-auth mschapv2 \
    802-1x.password-flags 0 >/dev/null

# NetworkManager treats both the 802.1X identity and password as activation
# secrets. Supply both through stdin so neither appears in nmcli's argv.
if ! printf '802-1x.identity:%s\n802-1x.password:%s\n' "$identity" "$password" \
    | nmcli connection up "$connection_name" passwd-file /dev/stdin >/dev/null 2>&1; then
    nmcli connection delete "$connection_name" >/dev/null 2>&1 || true
    printf '%s\n' 'Authentication failed. Check the user ID and password.' >&2
    exit 1
fi
