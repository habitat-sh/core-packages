program="mpc"

pkg_name="libmpc-stage1"
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

pkg_build_deps=(
	core/gcc-stage1-with-glibc
	core/gmp-stage1
	core/mpfr-stage1
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	# We disable shared libraries so that when this package is used as a dependency
	# for core/gcc, it will get linked into gcc statically. Thus gcc won't have
	# a runtime dependency back to this library.
	./configure \
		--prefix="$pkg_prefix" \
		--docdir="$pkg_prefix/share/doc/mpc-1.2.1" \
		--disable-shared

	make
}

do_check() {
	make check
}

do_install() {
	make install
	# Remove unneccessary files
	rm -v "${pkg_prefix}/lib/libmpc.la"
}
