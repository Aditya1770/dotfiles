#!/bin/sh

set -eu

profile_file=/sys/firmware/acpi/platform_profile

case "${1:-get}" in
    detect)
        vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)
        product="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true) $(cat /sys/class/dmi/id/product_family 2>/dev/null || true)"
        identity=$(printf '%s %s' "$vendor" "$product" | tr '[:upper:]' '[:lower:]')

        has_battery=false
        for supply in /sys/class/power_supply/BAT*; do
            if [ -r "$supply/type" ] && grep -qx Battery "$supply/type"; then
                has_battery=true
                break
            fi
        done

        case "$identity" in
            *acer*predator*) is_predator=true ;;
            *) is_predator=false ;;
        esac

        if [ "$is_predator" = true ] && [ "$has_battery" = true ] && [ -r "$profile_file" ]; then
            printf '1\n'
        else
            printf '0\n'
        fi
        ;;
    get)
        [ -r "$profile_file" ] || exit 1
        tr -d '\n' < "$profile_file"
        printf '\n'
        ;;
    set)
        profile=${2:-}
        case "$profile" in
            low-power|quiet|balanced|balanced-performance|performance) ;;
            *) exit 2 ;;
        esac

        if [ -w "$profile_file" ]; then
            printf '%s' "$profile" > "$profile_file"
        else
            printf '%s' "$profile" | pkexec /usr/bin/tee "$profile_file" >/dev/null
        fi
        printf '%s\n' "$profile"
        ;;
    *)
        exit 2
        ;;
esac
