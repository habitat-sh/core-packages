program="zlib"
native_target="${pkg_target%%-*}-hab-linux-gnu"

pkg_name="zlib"
pkg_origin="core"
pkg_version="1.2.13"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Compression library implementing the deflate compression method found in gzip \
and PKZIP.\
"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('zlib')
pkg_source="http://zlib.net/${program}-${pkg_version}.tar.gz"
pkg_shasum="b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
    core/glibc   
)
pkg_build_deps=(
    core/linux-headers
    core/build-tools-patch
    core/build-tools-make
    core/build-tools-gcc
    core/build-tools-patchelf
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
    case $pkg_target in
    aarch64-linux)
        HAB_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc)/lib/ld-linux-aarch64.so.1"
        ;;
    x86_64-linux)
        HAB_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2"
        ;;
    esac
    export HAB_GLIBC_DYNAMIC_LINKER
    build_line "Setting HAB_GLIBC_DYNAMIC_LINKER=${HAB_GLIBC_DYNAMIC_LINKER}"
    
    HAB_GLIBC_PKG_PATH="$(pkg_path_for glibc)"
    export HAB_GLIBC_PKG_PATH
    build_line "Setting HAB_GLIBC_PKG_PATH=${HAB_GLIBC_PKG_PATH}"

    HAB_LINUX_HEADERS_PKG_PATH="$(pkg_path_for linux-headers)"
    export HAB_LINUX_HEADERS_PKG_PATH
    build_line "Setting HAB_LINUX_HEADERS_PKG_PATH=${HAB_LINUX_HEADERS_PKG_PATH}"

    unset LD_RUN_PATH
    unset LDFLAGS
    unset CFLAGS
    unset CXXFLAGS
    unset CPPFLAGS
    build_line "Unset CFLAGS, CXXFLAGS, CPPFLAGS, LDFLAGS and LD_RUN_PATH"
}

do_install() {
    make install
    # Removes unnecesary rpath entry to build-tools-gcc/lib64
    patchelf --shrink-rpath "${pkg_prefix}/lib/libz.so.${pkg_version}"
}

do_check() {
    make check
}