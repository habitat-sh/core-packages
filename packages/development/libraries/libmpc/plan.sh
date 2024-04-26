program="mpc"

pkg_name="libmpc"
pkg_origin="core"
pkg_version="1.3.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU MPC is a C library for the arithmetic of complex numbers with arbitrarily \
high precision and correct rounding of the result.\
"
pkg_upstream_url="http://www.multiprecision.org/"
pkg_license=('LGPL-3.0-or-later')
pkg_source="https://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/gmp
	core/mpfr
)

pkg_build_deps=(
	core/gcc
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
