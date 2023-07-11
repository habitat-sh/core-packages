pkg_name="gdal"
pkg_origin="core"
pkg_version="2.4.4"
pkg_description="GDAL is a translator library for raster and vector geospatial data formats"
pkg_upstream_url="http://www.gdal.org/"
pkg_license=('MIT')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://download.osgeo.org/gdal/${pkg_version}/gdal-${pkg_version}.tar.gz"
pkg_shasum="e6a2456907610639d73fc6a82bb10aa6fa02e2d03b24edacde34a16b6aa91080"
pkg_deps=(
	core/gcc-libs
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/make
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure --prefix="${pkg_prefix}"
	make -j"$(nproc)"
}
