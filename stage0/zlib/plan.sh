program="zlib"

pkg_name="zlib-stage0"
pkg_origin="core"
pkg_version="1.2.13"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
Compression library implementing the deflate compression method found in gzip \
and PKZIP.\
"
pkg_upstream_url="http://www.zlib.net/"
pkg_license=('zlib')
pkg_source="http://zlib.net/${program}-${pkg_version}.tar.gz"
pkg_shasum="b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc-stage0
	core/build-tools-coreutils
	core/build-tools-make
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	unset LD_RUN_PATH
	unset LDFLAGS
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
	build_line "Unset CFLAGS, CXXFLAGS, CPPFLAGS, LDFLAGS and LD_RUN_PATH"
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