#!/bin/sh

action=$1
entry_id=$2
entry_type=$3
data_root=${XDG_DATA_HOME:-"$HOME/.local/share"}
pinned_dir="$data_root/fianchetto/pinned-clipboard"
data_path="$pinned_dir/$entry_id.data"
meta_path="$pinned_dir/$entry_id.meta"
mkdir -p "$pinned_dir"

if [ "$action" = wipe ]; then
    cliphist wipe
    exit
fi

case "$entry_id" in
    ''|*[!0-9]*) exit 2 ;;
esac

case "$action" in
    restore)
        if [ -s "$data_path" ]; then wl-copy < "$data_path"
        else cliphist decode "$entry_id" | wl-copy
        fi
        ;;
    delete)
        if [ -f "$meta_path" ]; then rm -f "$meta_path" "$data_path"
        else printf '%s\n' "$entry_id" | cliphist delete-query
        fi
        ;;
    pin)
        if [ -f "$meta_path" ]; then
            rm -f "$meta_path" "$data_path"
        else
            case "$entry_type" in image|text) ;; *) exit 2 ;; esac
            cliphist decode "$entry_id" > "$data_path" || exit 1
            printf '%s\n' "$entry_type" > "$meta_path"
        fi
        ;;
    *) exit 2 ;;
esac
