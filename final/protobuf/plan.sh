pkg_name="protobuf"
pkg_origin="core"
pkg_version="3.19.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Protocol buffers are a language-neutral, platform-neutral extensible mechanism \
for serializing structured data. \
"
pkg_upstream_url="ihttps://developers.google.com/protocol-buffers/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://github.com/google/${pkg_name}/releases/download/v${pkg_version}/${pkg_name}-all-${pkg_version}.tar.gz"
pkg_shasum="7b8d3ac3d6591ce9d25f90faba80da78d0ef620fda711702367f61a40ba98429"

pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/gcc
	core/zlib
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
