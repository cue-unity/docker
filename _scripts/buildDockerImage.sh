#!/usr/bin/env bash

set -eu -o pipefail
shopt -s inherit_errexit

export DOCKER_BUILDKIT=1

# buildDockerImage is a helper for the cueckoo/unity Dockage image.
#
# Run with no args, the script first checks whether an image corresponding
# to the commit at which the copybara submodule is pinned exists locally.
# If not, it attempts to pull it from Docker hub. Failing that, the image
# is built.
#
# The -p flag attempts to push the local image to Docker hub.

push=""
force=""

while getopts 'pf' opt; do
	case $opt in
		p) push=true ;;
		f) force=true ;;
		*) echo 'Error in command line parsing' >&2
			exit 1
	esac
done

# Change to the top-level of the git repo
command cd "$(git rev-parse --show-toplevel)"

target="cueckoo/unity:$(git rev-parse HEAD)"

imageExists=""
if docker inspect $target > /dev/null 2>&1
then
	imageExists=true
fi

if [[ $force ]] || ! [[ $imageExists ]]
then
	if ! [[ $force  ]] && docker pull $target > /dev/null 2>&1
	then
		echo "successfully pulled $target"
		# No need to push because we pulled
		exit 0
	fi
	pushFlag=""
	if [[ $push ]]
	then
		echo "Push is $push"
		pushFlag="--push"
	fi
	# linux/arm64 and linux/amd64 are sufficient here
	# because on macOS we have native emulation.
	docker buildx build --platform linux/arm64,linux/amd64 $pushFlag -t $target .
fi

