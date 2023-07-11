pkg_name=pkg-config
pkg_origin=core
pkg_version=0.29.2
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
 pkg-config is a helper tool used when compiling applications and libraries. \
 It helps you insert the correct compiler options on the command line so an \
 application can use a call to pkg-config for instance, rather than \
 hard-coding values on where to find glib (or other libraries).\
 "
pkg_upstream_url="http://pkgconfig.freedesktop.org/wiki/"
pkg_license=('GPL-2.0-or-later')
pkg_source="http://pkgconfig.freedesktop.org/releases/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
)
pkg_bin_dirs=(bin)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-internal-glib \
		--disable-host-tool
	make
}

do_check() {
	make check
}
do_install() {
	make install
}
