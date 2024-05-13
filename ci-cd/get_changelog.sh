#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <PATH_TO_FILE> <VERSION>"
    exit 1
fi

file_path=$1
version=$2

if [ ! -f "$file_path" ]; then
    echo "File not found: $file_path"
    exit 1
fi

current_version=""

while IFS= read -r line; do
    if [[ "$line" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        current_version="$line"
    elif [ "$current_version" = "$version" ]; then
        echo "$line"
    fi
done < "$file_path"
