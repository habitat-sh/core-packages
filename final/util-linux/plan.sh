pkg_name=util-linux
pkg_origin=core
pkg_version=2.38.1
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Miscellaneous system utilities for Linux"
pkg_upstream_url="https://www.kernel.org/pub/linux/utils/util-linux"
pkg_license=('GPLv2-or-later')
pkg_source="https://www.kernel.org/pub/linux/utils/${pkg_name}/v${pkg_version%.?}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="60492a19b44e6cf9a3ddff68325b333b8b52b6c59ce3ebd6a0ecaa4c5117e84f"
pkg_deps=(
  core/glibc
  core/zlib
  core/ncurses
)
pkg_build_deps=(
  core/coreutils
  core/diffutils
  core/patch
  core/make
  core/gcc
  core/sed
  core/pcre2
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
  ./configure \
    --prefix="$pkg_prefix" \
    --sbindir="$pkg_prefix/bin" \
    --localstatedir="$pkg_svc_var_path/run" \
    --without-python \
    --without-slang \
    --without-systemd \
    --without-systemdsystemunitdir \
    --disable-use-tty-group \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount
  make
}

do_install() {
  make install usrsbin_execdir="$pkg_prefix/bin"
}

