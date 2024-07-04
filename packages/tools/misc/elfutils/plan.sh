program=elfutils
pkg_name=elfutils
pkg_origin=core
pkg_version=0.191
pkg_license=('GPL-3.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="elfutils is a collection of various binary tools such as
  eu-objdump, eu-readelf, and other utilities that allow you to inspect and
  manipulate ELF files."
pkg_upstream_url=https://sourceware.org/elfutils/
pkg_source=https://sourceware.org/${pkg_name}/ftp/${pkg_version}/$pkg_name-$pkg_version.tar.bz2
pkg_shasum=df76db71366d1d708365fc7a6c60ca48398f14367eb2b8954efc8897147ad871
pkg_deps=(
  core/glibc
  core/zlib
  core/gcc-libs
)
pkg_build_deps=(
  core/gcc
  core/m4
  core/make
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_build() {
  ./configure --prefix="$pkg_prefix" --disable-libdebuginfod --disable-debuginfod
  make
}
