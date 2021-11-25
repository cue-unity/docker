#!/usr/bin/env bash

set -eu -o pipefail
shopt -s inherit_errexit

export DOCKER_BUILDKIT=1

# buildDockerImage is a helper for the cueckoo/unity Dockage image.
#
# The -p flag attempts to push the resulting images to Docker hub.

pushFlag="--push"

while getopts ':b' opt; do
	case $opt in
		b) pushFlag="" ;;
		*) echo 'Error in command line parsing' >&2
			exit 1
	esac
done

# Change to the top-level of the git repo
command cd "$(git rev-parse --show-toplevel)"

target="cueckoo/unity"

# linux/arm64 and linux/amd64 are sufficient here
# because on macOS we have native emulation.
docker buildx build --platform linux/arm64,linux/amd64 $pushFlag -t $target .
