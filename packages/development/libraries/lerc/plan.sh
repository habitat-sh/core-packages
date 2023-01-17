program="lerc"

pkg_name="lerc"
pkg_origin="core"
pkg_version="4.0.0"
pkg_description="C++ library for Limited Error Raster Compression"
pkg_upstream_url="https://github.com/esri/lerc"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/Esri/lerc/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="91431c2b16d0e3de6cbaea188603359f87caed08259a645fd5a3805784ee30a0"
pkg_deps=(
	core/gcc-libs
	core/glibc
)
pkg_build_deps=(
	core/cmake
	core/gcc
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	# A folder called `build` already exists so we 
	# use a different build folder
	mkdir local-build
	pushd local-build || exit 1
	cmake .. --install-prefix="${pkg_prefix}"
	cmake --build . --parallel "$(nproc)"
	popd || exit 1
}

do_install() {
	pushd local-build || exit 1
	cmake --install .
	popd || exit 1
}
