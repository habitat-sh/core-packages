pkg_name="geos"
pkg_origin="core"
pkg_version="3.9.2"
pkg_description="GEOS (Geometry Engine - Open Source) is a C++ port of the ​Java Topology Suite (JTS)."
pkg_upstream_url="https://libgeos.org/"
pkg_license=('LGPL')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://download.osgeo.org/geos/geos-${pkg_version}.tar.bz2"
pkg_shasum="44a5a9be21d7d473436bf621c2ddcc3cf5a8bbe3c786e13229618a3b9d861297"

pkg_deps=(
	core/glibc
	core/gcc-libs
)
pkg_build_deps=(
	core/gcc
	core/cmake
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
		-DCMAKE_INSTALL_RPATH="$pkg_prefix/$lib"
	cmake --build . --parallel "$(nproc)"
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
