#!/bin/sh

profile_file=/sys/firmware/acpi/platform_profile
last_profile=

while :; do
    profile=
    if [ -r "$profile_file" ]; then
        IFS= read -r profile < "$profile_file" || true
    fi

    if [ -n "$profile" ] && [ "$profile" != "$last_profile" ]; then
        printf '%s\n' "$profile"
        last_profile=$profile
    fi

    sleep 0.5
done
