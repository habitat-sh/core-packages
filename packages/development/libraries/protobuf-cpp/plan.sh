pkg_name=protobuf-cpp
pkg_distname=protobuf
pkg_origin=core
pkg_version=3.21.12
pkg_license=('BSD-3-Clause')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data."
pkg_upstream_url="https://github.com/google/${pkg_distname}"
pkg_source="https://github.com/google/${pkg_distname}/releases/download/v21.12/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum=4eab9b524aa5913c6fffb20b2a8abf5ef7f95a80bc0701f3a6dbb4c607f73460
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_deps=(
	core/zlib
	core/gcc-libs)
pkg_build_deps=(
	core/gcc)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
