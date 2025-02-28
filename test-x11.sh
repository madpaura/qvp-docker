#!/bin/bash
# test-x11.sh - Script to test X11 functionality inside the container
#
# This script should be copied into the container and run to test X11 forwarding

echo "Testing X11 forwarding..."
echo "DISPLAY=$DISPLAY"

# Check if DISPLAY is set
if [ -z "$DISPLAY" ]; then
    echo "Error: DISPLAY environment variable is not set."
    echo "X11 forwarding is not configured correctly."
    exit 1
fi

# Check if X11 socket directory exists
if [ ! -d "/tmp/.X11-unix" ]; then
    echo "Error: /tmp/.X11-unix does not exist."
    echo "X11 socket directory is not properly mounted."
    exit 1
fi

# Check if we can connect to the X server
echo "Attempting to connect to X server..."
if ! xdpyinfo >/dev/null 2>&1; then
    echo "Error: Cannot connect to X server."
    echo "X11 forwarding is not working properly."
    
    # Additional diagnostics
    echo "Checking X11 authentication..."
    if [ ! -f "$HOME/.Xauthority" ]; then
        echo "  - .Xauthority file is missing"
    else
        echo "  - .Xauthority file exists"
    fi
    
    echo "Checking X11 socket permissions..."
    ls -la /tmp/.X11-unix/
    
    exit 1
fi

echo "X11 connection successful!"
echo "Launching a test X11 application (xeyes)..."

# Try to run xeyes as a test
if command -v xeyes >/dev/null 2>&1; then
    xeyes &
    sleep 5
    killall xeyes
    echo "xeyes launched successfully."
else
    echo "xeyes not found. Trying xclock..."
    if command -v xclock >/dev/null 2>&1; then
        xclock &
        sleep 5
        killall xclock
        echo "xclock launched successfully."
    else
        echo "Neither xeyes nor xclock found."
        echo "Please install x11-apps package."
    fi
fi

echo "X11 test completed."
