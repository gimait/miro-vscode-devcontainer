# Build xenial container
FROM osrf/ros:noetic-desktop-full

# Install tools
RUN apt-get update \
    && apt-get -y install ssh build-essential cmake cppcheck valgrind htop\
    python3-pip python3-matplotlib python3-tk ffmpeg wget \
    net-tools python3-pip python3-flake8 flake8
RUN python3 -m pip install -U pip
RUN python3 -m pip install flake8 apriltag getkey

# Install git and git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get -y install git git-lfs

    # Clean up
RUN rosdep update \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# Add the devcontainer config
COPY config/.bashrc /root/.bashrc
RUN mkdir /root/.miro2/ && ln -s /workspaces/consequential/mdk/share/config /root/.miro2/config
RUN ln -s /workspaces/consequential/mdk /root/mdk
