program="bc"
pkg_name="build-tools-bc"
pkg_origin="core"
pkg_version="6.0.4"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="bc is an arbitrary precision numeric processing language. Syntax is similar to C, but differs in many substantial areas. It supports interactive execution of statements. bc is a utility included in the POSIX P1003.2/D11 draft standard."
pkg_upstream_url="https://git.yzena.com/gavin/bc"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="https://github.com/gavinhoward/bc/releases/download/${pkg_version}/${program}-${pkg_version}.tar.gz"
pkg_shasum="8226167bf22a4bb33b6910042a60e7efde61b5258dec7082a0990f07951c1256"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/build-tools-gcc
	core/build-tools-binutils
)

pkg_bin_dirs=(bin)

do_build() {
	export CC=gcc
	# why NLS is disabled refer url
	# https://github.com/gavinhoward/bc/blob/dc451d675fc2550cda1f079c1aaa3d4d4089d9c3/configure.sh#L140
	./configure \
		--predefined-build-type=GNU \
		--prefix="$pkg_prefix" \
		--disable-nls -O3
	make
}

do_check() {
	export PATH=$PATH:${CACHE_PATH}/bin
	make test
}

do_install() {
    make install
}
