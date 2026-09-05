#!/bin/sh

runtime_root=${XDG_RUNTIME_DIR:-/tmp}
cache_dir="$runtime_root/fianchetto-clipboard"
data_root=${XDG_DATA_HOME:-"$HOME/.local/share"}
pinned_dir="$data_root/fianchetto/pinned-clipboard"
mkdir -p "$cache_dir" "$pinned_dir"

for meta_path in "$pinned_dir"/*.meta; do
    [ -f "$meta_path" ] || continue
    entry_id=${meta_path##*/}
    entry_id=${entry_id%.meta}
    entry_type=$(sed -n '1p' "$meta_path")
    data_path="$pinned_dir/$entry_id.data"
    [ -s "$data_path" ] || continue
    if [ "$entry_type" = image ]; then
        printf '%s\timage\tPinned image\tfile://%s\ttrue\n' "$entry_id" "$data_path"
    else
        preview=$(head -c 240 "$data_path" | tr '\t\r\n' '   ')
        printf '%s\ttext\t%s\t\ttrue\n' "$entry_id" "$preview"
    fi
done

cliphist list | head -n 60 | while IFS="$(printf '\t')" read -r entry_id preview; do
    case "$entry_id" in
        ''|*[!0-9]*) continue ;;
    esac
    [ -f "$pinned_dir/$entry_id.meta" ] && continue

    clean_preview=$(printf '%s' "$preview" | tr '\t\r\n' '   ')
    case "$preview" in
        *"binary data"*" png "*|*"binary data"*"image/png"*)
            mime=image/png; extension=png
            ;;
        *"binary data"*" jpg "*|*"binary data"*" jpeg "*|*"binary data"*"image/jpeg"*)
            mime=image/jpeg; extension=jpg
            ;;
        *"binary data"*" webp "*|*"binary data"*"image/webp"*)
            mime=image/webp; extension=webp
            ;;
        *"binary data"*" gif "*|*"binary data"*"image/gif"*)
            mime=image/gif; extension=gif
            ;;
        *"binary data"*"image/"*)
            mime=$(printf '%s' "$preview" | sed -n 's/.*\(image\/[A-Za-z0-9.+-]*\).*/\1/p')
            extension=png
            ;;
        *)
            printf '%s\ttext\t%s\t\tfalse\n' "$entry_id" "$clean_preview"
            continue
            ;;
    esac

    if [ -n "$mime" ]; then
            image_path="$cache_dir/$entry_id.$extension"
            if [ ! -s "$image_path" ]; then
                cliphist decode "$entry_id" > "$image_path" 2>/dev/null || rm -f "$image_path"
            fi
            printf '%s\timage\t%s\tfile://%s\tfalse\n' "$entry_id" "$mime" "$image_path"
    fi
done
