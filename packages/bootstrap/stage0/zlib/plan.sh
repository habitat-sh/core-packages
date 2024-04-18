program="zlib"

pkg_name="zlib-stage0"
pkg_origin="core"
pkg_version="1.3.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Compression library implementing the deflate compression method found in gzip \
and PKZIP.\
"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('Zlib')
pkg_source="https://github.com/madler/${program}/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc-stage0
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	# The "-fPIC" flag is essential for the generation of libz.a archive.
	# Without it, the generated archive cannot be linked into shared libraries
	# on certain platforms.
	export CFLAGS="-fPIC"
}

do_install() {
	make install

	# We want to statically link zlib into gcc and binutils so we remove
	# unnecessary shared libraries and pkgconfig
	rm -fv "${pkg_prefix}"/lib/*.so*
	rm -rfv "${pkg_prefix}"/lib/pkgconfig
}

do_check() {
	make check
}
