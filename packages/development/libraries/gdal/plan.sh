pkg_name="gdal"
pkg_origin="core"
pkg_version="3.6.2"
pkg_description="GDAL is a translator library for raster and vector geospatial data formats"
pkg_upstream_url="http://www.gdal.org/"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/OSGeo/gdal/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="5cbc9df4a39c7ff69748defe38cbaf1c46267e124ee4d9b3975354c57dc2d618"
pkg_deps=(
	core/curl
	core/gcc-libs
	core/geos
	core/glibc
	core/giflib
	core/json-c
	core/lerc
	core/libdeflate
	core/libgeotiff
	core/libjpeg-turbo
	core/libpcre2
	core/libpng
	core/libtiff
	core/libxml2
	core/lz4
	core/proj
	core/xz
	core/zlib
	core/zstd
)
pkg_build_deps=(
	core/bison
	core/gcc
	core/cmake
	core/pkg-config
	core/python
	core/sqlite
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# Add package prefix paths to the CMAKE_PREFIX_PATH so that cmake is able
	# to find binaries, libraries and headers
	CMAKE_PREFIX_PATH=$(join_by ";" "${pkg_all_deps_resolved[@]}")
	build_line "Setting CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
}

do_build() {
	mkdir local-build
	pushd local-build || exit 1
	cmake .. \
		--install-prefix="${pkg_prefix}" \
		-DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}"
	cmake --build .
	popd || exit 1
}

do_check() {
	pushd local-build || exit 1
	make test
	popd || exit 1
}

do_install() {
	pushd local-build || exit 1
	cmake --install .
	popd || exit 1
}
