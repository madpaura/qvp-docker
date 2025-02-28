#!/bin/bash
# run-ssh.sh - Simple and reliable script to run container with SSH access
#
# Usage: ./run-ssh.sh [tag_name] [ssh_port]

set -e

# Default values
IMAGE_TAG=${1:-"qvp-docker:latest"}
SSH_PORT=${2:-2222}

# Remove existing container if it exists
if docker ps -a | grep -q qvp-ssh; then
    echo "Removing existing container..."
    docker rm -f qvp-ssh
fi

echo "========================================================"
echo "Running Docker container with SSH access"
echo "Image: ${IMAGE_TAG}"
echo "SSH port: ${SSH_PORT}"
echo "Started at: $(date)"
echo "========================================================"

# Run the container in detached mode
docker run -d --privileged \
  --name qvp-ssh \
  -p ${SSH_PORT}:22 \
  ${IMAGE_TAG} \
  tail -f /dev/null

# Wait for container to fully start
echo "Waiting for container to fully start..."
sleep 2

# Explicitly start the SSH service
echo "Starting SSH service in the container..."
docker exec qvp-ssh bash -c "service ssh start"

# Verify SSH is running
SSH_STATUS=$(docker exec qvp-ssh bash -c "service ssh status | grep 'Active:' || echo 'Not running'")
echo "SSH service status: $SSH_STATUS"

# Show connection information
echo "========================================================"
echo "Container is running with SSH enabled"
echo ""
echo "To SSH into the container:"
echo "  ssh -p ${SSH_PORT} root@localhost"
echo "  Password: qvpdocker"
echo ""
echo "If SSH connection fails, try manually restarting the SSH service:"
echo "  docker exec qvp-ssh service ssh restart"
echo ""
echo "To access the container shell directly:"
echo "  docker exec -it qvp-ssh /bin/bash"
echo ""
echo "To stop the container:"
echo "  docker stop qvp-ssh"
echo "========================================================"
