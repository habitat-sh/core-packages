pkg_name=oniguruma
pkg_origin=core
pkg_version="6.9.7.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Oniguruma is a modern and flexible regular expressions library"
pkg_upstream_url="https://github.com/kkos/oniguruma"
pkg_license=("BSD-2-Clause")
pkg_source="https://github.com/kkos/oniguruma/archive/v${pkg_version}.tar.gz"
pkg_shasum="8f9a75b7d90dde0942c30a8b3c17889b2fecf190690988cc381c4e525cbbd22b"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/autoconf
	core/automake
	core/libtool
	core/gcc
)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_bin_dirs=(bin)
pkg_pconfig_dirs=(lib/pkgconfig)

do_build() {
	libtoolize
	./autogen.sh
	./configure \
		--prefix "${pkg_prefix}"
	make
}
