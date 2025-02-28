# QEMU/QVirt Docker Development Environment

This repository contains a Docker environment for QEMU/QVirt development.

## Features

- **Organized Package Installation**: Packages are grouped by purpose with clear echo statements for build visibility
- **Python Virtual Environment**: Python packages are installed in a virtual environment at `/opt/venv`
- **X11 Support**: Full X11 forwarding support for GUI applications
- **Build Scripts**: Flexible build scripts with various options
- **Optimized Dockerfile**: Reduced image size by removing cache artifacts

## Building the Docker Image

There are two scripts provided for building the Docker image:

1. **Basic build script**:
   ```
   chmod +x build.sh
   ./build.sh [tag_name]
   ```
   If no tag name is provided, it defaults to `qvp-docker:latest`.

2. **Advanced build script with options**:
   ```
   chmod +x build-with-options.sh
   ./build-with-options.sh [OPTIONS]
   ```
   Available options:
   - `-t, --tag TAG`: Set the image tag (default: qvp-docker:latest)
   - `-n, --no-cache`: Disable Docker build cache
   - `-p, --pull`: Always pull base image
   - `-s, --squash`: Squash newly built layers into a single new layer
   - `-h, --help`: Show help message

## Running the Container with X11 Support

To run the container with X11 forwarding for GUI applications:

1. **Fix X11 permissions on the host**:
   ```
   chmod +x fix-x11-permissions.sh
   ./fix-x11-permissions.sh
   ```

2. **Run the container with X11 forwarding**:
   ```
   chmod +x run-with-x11.sh
   ./run-with-x11.sh [tag_name]
   ```

3. **Test X11 inside the container**:
   Once inside the container, run:
   ```
   test-x11.sh
   ```

## SSH Access to the Container

To run the container with SSH access:

1. **Using the SSH Script (Recommended)**:
   ```
   chmod +x run-ssh.sh
   ./run-ssh.sh [tag_name] [ssh_port]
   ```
   
   Then connect via SSH:
   ```
   ssh -p 2222 root@localhost
   ```
   Password: `qvpdocker`

   If the SSH connection fails, manually restart the SSH service:
   ```
   docker exec qvp-ssh service ssh restart
   ```

2. **SSH Troubleshooting**:
   If you encounter SSH connection issues:
   
   - Restart the SSH service:
     ```
     docker exec qvp-ssh service ssh restart
     ```
   
   - Check SSH service status:
     ```
     docker exec qvp-ssh service ssh status
     ```
   
   - Check SSH configuration:
     ```
     docker exec qvp-ssh cat /etc/ssh/sshd_config
     ```
   
   - View SSH logs:
     ```
     docker exec qvp-ssh cat /var/log/auth.log
     ```
   
   - Try connecting with verbose output:
     ```
     ssh -v -p 2222 root@localhost
     ```

## Dockerfile Structure

The Dockerfile is organized into logical sections with echo statements to provide visibility during the build process:

1. **Base Configuration**: Sets up environment variables and apt configuration
2. **Build Essentials**: Installs core build tools and development packages
3. **Kernel Development**: Installs kernel-specific development packages
4. **QEMU Dependencies**: Installs all libraries required for QEMU development
5. **Virtualization Tools**: Installs KVM, libvirt, and related tools
6. **Networking Tools**: Installs networking utilities and libraries
7. **Debugging Tools**: Installs GDB, profiling tools, and related utilities
8. **Python Environment**: Sets up Python with a virtual environment
9. **X11 Configuration**: Installs and configures X11 support

Each section includes an echo statement to track progress during the build:

```
RUN echo "===> Installing build essentials..." && \
    apt-get update && apt-get install --no-install-recommends \
    build-essential \
    ...
```

## Troubleshooting X11 Forwarding

If you encounter X11 forwarding issues:

1. Make sure your host X server allows connections:
   ```
   xhost +local:
   ```

2. Check if the DISPLAY environment variable is set correctly:
   ```
   echo $DISPLAY
   ```

3. Verify that the X11 socket is properly mounted:
   ```
   ls -la /tmp/.X11-unix/
   ```

4. Ensure .Xauthority is properly configured:
   ```
   touch ~/.Xauthority
   chmod 600 ~/.Xauthority
   ```

5. Try running a simple X11 application like `xeyes` or `xclock` to test.

## Container Features

This Docker container includes:

- Ubuntu 24.04 base
- QEMU development dependencies
- Python virtual environment at `/opt/venv`
- X11 support for GUI applications
- SSH server
- Development tools (git, vim, gdb, etc.)
- Virtualization tools (qemu-kvm, virt-manager, etc.)
- Echo statements for build progress visibility

## Customizing the Build

You can customize the build process by:

1. **Modifying the Dockerfile**: Add or remove packages as needed
2. **Adjusting apt Configuration**: The Dockerfile configures apt for minimal installation by default
3. **Using Build Options**: The build-with-options.sh script provides various build configurations

## License

See the LICENSE file for details.
