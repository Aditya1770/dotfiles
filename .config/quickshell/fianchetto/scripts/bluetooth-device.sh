#!/bin/sh

set -eu

action=${1:-}
address=${2:-}

case "$address" in
    [0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]) ;;
    *) printf 'Invalid Bluetooth address\n' >&2; exit 2 ;;
esac

device_info() {
    bluetoothctl info "$address" 2>/dev/null
}

case "$action" in
    pair)
        bluetoothctl power on >/dev/null
        if ! timeout 40 bluetoothctl --agent=NoInputNoOutput pair "$address"; then
            device_info | grep -q 'Paired: yes' || {
                printf 'Pairing failed. Put the device in pairing mode and try again.\n' >&2
                exit 1
            }
        fi
        bluetoothctl trust "$address" >/dev/null
        timeout 20 bluetoothctl connect "$address" >/dev/null || {
            printf 'Paired successfully, but connection failed.\n' >&2
            exit 1
        }
        ;;
    connect)
        bluetoothctl trust "$address" >/dev/null
        timeout 20 bluetoothctl connect "$address" >/dev/null || {
            printf 'Could not connect to the device.\n' >&2
            exit 1
        }
        ;;
    disconnect)
        timeout 15 bluetoothctl disconnect "$address" >/dev/null || {
            printf 'Could not disconnect the device.\n' >&2
            exit 1
        }
        ;;
    forget)
        bluetoothctl disconnect "$address" >/dev/null 2>&1 || true
        bluetoothctl remove "$address" >/dev/null || {
            printf 'BlueZ could not remove the device.\n' >&2
            exit 1
        }
        if device_info >/dev/null 2>&1; then
            printf 'The device is still registered with BlueZ.\n' >&2
            exit 1
        fi
        ;;
    *) printf 'Unknown Bluetooth action\n' >&2; exit 2 ;;
esac
