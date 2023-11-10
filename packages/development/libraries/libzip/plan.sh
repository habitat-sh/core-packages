pkg_name=libzip
pkg_origin=core
pkg_version=1.8.0
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="A C library for reading, creating, and modifying zip archives"
pkg_upstream_url="https://libzip.org/"
pkg_license=('BSD-3-Clause')
pkg_source="https://github.com/nih-at/libzip/releases/download/v${pkg_version}/libzip-${pkg_version}.tar.gz"
pkg_shasum=30ee55868c0a698d3c600492f2bea4eb62c53849bcf696d21af5eb65f3f3839e
pkg_deps=(
  core/bzip2
  core/openssl
  core/zlib
  core/xz
  core/zstd
)
pkg_build_deps=(
  core/cmake
  core/gcc
  core/pkg-config
  core/perl
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_build() {
  # We set CMAKE_SKIP_RPATH=TRUE so that cmake doesn't add empty rpaths to the built
  # binaries. Our wrapped gcc automatically takes care of rpath handling as well, so cmake's
  # additional rpath handling is unnecessary
  cmake . \
    -DCMAKE_INSTALL_PREFIX="${pkg_prefix}" \
    -DCMAKE_SKIP_RPATH=TRUE \
    -DCMAKE_PREFIX_PATH="$(pkg_path_for zlib);$(pkg_path_for bzip2);$(pkg_path_for xz);$(pkg_path_for zstd)"
  make -j "$(nproc)"
}