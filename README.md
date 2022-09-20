# Habitat Build Toolchain Bootstrap

This repo contains plan files that can be used to bootstrap a set of self contained GNU build tools
that are completely isolated from the host system environment. These build tools can then be used to
bootstrap a set of standard habitat packages for new platforms. 

This repo build on knowledge available from the Linux From Scratch project (LFS) and adapts it for 
Habitat's packaging system. There are many variants of the LFS project for different platforms and versions. This repo largely follows the instructions [mentioned here](https://clfs.org/~kb0iic/lfs-systemd/index.html). 

## Building Bootstrap Packages

The packages involved in the bootstrapping process are almost always native packages. 
To build them you must make sure you have enabled native package support.

You must also ensure that your host system has all the [required build tools](https://clfs.org/~kb0iic/lfs-systemd/chapter02/hostreqs.html) available.

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