program="util-linux"
pkg_name="build-tools-util-linux"
pkg_origin="core"
pkg_version="2.38.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Miscellaneous system utilities for Linux"
pkg_upstream_url="https://www.kernel.org/pub/linux/utils/util-linux"
pkg_license=('GPLv2-or-later')
pkg_source="https://www.kernel.org/pub/linux/utils/${program}/v${pkg_version%.?}/${program}-${pkg_version}.tar.xz"
pkg_shasum="60492a19b44e6cf9a3ddff68325b333b8b52b6c59ce3ebd6a0ecaa4c5117e84f"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
    core/build-tools-glibc
)
pkg_build_deps=(
    core/build-tools-gcc
    core/build-tools-coreutils
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --sbindir="$pkg_prefix/bin" \
        --docdir="$pkg_prefix/share/doc/util-linux-2.38.1" \
        --localstatedir="$pkg_svc_var_path/run" \
        --without-python \
        --disable-chfn-chsh \
        --disable-login \
        --disable-nologin \
        --disable-su \
        --disable-setpriv \
        --disable-static \
        --disable-runuser \
        --disable-pylibmount
    make
}

do_install() {
    make install usrsbin_execdir="$pkg_prefix/bin"
}
