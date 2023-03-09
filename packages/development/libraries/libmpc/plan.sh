program="mpc"

pkg_name="libmpc"
pkg_origin="core"
pkg_version="1.2.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU MPC is a C library for the arithmetic of complex numbers with arbitrarily \
high precision and correct rounding of the result.\
"
pkg_upstream_url="http://www.multiprecision.org/"
pkg_license=('LGPL-3.0-or-later')
pkg_source="https://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="17503d2c395dfcf106b622dc142683c1199431d095367c6aacba6eec30340459"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/gmp
	core/mpfr
)

pkg_build_deps=(
	core/coreutils
	core/gcc
	core/grep
	core/make
	core/sed
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix/share/doc/mpc-1.2.1"

	make
}

do_check() {
	make check
}
