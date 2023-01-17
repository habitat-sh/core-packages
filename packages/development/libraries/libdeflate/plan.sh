program="libdeflate"

pkg_name="libdeflate"
pkg_origin="core"
pkg_version="1.15"
pkg_description="Fast DEFLATE/zlib/gzip compressor and decompressor"
pkg_upstream_url="https://github.com/ebiggers/libdeflate"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/ebiggers/libdeflate/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="58b95040df7383dc0413defb700d9893c194732474283cc4c8f144b00a68154b"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/cmake
	core/zlib
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	mkdir build
	pushd build || exit 1
	cmake .. \
		--install-prefix="${pkg_prefix}" \
		-DCMAKE_PREFIX_PATH="$(pkg_path_for zlib)" \
		-DLIBDEFLATE_BUILD_TESTS=ON
	cmake --build .
	popd || exit 1
}

do_check() {
	pushd build || exit 1
	make test
	popd || exit 1
}

do_install() {
	pushd build || exit 1
	cmake --install .
	popd || exit 1
}
