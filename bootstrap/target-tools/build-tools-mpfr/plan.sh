program="mpfr"
pkg_name="build-tools-mpfr"
pkg_origin="core"
pkg_version="4.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="GNU MPFR (GNU Multiple Precision Floating-Point Reliably) is a GNU portable C library for arbitrary-precision binary floating-point computation with correct rounding, based on GNU Multi-Precision Library."
pkg_upstream_url="http://www.mpfr.org/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://www.mpfr.org/${program}-${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
	core/build-tools-gmp
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
	--disable-static \
	--enable-thread-safe \
	--docdir="$pkg_prefix"/share/doc/mpfr-4.1.0

    make
}

do_check() {
	make check
}

do_install() {
    make install
}
