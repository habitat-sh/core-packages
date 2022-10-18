# Habitat Build Toolchain Bootstrap

This repo contains plan files that can be used to bootstrap a set of self contained GNU build tools
that are completely isolated from the host system environment. These build tools can then be used to
bootstrap a set of standard habitat packages for new platforms. 

This repo builds on knowledge available from the Linux From Scratch project (LFS) and adapts it for 
Habitat's packaging system. There are many variants of the LFS project for different platforms and versions. 
This repo largely follows the instructions [mentioned here](https://clfs.org/~kb0iic/lfs-systemd/index.html).

## Building

### Checking the Host System tools

Before you start building, you can run the `version-check.sh` script to check the versions of the various required tools on your system.
Be sure to cross check the version meets the minimum specified version mentioned [here](https://clfs.org/~kb0iic/lfs-systemd/chapter02/hostreqs.html).

```bash
bash version-check.sh
```

### Building with hab-auto-build

The packages in this repo can be built using [hab-auto-build](). 

To build all the packages you can use the following command:

```bash
hab-auto-build build
```

**IMPORTANT** If you make any changes to any plans in any of the folders, the hab-auto-build 
tool will consider the package as updated and rebuild that package and all it's
dependants.

You can also build a specific package and all packages that depend on it with
the following command:

```bash
hab-auto-build build -i dev <package-name>
```

### Building Manually

The packages involved in the bootstrapping process are almost always native packages.
To build them you must make sure you have enabled native package support for Habitat.

As of this writing, you need a habitat build of the latest commit on [jj/aarch64-linux-bootstrap branch](https://github.com/habitat-sh/habitat/tree/jj/aarch64-linux-bootstrap) to build these plans.

```bash
export HAB_FEAT_NATIVE_PACKAGE_SUPPORT=1
```

To build a package you can use the following command

```bash
# In the root folder of this repo
hab pkg build -N <package-folder>
# Eg: hab pkg build -N bootstrap/cross-tools/build-tools-glibc
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
# Eg: DO_CHECK=1 hab pkg build -N bootstrap/cross-tools/build-tools-file
```

## Manual Build Order

This is a build order for the initial set of build tools packages that can be followed if you
are building each plan manually. 

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

### Build Tools

These are the set of packages that compromise the isolated build tools. They still depend on tools 
available on the host for their build process, however they have no runtime dependencies on the host system.

- build-tools-binutils
- build-tools-libgmp
- build-tools-libmpfr
- build-tools-libmpc
- build-tools-libisl
- build-tools-gcc
- build-tools-gcc-libs
- build-tools-patchelf
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
- build-tools-cacerts
- build-tools-openssl
- build-tools-wget
- native-busybox-static

### Hab Bootstrap Studio Toolchain

These next set of packages are the minimum set of native packages required to get a functional
habitat bootstrap studio running to start building standard packages in a clean room environment.

Since these components already have existing standard plans, we have an alternative set of native
bootstrapping plans in this repo which we use to build a minimal hab chroot studio with support for 
the `bootstrap` studio type.

- build-tools-hab
- build-tools-hab-plan-build
- build-tools-hab-backline
- build-tools-studio

On you have built a bootstrap studio you can use it for isolated package builds using the following 
commands. 

```bash
# Entering a studio
sudo HAB_LICENSE=accept-no-persist HAB_ORIGIN=core hab pkg exec core/build-tools-hab-studio hab-studio -- -t bootstrap enter
```

**IMPORTANT**: If you have not yet been able to push your packages to the builder you will need to ensure
that the correct version of each build dependency is installed inside the bootstrap studio before doing a build.

You can do this using the following command inside the studio:

```bash
hab pkg install /hab/cache/artifacts/<dependency-hart-file>
# Eg: hab pkg install /hab/cache/artifacts/core-build-tools-util-linux-2.38.1-20221018054208-aarch64-linux.hart
```