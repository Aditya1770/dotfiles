#!/bin/sh
set -eu

data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fianchetto"
event_file="$data_dir/events.tsv"
reminder_file="$data_dir/event-reminders.tsv"
mkdir -p "$data_dir"
touch "$event_file"
touch "$reminder_file"

case "${1:-list}" in
    list)
        sort -t "$(printf '\t')" -k1,1 "$event_file"
        ;;
    add)
        date_key=${2:?missing date}
        title=${3:?missing title}
        clean_title=$(printf '%s' "$title" | tr '\t\n\r' '   ')
        printf '%s\t%s\n' "$date_key" "$clean_title" >> "$event_file"
        ;;
    remove)
        date_key=${2:?missing date}
        title=${3:?missing title}
        temporary_file=$(mktemp "$data_dir/events.XXXXXX")
        awk -F '\t' -v date="$date_key" -v title="$title" \
            'BEGIN { removed=0 } !(removed == 0 && $1 == date && $2 == title) { print } $1 == date && $2 == title && removed == 0 { removed=1 }' \
            "$event_file" > "$temporary_file"
        mv "$temporary_file" "$event_file"
        ;;
    pending)
        date_key=${2:?missing date}
        awk -F '\t' -v date="$date_key" '
            FILENAME == ARGV[1] { seen[$1 FS $2] = 1; next }
            $1 == date && !(($1 FS $2) in seen) { print $2 }
        ' "$reminder_file" "$event_file"
        ;;
    mark)
        date_key=${2:?missing date}
        title=${3:?missing title}
        clean_title=$(printf '%s' "$title" | tr '\t\n\r' '   ')
        printf '%s\t%s\n' "$date_key" "$clean_title" >> "$reminder_file"
        ;;
    *) exit 2 ;;
esac
