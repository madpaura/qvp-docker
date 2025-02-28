#!/bin/bash
# run-ssh-direct.sh - Run the container with SSH access using direct commands
#
# This script runs the container with SSH port forwarding and directly starts the SSH service
# Usage: ./run-ssh-direct.sh [tag_name] [ssh_port]

set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if container already exists
if docker ps -a | grep -q qvp-ssh-direct; then
    echo "Container 'qvp-ssh-direct' already exists. Removing it..."
    docker rm -f qvp-ssh-direct
fi

# Default values
IMAGE_TAG=${1:-"qvp-docker:latest"}
SSH_PORT=${2:-2222}

echo "========================================================"
echo "Running Docker container: ${IMAGE_TAG} with SSH access"
echo "SSH will be available on port: ${SSH_PORT}"
echo "Default root password: qvpdocker"
echo "Started at: $(date)"
echo "========================================================"

# Run the container with a direct command to keep it running
docker run -d --privileged \
  -p ${SSH_PORT}:22 \
  --name qvp-ssh-direct \
  ${IMAGE_TAG}

#  /bin/bash -c "service ssh start && tail -f /dev/null"

# Wait for container to start
echo "Waiting for container to start..."
sleep 2

# Restart SSH service in the container
echo "Restarting SSH service in the container..."
docker exec qvp-ssh-direct bash -c "service ssh restart"

# Wait for SSH to start
echo "Waiting for SSH service to start..."
sleep 2

# Check if container is still running
if ! docker ps | grep -q qvp-ssh-direct; then
    echo "ERROR: Container stopped unexpectedly. Checking logs..."
    docker logs qvp-ssh-direct
    exit 1
fi

echo "========================================================"
echo "Container is running in background with SSH enabled"
echo ""
echo "To SSH into the container, use:"
echo "  ssh -p ${SSH_PORT} root@localhost"
echo "  Password: qvpdocker"
echo ""
echo "To get a shell in the container, use:"
echo "  docker exec -it qvp-ssh-direct /bin/bash"
echo ""
echo "To stop the container, use:"
echo "  docker stop qvp-ssh-direct"
echo ""
echo "To remove the container, use:"
echo "  docker rm qvp-ssh-direct"
echo "========================================================="
