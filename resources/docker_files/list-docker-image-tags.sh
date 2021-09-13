#!/bin/sh
#
# List the docker image tag used by Jenkins,
# for the Dockerfile in each subdirectory of this folder.

set -e
cd "$(dirname $0)"

for dir in *; do
    if [ -d "$dir" ]; then
        hash="$(git hash-object "$dir/Dockerfile")"
        echo "$dir-$hash"
    fi
done
