program="nghttp2"

pkg_name="nghttp2"
pkg_origin="core"
pkg_version="1.46.0"
pkg_description="nghttp2 is an open source HTTP/2 C Library."
pkg_upstream_url="https://nghttp2.org/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_source="https://github.com/${program}/${program}/releases/download/v${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="4b6d11c85f2638531d1327fe1ed28c1e386144e8841176c04153ed32a4878208"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/cunit
	core/gcc
	core/make
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

	# Remove unnecessary folders
	rm -rf "${pkg_prefix:?}"/bin
	rm -rf "${pkg_prefix:?}"/share/nghttp2
}
