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

while getopts 'p' opt; do
	case $opt in
		p) push=true ;;
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

if ! [[ $imageExists ]]
then
	if docker pull $target > /dev/null 2>&1
	then
		echo "successfully pulled $target"
		# No need to push because we pulled
		exit 0
	fi
	docker build --rm -t $target .
fi

if [[ $push ]]
then
	docker push $target
fi
