#!/bin/bash

cmd() {
    echo "[#] $*" >&2
    # "$@"
}


CHMOCKER_IMAGES_DIR_PATH="$HOME/.chmo/images"
CHMOCKER_IMAGES_DIR_SUFFIX="${1:-}"

if [ ! -z "$CHMOCKER_IMAGES_DIR_SUFFIX" ]; then
    export CHMOCKER_IMAGES_DIR_SUFFIX

    cmd mkdir -p "${CHMOCKER_IMAGES_DIR_PATH}/${CHMOCKER_IMAGES_DIR_SUFFIX}"
    cmd cp "${CHMOCKER_IMAGES_DIR_PATH}/MacOSVenturaWithBrew.tar" "${CHMOCKER_IMAGES_DIR_PATH}/${CHMOCKER_IMAGES_DIR_SUFFIX}/"

    for i in $(seq 1 8); do
        tag=$(head -n1 Dockerfile.step${i} | cut -f4 -d' ')

        cmd cp Dockerfile.step${i} Dockerfile
        cmd chmocker build -t ${tag}
        cmd rm Dockerfile
    done

    cmd cp "${CHMOCKER_IMAGES_DIR_PATH}/${CHMOCKER_IMAGES_DIR_SUFFIX}/flipperzero-toolchain-mac.tar" "${CHMOCKER_IMAGES_DIR_PATH}/${CHMOCKER_IMAGES_DIR_SUFFIX}/flipperzero-toolchain-mac:${CHMOCKER_IMAGES_DIR_SUFFIX}.tar"
fi
