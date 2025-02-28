#!/bin/bash
# build.sh - Docker build script with caching enabled for QEMU/QVirt development environment
# 
# This script builds the Docker image with caching enabled to speed up subsequent builds.
# Usage: ./build.sh [tag_name] [options]
#
# If tag_name is not provided, it defaults to "qvp-docker:latest"
# Options:
#   -q, --quiet         Enable quiet mode (less verbose output)

set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Default values
IMAGE_TAG="qvp-docker:latest"
QUIET_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -q|--quiet)
      QUIET_MODE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [tag_name] [options]"
      echo ""
      echo "Options:"
      echo "  -q, --quiet         Enable quiet mode (less verbose output)"
      echo "  -h, --help          Show this help message"
      exit 0
      ;;
    *)
      # If not an option, assume it's the tag name
      if [[ "$1" != -* ]]; then
        IMAGE_TAG="$1"
        shift
      else
        echo "Unknown option: $1"
        echo "Run '$0 --help' for usage information"
        exit 1
      fi
      ;;
  esac
done

# Directory containing the Dockerfile
DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build options
BUILD_OPTS=""
if [ "$QUIET_MODE" = true ]; then
  BUILD_OPTS="${BUILD_OPTS} --quiet"
fi

echo "========================================================"
echo "Building Docker image: ${IMAGE_TAG}"
echo "Using Dockerfile in: ${DOCKER_DIR}"
echo "Build started at: $(date)"
echo "========================================================"

# Build the Docker image with cache enabled
docker build \
  --cache-from ${IMAGE_TAG} \
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
