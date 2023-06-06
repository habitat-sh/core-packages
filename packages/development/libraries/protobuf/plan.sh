pkg_name="protobuf"
pkg_origin="core"
pkg_version="3.19.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Protocol buffers are a language-neutral, platform-neutral extensible mechanism \
for serializing structured data. \
"
pkg_upstream_url="https://developers.google.com/protocol-buffers/"
pkg_license=('BSD-3-Clause')
pkg_source="https://github.com/google/${pkg_name}/releases/download/v${pkg_version}/${pkg_name}-all-${pkg_version}.tar.gz"
pkg_shasum="7b8d3ac3d6591ce9d25f90faba80da78d0ef620fda711702367f61a40ba98429"

pkg_deps=(
	core/glibc
	core/gcc-libs
	core/zlib
)
pkg_build_deps=(
	core/gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="${pkg_prefix}"

	make -j"$(nproc)"
}

do_check() {
	make check
}

do_install() {
	make install

	# Install license file
	install -Dm644 LICENSE "${pkg_prefix}/share/licenses/LICENSE"
}
