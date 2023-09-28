# Habitat Core Packages

This repository houses plan files designed to bootstrap a comprehensive suite of self-sufficient GNU build tools. These tools are designed to operate independently from the host system environment, providing a foundation to bootstrap a complete set of standard habitat packages for both new and existing platforms.

The repository leverages knowledge from various sources, including the Linux From Scratch (LFS) project and Nix, and tailors it to suit Habitat's packaging system.

There exist numerous LFS project variants tailored for different platforms and versions. This repository primarily adheres to the instructions [found here](https://clfs.org/~kb0iic/lfs-systemd/index.html).

## Compilation Process

To compile all the packages contained within this repository, clone the repository and execute the following command:

```bash
make build
```

The Habitat Auto Build tool is utilized internally to build the packages. For more complex tasks, please refer to the Habitat Auto Build tool's [readme](https://github.com/habitat-sh/hab-auto-build/tree/v2).
