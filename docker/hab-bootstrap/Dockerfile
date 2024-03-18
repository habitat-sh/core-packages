FROM ubuntu:20.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl sudo tar xz-utils gawk bison python3 make m4 patch gcc g++ texinfo bash autoconf protobuf-compiler pkg-config
RUN ln -sfv bash /bin/sh
COPY build.sh /bin/build
RUN chmod +x /bin/build