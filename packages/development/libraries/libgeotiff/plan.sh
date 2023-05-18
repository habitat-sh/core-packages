pkg_name="libgeotiff"
pkg_version="1.7.1"
pkg_origin="core"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://github.com/OSGeo/libgeotiff/releases/download/${pkg_version}/libgeotiff-${pkg_version}.tar.gz"
pkg_upstream_url="https://github.com/OSGeo/libgeotiff"
pkg_description="Library implementing attempt to create a tiff based interchange format for georeferenced raster imagery"
pkg_shasum="05ab1347aaa471fc97347d8d4269ff0c00f30fa666d956baba37948ec87e55d6"
pkg_deps=(
	core/glibc
	core/zlib
	core/libjpeg-turbo
	core/libtiff
	core/jbigkit
	core/proj8
)
pkg_build_deps=(
	core/gcc
	core/pkg-config
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="${pkg_prefix}"
	make
}

do_check() {
	make check
}
