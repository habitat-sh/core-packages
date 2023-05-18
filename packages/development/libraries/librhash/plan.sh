program="RHash"
pkg_name="librhash"
pkg_origin="core"
pkg_version="1.4.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('0BSD')
pkg_upstream_url="https://rhash.sourceforge.net/"
pkg_description="Console utility and library for computing and verifying hash sums of files"
pkg_source="https://github.com/rhash/RHash/archive/refs/tags/v${pkg_version}.tar.gz"
pkg_shasum="1e40fa66966306920f043866cbe8612f4b939b033ba5e2708c3f41be257c8a3e"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
	core/openssl
)
pkg_build_deps=(
	core/gcc
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--enable-lib-static \
		--enable-lib-shared
	make \
		CFLAGS="${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS} -Wl,-rpath=${pkg_prefix}/lib" \
		-j"$(nproc)"
}

do_check() {
	make \
		CFLAGS="${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS} -Wl,-rpath=${pkg_prefix}/lib" \
		test
}

do_install() {
	# Install headers and shared library symlink
	make install install-lib-headers install-lib-so-link
}
