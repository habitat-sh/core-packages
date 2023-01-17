pkg_name="libtiff"
pkg_origin="core"
pkg_version="4.5.0"
pkg_description="Library for reading and writting files in the Tag Image File Format (TIFF)"
pkg_upstream_url="http://www.libtiff.org"
pkg_license=('libtiff')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="http://download.osgeo.org/libtiff/tiff-${pkg_version}.tar.gz"
pkg_shasum="c7a1d9296649233979fa3eacffef3fa024d73d05d589cb622727b5b08c423464"
pkg_deps=(
	core/glibc
	core/gcc-libs
	core/lerc
	core/libdeflate
	core/libjpeg-turbo
	core/xz
	core/zlib
	core/zstd
)
pkg_build_deps=(
	core/coreutils
	core/gcc
	core/grep
	core/make
	core/sed
	core/jbigkit
	core/file
	core/python
)
pkg_dirname="tiff-${pkg_version}"
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_check() {
	make check
}
