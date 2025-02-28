#!/bin/bash
# fix-x11-permissions.sh - Script to fix X11 permissions on the host
#
# This script should be run on the host machine before running the container
# to ensure proper X11 forwarding.

# Allow connections to the X server from localhost
echo "Setting X server permissions..."
xhost +local:

# Check if .Xauthority exists
if [ ! -f "$HOME/.Xauthority" ]; then
    echo "Warning: $HOME/.Xauthority does not exist."
    echo "This may cause X11 forwarding issues."
    touch "$HOME/.Xauthority"
fi

# Ensure .Xauthority has the right permissions
chmod 600 "$HOME/.Xauthority"

# Check if X11 socket directory exists and has correct permissions
if [ ! -d "/tmp/.X11-unix" ]; then
    echo "Warning: /tmp/.X11-unix does not exist."
    echo "This may indicate that X11 is not running properly on your system."
else
    # Ensure the X11 socket directory has the right permissions
    sudo chmod 1777 /tmp/.X11-unix
    sudo chown root:root /tmp/.X11-unix
fi

echo "X11 permissions have been set."
echo ""
echo "To run the container with X11 forwarding, use:"
echo "./run-with-x11.sh [tag_name]"
echo ""
echo "To test X11 forwarding inside the container, run:"
echo "xeyes or xclock"
