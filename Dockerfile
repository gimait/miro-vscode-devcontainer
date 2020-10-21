# Build libglvnd
FROM ubuntu:16.04 as libglvnd
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        make \
        automake \
        autoconf \
        libtool \
        pkg-config \
        python \
        libxext-dev \
        libx11-dev \
        x11proto-gl-dev && \
    rm -rf /var/lib/apt/lists/*

ARG LIBGLVND_VERSION=v1.1.1

WORKDIR /opt/libglvnd
RUN git clone --branch="${LIBGLVND_VERSION}" https://github.com/NVIDIA/libglvnd.git . && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/x86_64-linux-gnu && \
    make -j"$(nproc)" install-strip && \
    find /usr/local/lib/x86_64-linux-gnu -type f -name 'lib*.la' -delete

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
        gcc-multilib \
        libxext-dev:i386 \
        libx11-dev:i386 && \
    rm -rf /var/lib/apt/lists/*

# 32-bit libraries
RUN make distclean && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/i386-linux-gnu --host=i386-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" && \
    make -j"$(nproc)" install-strip && \
    find /usr/local/lib/i386-linux-gnu -type f -name 'lib*.la' -delete

# Build Ogre
FROM ubuntu:16.04 as libogre
RUN apt update && apt install -y \
        build-essential automake libtool libfreetype6-dev libfreeimage-dev libzzip-dev \
        libxrandr-dev libxaw7-dev freeglut3-dev libgl1-mesa-dev libglu1-mesa-dev libpoco-dev \
        libtbb-dev doxygen libcppunit-dev wget cmake unzip

RUN mkdir -p /workspaces/ogre && \
    cd /workspaces/ogre && \
    wget -q https://github.com/OGRECave/ogre/archive/v1.9.1.zip && \
    unzip -o v1.9.1.zip && \
    rm v1.9.1.zip && \
    mkdir ogre-1.9.1/build

RUN cd /workspaces/ogre/ogre-1.9.1/build && \
    cmake   -DOGRE_BUILD_TOOLS:BOOL="0" -DOGRE_BUILD_COMPONENT_TERRAIN:BOOL="0" \
            -DOGRE_BUILD_COMPONENT_RTSHADERSYSTEM:BOOL="0" -DOGRE_INSTALL_TOOLS:BOOL="0" \
            -DOGRE_BUILD_COMPONENT_VOLUME:BOOL="0" -DOGRE_BUILD_COMPONENT_PAGING:BOOL="0" \
            -DOGRE_INSTALL_DOCS:BOOL="0" -DOGRE_INSTALL_SAMPLES:BOOL="0" \
            -DOGRE_BUILD_COMPONENT_PROPERTY:BOOL="0" \
            .. && \
    make -j"$(nproc)" && \
    make install && \
    mkdir /tmp/libogre && \
    make DESTDIR=/tmp/libogre install

# Add libraries to xenial
FROM osrf/ros:kinetic-desktop-full

RUN apt-get update \
    # Install tools
    && apt-get -y install build-essential cmake cppcheck valgrind htop git\
    python python-matplotlib python-tk ffmpeg wget \
    net-tools python-pip

RUN pip install --upgrade pip
RUN pip install apriltag signals flake8

# Upgrade gazebo
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list
RUN wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN apt-get update \
    # Remove old gazebo
    && apt-get remove -y ros-kinetic-gazebo* \
    && apt-get install -y gazebo9 gazebo9-* ros-kinetic-gazebo9-*

    # Clean up
RUN rosdep update \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Nvidia support
COPY --from=libglvnd /usr/local/lib/x86_64-linux-gnu /usr/local/lib/x86_64-linux-gnu
COPY --from=libglvnd /usr/local/lib/i386-linux-gnu /usr/local/lib/i386-linux-gnu

COPY tools/10_nvidia.json /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    echo '/usr/local/lib/i386-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig

ENV LD_LIBRARY_PATH /usr/local/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# Install Ogre
COPY --from=libogre /tmp/libogre/usr/local/lib/ /usr/local/lib/
COPY --from=libogre /tmp/libogre/usr/local/lib/OGRE /usr/local/lib/OGRE
COPY --from=libogre /tmp/libogre/usr/local/lib/pkgconfig /usr/lib/x86_64-linux-gnu/pkgconfig
COPY --from=libogre /tmp/libogre/usr/local/include/OGRE /usr/local/include/OGRE


# Add the devcontainer config
COPY config/.bashrc /root/.bashrc
RUN mkdir /root/.miro2/ && ln -s /workspaces/consequential/mdk/share/config /root/.miro2/config
RUN ln -s /workspaces/consequential/mdk /root/mdk

