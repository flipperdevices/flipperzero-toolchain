#!/bin/bash

set -euo pipefail;

DIRECTORY="${1:-""}";

if [[ -z "$DIRECTORY" ]]; then
    echo "Usage: $0 [directory]";
    exit 1;
fi

OBJECTS=( $(find "$DIRECTORY" -type f ! -size 0 ! -name "*.a" -and ! -name "*.o" -exec file {} \; | grep ELF | awk -F ': ELF' '{print $1}') );
for CUR in "${OBJECTS[@]}"; do
	strip "$CUR";
done
