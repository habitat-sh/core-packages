program="proj"

pkg_name="proj8"
pkg_origin="core"
pkg_version="8.2.1"
pkg_description="Cartographic Projections Library"
pkg_upstream_url="https://proj.org/"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://download.osgeo.org/proj/proj-${pkg_version}.tar.gz"
pkg_shasum="76ed3d0c3a348a6693dfae535e5658bbfd47f71cb7ff7eb96d9f12f7e068b1cf"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
	core/libtiff
	core/curl
	core/sqlite
)
pkg_build_deps=(
	core/gcc
	core/cmake
	core/python
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	# Add package prefix paths to the CMAKE_PREFIX_PATH so that cmake is able
	# to find binaries, libraries and headers
	CMAKE_PREFIX_PATH=$(join_by ";" "${pkg_all_deps_resolved[@]}")
	build_line "Setting CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
}

do_build() {
	mkdir build
	pushd build || exit 1
	cmake .. \
		--install-prefix="${pkg_prefix}" \
		-DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
		-DCMAKE_BUILD_TYPE=Release
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
