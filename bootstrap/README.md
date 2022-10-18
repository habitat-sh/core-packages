# Bootstrap Plans

This folder contains all the plans required to bootstrap Habitat Packages for a new platform.
The bootstrapping process is similar to a cross compilation process. You need to have a solid understanding
of cross compilation principles in order to correctly modify and use these plans. Namely the use of the 
terms `host`, `build` and `target` must be well understood. You can find a useful explanation [here](https://gcc.gnu.org/onlinedocs/gccint/Configure-Terms.html)

## Folder Structure

The plans are divided into various sub-folders depending on the manner in which they have to be compiled.
The name of the plan itself reflects it's purpose and not how it must be built. 

For example, the `build-tools-sed` is a natively built plan, however the `build-tools-bison` is built within a bootstrap chroot hab-studio. Both of them are however prefixed as `build-tools-` because they are part of the set of tools used to bootstrap a gcc compiler from source.

### Sub Folders 

| Folder | Description |
|-|-|
| host-tools | Plans for natively building tools that use the host build and runtime environment |
| cross-compiler | Plans to build a cross compiler that uses the host build and runtime environment |
| cross-tools | Plans to build cross-compiled build-tools that uses the host build environment but are designed to be able to run within a chroot habitat studio environment |
| target-tools | Plans to build tools that use the bootstrap chroot hab studio and are designed to run within a chroot habitat studio environment |

### Dependency Rules

The following rules have to be followed while making changes to the plans in this folder.

| Folder | Allowed Build Deps | Allowed Runtime Deps | Reason |
|-|-|-|-|
| host-tools | host-tools | host-tools | The host tools all share the host build and runtime environment |
| cross-compiler | host-tools, cross-compiler | host-tools, cross-compiler | The cross-compiler tools all share the host build and runtime environment |
| cross-tools | host-tools, cross-compiler | cross-tools | The cross tools cannot have build dependencies on other cross tools as they are built on the host system but run on the target system |
| target-tools | cross-tools | cross-tools | The target-tools are built and run on the target system only |

 




