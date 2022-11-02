program="binutils"
pkg_name="build-tools-binutils"
pkg_origin="core"
pkg_version="2.39"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The GNU Binary Utilities, or binutils, are a set of programming tools for creating and managing binary programs, object files, libraries, profile data, and assembly source code."
pkg_upstream_url="https://www.gnu.org/software/binutils/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.xz"
pkg_shasum="645c25f563b8adc0a81dbd6a41cffbf4d37083a382e02d5d3df4f65c09516d00"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
)

pkg_build_deps=(
	core/build-tools-gcc
	core/build-tools-texinfo
	core/build-tools-zlib
	core/build-tools-bison
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
    mkdir -v build
    pushd build || exit 1

    ../configure \
	    --prefix="$pkg_prefix" \
	    --sysconfdir=/etc \
	    --enable-gold \
	    --enable-ld=default \
	    --enable-plugins \
	    --enable-shared \
	    --disable-werror \
	    --enable-64-bit-bfd \
	    --with-system-zlib

    make tooldir="${pkg_prefix}"

    popd >/dev/null || exit 1
}

do_check() {
	make check
}

do_install() {
    #make tooldir="${pkg_prefix}" install
    #make --prefix="${pkg_prefix}" install
    make install
}
