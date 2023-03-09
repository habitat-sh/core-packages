program="mpfr"
native_target="${TARGET_ARCH:-${pkg_target%%-*}}-hab-linux-gnu"

pkg_name="build-tools-mpfr"
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
pkg_source="http://www.mpfr.org/${program}-${pkg_version}/${program}-${pkg_version}.tar.xz"
pkg_shasum="0c98a3f1732ff6ca4ea690552079da9c597872d30e96ec28414ee23c95558a7f"
pkg_dirname="${program}-${pkg_version}"
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

pkg_deps=(
	core/build-tools-gmp
	core/build-tools-glibc
)

pkg_build_deps=(
	core/native-cross-gcc
)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(./config.guess)" \
		--host="$native_target" \
		--with-gmp="$(pkg_path_for build-tools-gmp)" \
		--disable-static \
		--enable-thread-safe
	make
}

do_check() {
	make check
}
