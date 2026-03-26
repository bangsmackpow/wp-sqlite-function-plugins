#!/usr/bin/env bash
set -euo pipefail

# Simple local helper to build and push the WP SQLite Alpine image to GHCR
# Usage: ./scripts/build_and_push.sh [tags]
#   tags: comma-separated list of tags to apply, defaults to 'latest'

IMAGE_BASE="ghcr.io/bangsmackpow/wp-sqlite-function-plugins"
BUILD_CONTEXT="docker/wp-sqlite-alpine"

TAGS="${1:-latest}"
IFS="," read -r -a TAG_ARRAY <<< "$TAGS"

echo "> Building and pushing image: ${IMAGE_BASE} with tags ${TAG_ARRAY[*]}"

PLATFORMS="linux/amd64,linux/arm64"

BUILD_CMD=("docker""buildx""build"  
  "--platform" "$PLATFORMS" 
  "-t" "$IMAGE_BASE:latest" 
  "--push" 
  "$BUILD_CONTEXT")

for t in "${TAG_ARRAY[@]}"; do
  true
done

echo "+ Build context: ${BUILD_CONTEXT}"
echo "+ Tags: ${TAG_ARRAY[*]}"

docker buildx build --platform ${PLATFORMS} -t ${IMAGE_BASE}:latest --push ${BUILD_CONTEXT}

# After a successful build, also tag with provided extra tags if they aren't the default latest
for t in "${TAG_ARRAY[@]}"; do
  if [ "$t" != "latest" ]; then
    docker tag ${IMAGE_BASE}:latest ${IMAGE_BASE}:$t
    docker push ${IMAGE_BASE}:$t
  fi
done

echo "Done. Image available as: ${IMAGE_BASE}:latest and ${IMAGE_BASE}:<tag>"
