# Habitat Packaging Guidelines

This document is a set of general guidelines to follow when habitizing a new package.

## General Principles
The packaged program needs to be able to run within an isolated chroot environment containing
only it's declared runtime deps. This make the program portable to any operating system as
long as the underlying kernel and cpu are compatible. 

Most of the techniques for doing this are directly influenced by the [Nix](https://github.com/NixOS/nixpkgs) project which 
is the source of inspiration for Habitat's packaging system. Getting familiar with the way 
the Nix project has addressed these is usually the easiest way to overcome many of the 
challenges faced.
A non-exhaustive list of some of the techniques used to achieve this are:
- Wrapper scripts to modify runtime behaviour of the program
  - gcc: We use wrappers to ensure gcc works with the correct linker / glibc and linux headers
  - binutils: We use wrappers to ensure produced binaries and libraries have the correct rpaths
- Patching the source to not use host system libraries, files and programs:
  - We patch the path of script interpreters to use fixed interpreters instead of standard host interpreters, for example:
    - `#!/bin/bash` becomes `#!/hab/pkgs/core/bash/5.1/20220701121212/bin/bash`
    - `#!/bin/perl` becomes `#!/hab/pkgs/core/perl/5.0/20220901121212/bin/perl`
  - We patch compilers like gcc to not search for standard libraries in default system locations
  - We used wrapped linkers to write the exact library locations as rpath entries so that each 
    library/executable finds the correct intendend versions of dependent libraries. This is what
    enables us to have programs with different versions of the same dependency installed
    simultaneously also known as the [Diamond Dependency Problem](https://jlbp.dev/what-is-a-diamond-dependency-conflict).
- We use tools like patchelf to modify the rpaths of precompiled binaries so that they find versions
  provided by our packages. We take this approach in the core/rust package.

## C/C++ GNU Autotools based packages

- Familiarize yourself with C/C++ project build tools. The most important tools to understand
  are:
    - Make: Used by most packages to build everything
    - Autoconf: Used to detect what features to enable and disable
    - Automake: Used to generate complex configurations and make based build systems
    - Libtool: Used by several package to create a unified way of compiling and linking C/C++
      programs across various platforms.
    - pkg-config: Used by configure scripts to search for package dependencies on the build system.

- For most 'final' packages we would ideally like to build as many features as practically 
  possible. Sometimes this may introduce a cyclic dependency between two packages. 
  See the section on resolving cyclic deps below for more information.

  Some ways of discovering the package's optional dependencies are:
    - **Configure Script Help** : Running `./configure --help` will help you.
    - **Scanning Logs**: Most build logs will contain useful output from configure scripts that
      tell you what it is looking for. 
      
- Some of the most common deps for almost all autotools based packages are:
    - coreutils
    - gawk
    - grep
    - sed
- Some of the less common deps which however are often needlessly added to most plans are:
    - diffutils: Check if the configure script actually checks for the `diff` program, or if a test uses it
    - patch: Most packages don't use patch. A plan usually only needs patch to apply it's own patches 
    to the source files.

- Get an understanding the of the various C and Unix Standards as they help to connect the dots and gain deeper understanding
  of why certain packages are built in a particular way.
  - [POSIX](https://en.wikipedia.org/wiki/POSIX): Common OS standard followed by various UNIX like OSes such as MacOS, Linux, FreeBSD
  - [FHS](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard): Common Filesystem Layout standard followed by most Linux distributions
  - [ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format): Common standard for executing binaries on UNIX like OSes
  - [ANSI C](https://en.wikipedia.org/wiki/ANSI_C): Multiple standards followed by most major C/C++ compilers.

## Resolving Cyclic Dependencies of Packages

Suppose you have 2 packages A and B which depend on each other to be built.
If both package A and B cannot be built without the other it's a hard cycle.
If package A or B can be built with sufficient functionality such that it can be used 
to build the other package, it's a soft cycle.

The general steps to resolve both of these are mentioned below.
You may need to build multiple packages sometimes to resolve these cycles as A and B
may have additional runtime deps. 

In the below steps the following assumptions are made:
- A package prefixed with `native-`, is built as a native package. eg: 'native-A', 'native-A-stage0'
- A package suffixed with `-host` is provided by the host system and is not a actually 
  a habitat package. eg: 'B-host'
- A package with no prefix or suffix is can built and run in a studio environment. eg: 'A', 'A-stage1'
- Native packages are configured/patched in a way that they can run in a studio environment. eg: 'native-A'

### Soft Cycle of Build Deps
1. Build A-stage1 without B as build dep.
2. Build B with A-stage1 as a build dep.
3. Build A with B as a build dep.

### Hard Cycle of Build Deps
1. Build native-A with B-host as build dep.
2. Build B with native-A as a build dep.
3. Build A with B as a build dep.

### Soft Cycle of Runtime Dep
1. Build A-stage1 without B as runtime dep.
2. Build B-stage1 without A as runtime dep.
3. Build A-base with B-stage1, but don't add B-stage1 as runtime dep.
4. Build B with A as a runtime dep.
5. Build A with B as a runtime dep and A-base as a build dep.

### Hard Cycle of Runtime Dep (TODO)
This is usually not very straightforward, and there are multiple possible approaches.
Will document this in the future.

## Package Sanity Checklist 

While you may be able to sometimes build packages successfully, they may not be built in the right
way. Namely, they may use host system libraries or files during their runtime execution.

These are some recommended checks to help ensure your packages behave as intended during runtime.
- Check the rpath entries of all produced shared libraries and dynamically linked binaries using readelf:
  ```bash
  readelf -d /hab/pkgs/core/glibc/2.36/20221130093221/bin/*
  readelf -d /hab/pkgs/core/glibc/2.36/20221130093221/lib/*
  ```
- In case of dynamically linked glibc binaries and libraries check that `ldd` resolves all dependencies to 
  '/hab/pkgs/*' locations.
- Run any binaries to see that they work as expected
- Run the built in test cases of the packages if possible. Most packages come with built in tests.
  This can give a high degree of confidence that the program works as intended in various runtime scenarios.
- Cross reference your plan's build with the equivalent Nix package. Most of the packages on the Nix project
  have had a long time to find various runtime behaviors that may need fixing which can be much harder to 
  discover otherwise.

## Common Sources of Reference on how to build packages

These are a list of common places to find information on what patches, configurations and tweaks that
may be required to be done on a package. It is advised to not follow the steps and practices from any of 
these sources blindly as they often are solving for problems that are highly relevant to their own 
package ecosystem.

- Package's own README
- [Linux From Scratch Project](https://clfs.org/~kb0iic/lfs-systemd/index.html): Useful source of the core packages needed for any linux distro.
- [Beyond Linux From Scratch Project](https://www.linuxfromscratch.org/blfs/view/stable/): Useful source of a large variety of commonly used linux packages
- [Nix Project](https://github.com/NixOS/nixpkgs): Most of our core plans are basically ports of the relevant parts of the nix package to 
  Habitat's plan file format.
- [Ubuntu Launchpad](https://launchpad.net/ubuntu): Also a good source of reference for general ideas around packaging such as what features. You will need an account to login.
  to enable for a package and various incompatibilites and solutions for different package versions.
- [Habitat Core Plans](https://github.com/habitat-sh/core-plans): The existing Habitat Core Plans for the x86_64 platform are also a good reference 
  for ways to solve the challenges in existing packages.
