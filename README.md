# Habitat Build Toolchain Bootstrap

This repo contains plan files that can be used to bootstrap a set of self contained GNU build tools
that are completely isolated from the host system environment. These build tools can then be used to
bootstrap a set of standard habitat packages for new platforms. 

This repo build on knowledge available from the Linux From Scratch project (LFS) and adapts it for 
Habitat's packaging system. There are many variants of the LFS project for different platforms and versions. This repo largely follows the instructions [mentioned here](https://clfs.org/~kb0iic/lfs-systemd/index.html). 

## Building Bootstrap Packages

The packages involved in the bootstrapping process are almost always native packages. 
To build them you must make sure you have enabled native package support.

As of this writing, you need a habitat build of the latest commit on [jj/aarch64-linux-bootstrap branch](https://github.com/habitat-sh/habitat/tree/jj/aarch64-linux-bootstrap) to build these plans.

```bash
export HAB_FEAT_NATIVE_PACKAGE_SUPPORT=1
```

To build a package you can use the following command

```bash
# In the root folder of this repo
hab pkg build -N <package-folder>
# Eg: hab pkg build -N build-tools-glibc
```

### Checking the Host System tools

You can run the `version-check.sh` script to check the versions of the various required tools on your system.
Be sure to cross check the version meets the minimum specified version mentioned [here](https://clfs.org/~kb0iic/lfs-systemd/chapter02/hostreqs.html).

```bash
bash version-check.sh
```

### Cross Building

You should theoretically be able to follow the same build process to cross build the arm packages on 
`x86_64` linux platforms as well. To do so you need to set an additional environment variable before 
running a build.

```bash
# On an x86_64 machine
export TARGET_ARCH="aarch64-linux"
```

### Running Tests

Most of the packages have tests defined. You can run it by setting the `DO_CHECK` environment variable.

```bash
DO_CHECK=1 hab pkg build -N <package-folder>
# Eg: DO_CHECK=1 hab pkg build -N build-tools-file
```

## Build Order

### Temporary Cross Compilation Toolchain

These are a minimal set of packages that can be used to build an isolated set of build tools. 
At this stage the build process completely depends on tools available on the host system.

- native-libgmp
- native-libmpfr
- native-libmpc
- native-libisl
- native-cross-binutils
- native-cross-gcc-real
- build-tools-linux-headers
- build-tools-glibc
- build-tools-libstdcpp
- native-cross-gcc

### Build Toolchain

These are the set of packages that compromise the isolated build tools. They still depend on tools 
available on the host for their build process, however they have no runtime dependencies on the host system.

This list is incomplete as this repo is still a work in progress.

- build-tools-m4
- build-tools-ncurses
- build-tools-bash
- build-tools-coreutils
- build-tools-diffutils
- native-file
- build-tools-file
- build-tools-findutils
- build-tools-gawk
- build-tools-grep
- build-tools-gzip
- build-tools-make
- build-tools-patch
- build-tools-sed
- build-tools-tar
- build-tools-xz
- build-tools-binutils
- build-tools-libgmp
- build-tools-libmpfr
- build-tools-libmpc
- build-tools-libisl
- build-tools-gcc