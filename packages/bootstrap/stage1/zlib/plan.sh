program="zlib"

pkg_name="zlib-stage1"
pkg_origin="core"
pkg_version="1.2.11"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Compression library implementing the deflate compression method found in gzip \
and PKZIP.\
"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('Zlib')
pkg_source="http://github.com/madler/${program}/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc-stage1-with-glibc
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
