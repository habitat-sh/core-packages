program=npth
pkg_name=npth
pkg_origin=core
pkg_version=1.7
pkg_license=('LGPL-3.0-or-later')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://gnupg.org/ftp/gcrypt/${pkg_name}/${pkg_name}-${pkg_version}.tar.bz2
pkg_upstream_url="https://gnupg.org/software/npth/index.html"
pkg_description="nPth is a library to provide the GNU Pth API and thus a non-preemptive threads implementation."
pkg_shasum=8589f56937b75ce33b28d312fccbf302b3b71ec3f3945fde6aaa74027914ad05
pkg_deps=(core/glibc)
pkg_build_deps=(
  core/gcc
  core/coreutils
  core/sed
  core/bison
  core/flex
  core/grep
  core/bash
  core/gawk
  core/libtool
  core/diffutils
  core/findutils
  core/xz
  core/gettext
  core/gzip
  core/make
  core/patch
  core/texinfo
  core/util-linux
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
  ./configure \
    --prefix="${pkg_prefix}" \
    --enable-static \
    --enable-shared
  make
}

do_check() {
  make check
}

