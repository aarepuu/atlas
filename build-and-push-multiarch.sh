#!/bin/bash

set -euo pipefail

# Variables
IMAGE_NAME="aarepuu/atlas"
IMAGE_TAG="latest" # Replace with specific version as needed


echo "Setting up Docker buildx for multi-platform builds..."
if ! docker buildx inspect multiarch > /dev/null 2>&1; then
  docker buildx create --name multiarch --use
else
  docker buildx use multiarch
fi


echo "Building and pushing multi-architecture image..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ${IMAGE_NAME}:${IMAGE_TAG} \
  --push \
  .

echo "Multi-architecture image pushed successfully!"
echo "Image URL: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Platforms: linux/amd64, linux/arm64"