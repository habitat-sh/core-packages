program="gcc"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="gcc-bootstrap"
pkg_origin="core"
pkg_version="12.2.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
The GNU Compiler Collection (GCC) is a compiler system produced by the GNU \
Project supporting various programming languages. GCC is a key component of \
the GNU toolchain and the standard compiler for most Unix-like operating \
systems. This package is a wrapper around the build-tools-gcc package with
additional configuration to link against core/glibc instead of core/build-tools-glibc.\
"
pkg_upstream_url="https://gcc.gnu.org/"
pkg_license=('GPL-3.0-or-later' 'GCC Runtime Library Exception')

pkg_deps=(
    core/glibc
    core/build-tools-gcc
    core/linux-headers
)

pkg_bin_dirs=(bin)

do_prepare() {
    case $pkg_target in
    aarch64-linux)
        set_runtime_env "HAB_GLIBC_DYNAMIC_LINKER" "$(pkg_path_for glibc)/lib/ld-linux-aarch64.so.1"
        ;;
    x86_64-linux)
        set_runtime_env "HAB_GLIBC_DYNAMIC_LINKER" "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2"
        ;;
    esac
    set_runtime_env "HAB_GLIBC_PKG_PATH" "$(pkg_path_for glibc)"
    set_runtime_env "HAB_LINUX_HEADERS_PKG_PATH" "$(pkg_path_for linux-headers)"
}

do_build() {
    return 0
}

do_install() {
    return 0
}