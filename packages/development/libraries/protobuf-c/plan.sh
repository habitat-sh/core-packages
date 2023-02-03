pkg_origin=core
pkg_name=protobuf-c
pkg_version=1.4.1
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-2-Clause')
pkg_source="https://github.com/protobuf-c/protobuf-c/releases/download/v${pkg_version}/protobuf-c-${pkg_version}.tar.gz"
pkg_upstream_url=https://github.com/protobuf-c/protobuf-c
pkg_description="Protocol Buffers implementation in C"
pkg_shasum=4cc4facd508172f3e0a4d3a8736225d472418aee35b4ad053384b137b220339f
pkg_deps=(
  core/gcc-libs
  core/protobuf-cpp
  core/zlib
)
pkg_build_deps=(
  core/gcc
  core/make
  core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_check() {
  make check
}
