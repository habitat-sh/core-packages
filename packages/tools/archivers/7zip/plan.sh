pkg_name=7zip
pkg_origin=core
pkg_version=17.05
pkg_license=("LGPL-2.1")
pkg_upstream_url=https://github.com/p7zip-project/p7zip
pkg_description="7-Zip is a file archiver with a high compression ratio"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source=https://github.com/p7zip-project/p${pkg_name}/archive/refs/tags/v${pkg_version}.tar.gz
pkg_shasum=d2788f892571058c08d27095c22154579dfefb807ebe357d145ab2ddddefb1a6
pkg_bin_dirs=(bin)
pkg_lib_dirs=(
  lib/p7zip
  lib/p7zip/Codecs
)
pkg_build_deps=(
  core/coreutils
  core/make
  core/gcc
)
pkg_deps=(
  core/glibc
  core/gcc-libs
)
pkg_dirname="p7zip-${pkg_version}"

do_build() {
 JOBS=$(getconf _NPROCESSORS_ONLN)

  # Build for AMD64 without native yasm.
  cp "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/makefile.linux_amd64" "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/makefile.machine"
  make -j "${JOBS}" all2
}

do_install() {
  make DEST_HOME="${pkg_prefix}" install
}

