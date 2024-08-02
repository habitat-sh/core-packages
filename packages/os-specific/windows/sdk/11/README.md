# windows-11-sdk

The Windows 11 SDK for Windows 11,  (servicing release 11.0.22621.2428) provides the latest headers, libraries, metadata, and tools for building Windows 11 apps.

## Maintainers

* The Habitat Maintainers: <humans@habitat.sh>

## Type of Package

Binary package


## Usage

This package is typically used as a build dependency for native application projects along with `core/visual-build-tools-2022`. Simply add`core/windows-11-sdk` to your build deps:

```
$pkg_build_deps=@(
    "core/visual-build-tools-2022",
    "core/windows-11-sdk"
)
```

Now the appropriate libraries and include headers should be added to your build environment.
