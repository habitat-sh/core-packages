FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget curl sudo tar xz-utils gawk bison python3 make m4 patch gcc g++ \
    texinfo bash autoconf protobuf-compiler pkg-config

# Link bash to /bin/sh
RUN ln -sfv /bin/bash /bin/sh

# Copy build script to bin
COPY build.sh /bin/build

# Set executable permissions on the build script
RUN chmod +x /bin/build
