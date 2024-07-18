pkg_name=dpkg
pkg_origin=core
pkg_version=1.22.6
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0-or-later')
pkg_upstream_url="https://wiki.debian.org/dpkg"
pkg_description="dpkg is a package manager for Debian-based systems"
pkg_source="http://http.debian.net/debian/pool/main/d/${pkg_name}/${pkg_name}_${pkg_version}.tar.xz"
pkg_shasum="4379123466cf1804f82aaac7fbea7133c58aefa178dfbf7029cdc61a8d220655"
pkg_deps=(
  core/glibc
  core/ncurses
  core/libmd
  core/perl
  core/xz
)
pkg_build_deps=(
  core/autoconf
  core/automake
  core/bzip2
  core/gcc
  core/gettext
  core/libtool
  core/patch
  core/pkg-config
  core/zlib
  core/diffutils
)
pkg_bin_dirs=(bin sbin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
  export LDFLAGS="$LDFLAGS -Wl,--copy-dt-needed-entries"
}

do_check() {
  make check
}
do_install() {
  do_default_install
  rm -rfv "${pkg_prefix}/var"  
}	
