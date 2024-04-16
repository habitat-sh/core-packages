program="zlib"

pkg_name="zlib"
pkg_origin="core"
pkg_version="1.3.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Compression library implementing the deflate compression method found in gzip \
and PKZIP.\
"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('Zlib')
pkg_source="http://zlib.net/${program}-${pkg_version}.tar.gz"
pkg_shasum="6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)

pkg_build_deps=(
	core/gcc
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_check() {
	make check
}
