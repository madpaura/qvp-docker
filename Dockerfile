# Docker image for QEMU/QVirt Development Environment
# Author: Minwoo Im <minwoo.im@samsung.com>
#         Songyi Park <songyi.park@samsung.com>
#         Haeun Kim <hanee.kim@samsung.com>
#         Vishwanath MG <vishwa.mg@samsung.com>

FROM ubuntu:24.04
MAINTAINER hanee.kim@samsung.com
MAINTAINER vishwa.mg@samsung.com

# Set non-interactive frontend to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set locale
ENV LANG=en_US.UTF-8
ENV NO_AT_BRIDGE=1

# Configure apt to be less verbose
RUN echo "===> Configuring apt for silent operation..." && \
    echo 'Apt::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90assumeyes && \
    echo 'Apt::Install-Recommends "false";' >> /etc/apt/apt.conf.d/90assumeyes && \
    echo 'Apt::Install-Suggests "false";' >> /etc/apt/apt.conf.d/90assumeyes

    # echo 'Apt::Get::quiet "true";' >> /etc/apt/apt.conf.d/90assumeyes && \
    
# Update package sources for faster installation
RUN echo "===> Updating package sources..." && \
    sed -i 's@archive.ubuntu.com@kr.archive.ubuntu.com@g' /etc/apt/sources.list

# Install essential build tools and development packages
RUN echo "===> Installing build essentials..." && \
    apt-get update && apt-get install --no-install-recommends \
    # Build essentials
    build-essential \
    bc \
    git \
    ninja-build \
    meson \
    pkg-config \
    autoconf \
    autogen \
    automake \
    texinfo \
    kmod

RUN echo "===> Installing kernel development packages..." && \
    apt-get update && apt-get install --no-install-recommends \
    # Kernel development
    libncurses-dev \
    libssl-dev \
    xz-utils \
    flex \
    bison \
    libelf-dev

RUN echo "===> Installing QEMU dependencies..." && \
    apt-get update && apt-get install --no-install-recommends \
    # QEMU dependencies
    libglib2.0-dev \
    libfdt-dev \
    libpixman-1-dev \
    zlib1g-dev \
    libaio-dev \
    libbluetooth-dev \
    libbrlapi-dev \
    libbz2-dev \
    libcap-dev \
    libcap-ng-dev \
    libcurl4-gnutls-dev \
    libgtk-3-dev \
    libibverbs-dev \
    libjpeg8-dev \
    libncurses5-dev \
    libnuma-dev \
    librbd-dev \
    librdmacm-dev \
    libsasl2-dev \
    libseccomp-dev \
    libsnappy-dev \
    libsnappy1v5 \
    libssh2-1 \
    libssh2-1-dev \
    libvde-dev \
    libvdeplug-dev \
    libvte-2.91-dev \
    libnfs-dev \
    libiscsi-dev \
    libspice-server-dev \
    libspice-protocol-dev \
    libattr1-dev \
    libsdl2-2.0-0 \
    libsdl2-dev \
    libstdc++6 \
    libunwind-dev

RUN echo "===> Installing virtualization tools..." && \
    apt-get update && apt-get install --no-install-recommends \
    # Virtualization tools
    qemu-kvm \
    virtinst \
    bridge-utils \
    cpu-checker \
    libvirt-daemon-system \
    virt-manager \
    libvirt-clients \
    cgroup-tools \
    # Networking tools
    net-tools \
    iproute2 \
    libpcap-dev

RUN echo "===> Installing debugging and profiling tools..." && \
    apt-get update && apt-get install --no-install-recommends \
    # Debugging and profiling tools
    gdb \
    gdbserver \
    cgdb \
    lcov \
    google-perftools \
    libgoogle-perftools-dev \
    graphviz \
    gv \
    kcachegrind

RUN echo "===> Installing utilities..." && \
    apt-get update && apt-get install --no-install-recommends \
    # Utilities
    vim \
    wget \
    docker.io \
    software-properties-common \
    locales \
    libcanberra-gtk3-module \
    gnome-terminal \
    psmisc \
    expect \
    samba \
    telnet \
    openssh-server \
    libreadline-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python and development tools
RUN echo "===> Installing Python and development tools..." && \
    apt-get update && apt-get install --no-install-recommends \
    python3.12 \
    python3.12-full \
    python3.12-venv \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and activate a Python virtual environment
RUN echo "===> Creating Python virtual environment..." && \
    python3.12 -m venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python packages in the virtual environment
RUN echo "===> Installing Python packages..." && \
    $VIRTUAL_ENV/bin/pip install --no-cache-dir \
    meson \
    pytest \
    pytest-cov \
    flake8 \
    black \
    mypy \
    numpy \
    pandas \
    matplotlib \
    paramiko

# Configure locale
RUN echo "===> Configuring locale..." && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN echo "===> Installing additional X11 packages..." && \
    apt-get update && apt-get install --no-install-recommends \
    # X11 related packages
    x11-apps \
    x11-utils \
    x11-xserver-utils \
    xauth \
    xterm \
    dbus-x11 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure X11
RUN echo "===> Configuring X11..." 
ENV DISPLAY=:0

# Add X11 test script
COPY test-x11.sh /usr/local/bin/test-x11.sh
RUN echo "===> Setting up X11 test script..." && \
    chmod +x /usr/local/bin/test-x11.sh

# Configure SSH server
RUN echo "===> Configuring SSH server..." && \
    apt-get update && apt-get install --no-install-recommends openssh-server && \
    mkdir -p /var/run/sshd && \
    mkdir -p /run/sshd && \
    echo 'root:qvpdocker' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A

# Expose port 5900 for VNC/remote access
EXPOSE 5900
# Expose port 22 for SSH access
EXPOSE 22

# Start SSH service and provide a shell
CMD ["/bin/bash"]
