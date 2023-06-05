pkg_name=protobuf-cpp
pkg_distname=protobuf
pkg_origin=core
pkg_version="3.19.0"
pkg_license=('BSD-3-Clause')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data."
pkg_upstream_url="https://github.com/google/${pkg_distname}"
pkg_source="https://github.com/google/${pkg_distname}/releases/download/v${pkg_version}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="24ce6d7c1899cf4dbc360354bd5420dab9927a2a30e533af5357c719b0f50672"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_deps=(
core/gcc-base 
core/zlib)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
