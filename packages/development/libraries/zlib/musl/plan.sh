pkg_name=zlib-musl
_distname="zlib"
pkg_origin=core
pkg_version=1.3.1
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Compression library implementing the deflate compression method found in gzip \
and PKZIP.\
"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('')
pkg_source="https://zlib.net/fossils/${_distname}-${pkg_version}.tar.gz"
pkg_shasum="9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"
pkg_dirname="${_distname}-${pkg_version}"
#pkg_license=('zlib')
pkg_deps=(
	core/musl
)
pkg_build_deps=(
	core/patch
	core/make
	core/gcc
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	export CC=musl-gcc
	build_line "Setting CC=$CC"
}

