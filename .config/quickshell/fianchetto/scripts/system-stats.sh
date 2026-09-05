#!/bin/sh
set -eu

read_cpu() {
    set -- $(sed -n 's/^cpu  //p' /proc/stat)
    idle=$(( ${4:-0} + ${5:-0} ))
    total=0
    for value in "$@"; do total=$((total + value)); done
    printf '%s %s\n' "$idle" "$total"
}

set -- $(read_cpu)
idle_a=$1 total_a=$2
sleep 0.5
set -- $(read_cpu)
idle_b=$1 total_b=$2

delta_total=$((total_b - total_a))
delta_idle=$((idle_b - idle_a))
if [ "$delta_total" -gt 0 ]; then
    cpu=$(( (100 * (delta_total - delta_idle) + delta_total / 2) / delta_total ))
else
    cpu=0
fi

memory_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
memory_available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
memory_used=$((memory_total - memory_available))
memory_percent=$((100 * memory_used / memory_total))

set -- $(df -Pk / | awk 'NR == 2 {print $3, $2, $5}')
disk_used_kb=$1 disk_total_kb=$2 disk_percent=${3%%%}
disk_used_gb=$((disk_used_kb / 1024 / 1024))
disk_total_gb=$((disk_total_kb / 1024 / 1024))

printf '%s\t%s\t%s\t%s\t%s\n' \
    "$cpu" "$memory_percent" "$disk_used_gb" "$disk_total_gb" "$disk_percent"
