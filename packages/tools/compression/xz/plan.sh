program="xz"

pkg_name="xz"
pkg_origin="core"
pkg_version="5.4.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
XZ Utils is free general-purpose data compression software with a high \
compression ratio. XZ Utils were written for POSIX-like systems, but also \
work on some not-so-POSIX systems. XZ Utils are the successor to LZMA Utils.\
"
pkg_upstream_url="http://tukaani.org/xz/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.0-or-later')
pkg_source="http://tukaani.org/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="705d0d96e94e1840e64dec75fc8d5832d34f6649833bec1ced9c3e08cf88132e"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/build-tools-gettext
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix"/share/doc/xz-5.2.6

	make
}

do_check() {
	make check
}

do_install() {
	make install
}
