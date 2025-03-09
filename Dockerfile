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

RUN apt update 
# Expose port 5900 for VNC/remote access
EXPOSE 5900
# Expose port 22 for SSH access
EXPOSE 22

# Start SSH service and provide a shell
CMD ["/bin/bash"]
