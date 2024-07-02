program=lcms2
pkg_name=lcms2
pkg_origin=core
pkg_version=2.16
pkg_description="Small-footprint color management engine, version 2"
pkg_upstream_url=http://www.littlecms.com
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_source=http://downloads.sourceforge.net/sourceforge/lcms/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=d873d34ad8b9b4cea010631f1a6228d2087475e4dc5e763eb81acc23d9d45a51
pkg_deps=(
  core/glibc
  core/libjpeg-turbo
  core/libtiff
  core/zlib
)
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_check() {
  make check
}

