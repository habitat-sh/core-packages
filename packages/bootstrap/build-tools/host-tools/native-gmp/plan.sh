program="gmp"

pkg_name="native-gmp"
pkg_origin="core"
pkg_version="6.3.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GMP is a free library for arbitrary precision arithmetic, operating on signed \
integers, rational numbers, and floating-point numbers.\
"
pkg_upstream_url="https://gmplib.org"
pkg_license=('LGPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
pkg_dirname="${program}-${pkg_version}"
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--build="$(./config.guess)" \
		--host="$(./config.guess)" \
		--disable-static
	make
}

do_check() {
	make check
}
