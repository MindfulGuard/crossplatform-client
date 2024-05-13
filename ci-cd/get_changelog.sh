#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <CHANGELOG_FILE> <CURRENT_VERSION>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    exit 1
fi

current_version="$2"

latest_version=$(grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' "$1" | head -n 1)

if [ "$current_version" = "$latest_version" ]; then
    log=$(awk "/^$latest_version$/,/^([0-9]+\.[0-9]+\.[0-9]+)$/ {print}" "$1" | sed '$d')
    echo "$log"
else
    echo ""
fi
