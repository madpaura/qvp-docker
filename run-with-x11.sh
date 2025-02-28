#!/bin/bash
# run-with-x11.sh - Script to run the QEMU/QVirt container with X11 forwarding
#
# This script sets up proper X11 forwarding for GUI applications in the container
# Usage: ./run-with-x11.sh [tag_name]
#
# If tag_name is not provided, it defaults to "qvp-docker:latest"

set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Default image tag
IMAGE_TAG=${1:-"qvp-docker:latest"}

# Allow X server connections from local users
xhost +local:

# Get the current user's UID and GID
USER_UID=$(id -u)
USER_GID=$(id -g)

echo "========================================================"
echo "Running Docker container: ${IMAGE_TAG} with X11 forwarding"
echo "Started at: $(date)"
echo "========================================================"

# Run the container with X11 forwarding
docker run -it --privileged \
  --network=host \
  -e DISPLAY=$DISPLAY \
  -e XAUTHORITY=$XAUTHORITY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/root/.Xauthority:ro \
  -v /etc/localtime:/etc/localtime:ro \
  ${IMAGE_TAG}

# Disallow X server connections when done
xhost -local:

echo "========================================================"
echo "Container session ended at: $(date)"
echo "========================================================"
