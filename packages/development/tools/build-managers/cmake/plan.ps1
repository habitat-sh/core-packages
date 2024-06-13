$pkg_name="cmake"
$pkg_origin="core"
$base_version="3.29"
$pkg_version="$base_version.3"
$pkg_description="CMake is an open-source, cross-platform family of tools designed to build, test and package software"
$pkg_upstream_url="https://cmake.org/"
$pkg_license=@("BSD-3-Clause")
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="http://cmake.org/files/v$base_version/cmake-$pkg_version-windows-x86_64.msi"
$pkg_shasum="9a8fc7d24050b6ef354e568dded20a5e26d34c9c3fc344fdec701206b496e05a"
$pkg_build_deps=@("core/lessmsi")
$pkg_bin_dirs=@("bin")

function Invoke-Unpack {
    mkdir "$HAB_CACHE_SRC_PATH/$pkg_dirname"
    Push-Location "$HAB_CACHE_SRC_PATH/$pkg_dirname"
    try {
        lessmsi x (Resolve-Path "$HAB_CACHE_SRC_PATH/$pkg_filename").Path
    } finally { Pop-Location }
}

function Invoke-Install {
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/cmake-$pkg_version-windows-x86_64/SourceDir/cmake/*" "$pkg_prefix" -Recurse -Force
}
