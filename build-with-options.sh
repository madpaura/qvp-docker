#!/bin/bash
# build-with-options.sh - Advanced Docker build script for QEMU/QVirt development environment
#
# This script provides various options for building the Docker image with caching enabled.
# 
# Usage: ./build-with-options.sh [OPTIONS]
#
# Options:
#   -t, --tag TAG       Set the image tag (default: qvp-docker:latest)
#   -n, --no-cache      Disable Docker build cache
#   -p, --pull          Always pull base image
#   -s, --squash        Squash newly built layers into a single new layer
#   -h, --help          Show this help message

set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Default values
IMAGE_TAG="qvp-docker:latest"
USE_CACHE=true
PULL_BASE=false
SQUASH=false
DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--tag)
      IMAGE_TAG="$2"
      shift 2
      ;;
    -n|--no-cache)
      USE_CACHE=false
      shift
      ;;
    -p|--pull)
      PULL_BASE=true
      shift
      ;;
    -s|--squash)
      SQUASH=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -t, --tag TAG       Set the image tag (default: qvp-docker:latest)"
      echo "  -n, --no-cache      Disable Docker build cache"
      echo "  -p, --pull          Always pull base image"
      echo "  -s, --squash        Squash newly built layers into a single new layer"
      echo "  -h, --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run '$0 --help' for usage information"
      exit 1
      ;;
  esac
done

# Build command options
BUILD_OPTS=""

if [ "$USE_CACHE" = true ]; then
  BUILD_OPTS="${BUILD_OPTS}"
else
  BUILD_OPTS="${BUILD_OPTS} --no-cache"
fi

if [ "$PULL_BASE" = true ]; then
  BUILD_OPTS="${BUILD_OPTS} --pull"
fi

if [ "$SQUASH" = true ]; then
  BUILD_OPTS="${BUILD_OPTS} --squash"
fi

if [ "$QUIET_MODE" = true ]; then
  BUILD_OPTS="${BUILD_OPTS} --quiet"
fi

echo "========================================================"
echo "Building Docker image: ${IMAGE_TAG}"
echo "Using Dockerfile in: ${DOCKER_DIR}"
echo "Build options: ${BUILD_OPTS}"
echo "Build started at: $(date)"
echo "========================================================"

# Execute the build command
docker build \
  ${BUILD_OPTS} \
  --tag ${IMAGE_TAG} \
  --file ${DOCKER_DIR}/Dockerfile \
  ${DOCKER_DIR}

echo "========================================================"
echo "Build completed successfully at: $(date)"
echo ""
echo "To run the container, use:"
echo "  docker run -it --privileged ${IMAGE_TAG}"
echo ""
echo "To run with X11 forwarding (for GUI applications):"
echo "  docker run -it --privileged -e DISPLAY=\$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ${IMAGE_TAG}"
echo "========================================================"
