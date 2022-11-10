pkg_name="mpfr"
pkg_origin="core"
pkg_version="4.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU MPFR (GNU Multiple Precision Floating-Point Reliably) is a GNU portable \
C library for arbitrary-precision binary floating-point computation with \
correct rounding, based on GNU Multi-Precision Library.\
"
pkg_upstream_url="http://www.mpfr.org/"
pkg_license=('LGPL-3.0-or-later')
pkg_source="http://www.mpfr.org/${pkg_name}-${pkg_version}/${pkg_name}-${pkg_version}.tar.xz"
pkg_shasum="0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f"

pkg_deps=(
	core/glibc
	core/gmp
)
pkg_build_deps=(
	core/build-tools-make
	core/gcc-bootstrap
	core/build-tools-patchelf
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    ./configure \
        --prefix="$pkg_prefix" \
        --docdir="$pkg_prefix/share/doc/mpfr-4.1.0" \
        --disable-static \
        --enable-thread-safe

    make
}

do_check() {
    make check
}

do_install() {
	make install
	patchelf --shrink-rpath "${pkg_prefix}/lib/libmpfr.so.6.1.0"
}
