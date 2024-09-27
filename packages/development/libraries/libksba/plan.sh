program=libksba
pkg_name=libksba
pkg_origin=core
pkg_version=1.6.7
pkg_license=('LGPL-3.0-or-later')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://gnupg.org/ftp/gcrypt/${pkg_name}/${pkg_name}-${pkg_version}.tar.bz2
pkg_upstream_url="https://www.gnupg.org/software/libksba/index.html"
pkg_description="Libksba is a library to make the tasks of working with X.509 certificates, CMS data and related objects more easy."
pkg_shasum=cf72510b8ebb4eb6693eef765749d83677a03c79291a311040a5bfd79baab763
pkg_deps=(
  core/glibc
  core/libgpg-error
)
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
pkg_bin_dirs=(bin)
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

