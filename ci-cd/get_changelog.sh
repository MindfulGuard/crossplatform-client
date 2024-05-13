#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <CHANGELOG_FILE> <CURRENT_VERSION>"
    exit 1
fi

changelog_file=$1
current_version=$2

latest_version=$(grep -E "^[0-9]+\.[0-9]+\.[0-9]+" "$changelog_file" | head -n 1)

if [ "$current_version" = "$latest_version" ]; then
    sed -n "/$latest_version/,/^[0-9]+\.[0-9]+\.[0-9]+/{p}" "$changelog_file"
else
    echo ""
fi
