program="zlib"

pkg_name="zlib"
pkg_origin="core"
pkg_version="1.2.11"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Compression library implementing the deflate compression method found in gzip \
and PKZIP.\
"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('Zlib')
pkg_source="http://zlib.net/${program}-${pkg_version}.tar.gz"
pkg_shasum="629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff"
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
