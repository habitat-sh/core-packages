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
	core/expat
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
	core/proj8
	core/xz
	core/zlib
	core/zstd
	core/python
	core/sqlite
)
pkg_build_deps=(
	core/bison
	core/gcc
	core/cmake
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# Add package prefix paths to the CMAKE_PREFIX_PATH so that cmake is able
	# to find binaries, libraries and headers
	CMAKE_PREFIX_PATH=$(join_by ";" "${pkg_all_deps_resolved[@]}")
	build_line "Setting CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
	local cmake_rpath_part=("$pkg_prefix/$lib")
	for dep_path in "${pkg_deps_resolved[@]}"; do
		if [[ -d "$dep_path/lib" ]]; then
			cmake_rpath_part+=("$dep_path/lib")
		fi
	done
	CMAKE_INSTALL_RPATH=$(join_by ";" "${cmake_rpath_part[@]}")
	build_line "Setting CMAKE_INSTALL_RPATH=${CMAKE_INSTALL_RPATH}"
}

do_build() {
	mkdir local-build
	pushd local-build || exit 1
	cmake .. \
		--install-prefix="${pkg_prefix}" \
		-DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
		-DCMAKE_INSTALL_RPATH="${CMAKE_INSTALL_RPATH}" \
		-DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE \
		-DCMAKE_BUILD_TYPE=Release
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