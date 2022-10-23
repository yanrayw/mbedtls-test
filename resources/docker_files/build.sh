#!/bin/sh

# Build the specified Dockerfile(s).
# Follow the image naming convention used on Jenkins, which uses a hash
# of the Dockerfile contents.

set -e

if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
    cat <<EOF
Usage: $0 DIR/Dockerfile[...] Optional(name of docker image)
Eg: $0 ubuntu-18.04
Build the specified Docker images.
EOF
    exit
fi

list_sh="$(dirname -- "$0")/list-docker-image-tags.sh"
image_prefix="mbedtls-ci/"

USER_NAME=$(id -un)
USER_ID=$(id -u)
USER_GROUP=$(id -g)

build () {
    local image_name=${2:-"$image_prefix$1"}
    if [ -d "$1" ]; then
        set -- "$1/Dockerfile"
    fi
    tag="$("$list_sh" "$1")"
    sudo docker build \
        --build-arg USER_NAME=$USER_NAME           \
        --build-arg USER_ID=$USER_ID               \
        --build-arg USER_GROUP=$USER_GROUP         \
        --network=host -t "$image_name:$tag" -f "$1" "${1%/*}"
}

for d in "$@"; do
    build "$d"
done
