program="nghttp2"

pkg_name="nghttp2"
pkg_origin="core"
pkg_version="1.51.0"
pkg_description="nghttp2 is an open source HTTP/2 C Library."
pkg_upstream_url="https://nghttp2.org/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_source="https://github.com/${program}/${program}/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="2a0bef286f65b35c24250432e7ec042441a8157a5b93519412d9055169d9ce54"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/cunit
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
	core/python
	core/pkg-config
)

pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="${pkg_prefix}" \
		--enable-lib-only
	make
}

do_check() {
	make check
}

do_install() {
	make install

	# Remove unnecessary folder
	rm -rf "${pkg_prefix}/bin"
}
