program="gettext"

pkg_name="gettext"
pkg_origin="core"
pkg_version="0.21"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="GNU internationalization library."
pkg_upstream_url="http://www.gnu.org/software/gettext/"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/$program/${program}-${pkg_version}.tar.gz"
pkg_shasum="c77d0da3102aec9c07f43671e60611ebff89a996ef159497ce8e59d075786b12"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
	core/acl
	core/bash-static
	core/coreutils
	core/gcc-libs
	core/glibc
	core/bzip2
	core/gzip
	core/sed
	core/xz
)
pkg_build_deps=(
	core/gawk
	core/gcc
	core/grep
	core/make
	core/tcl-stage1
	core/build-tools-bison
	core/build-tools-perl
	core/build-tools-python
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_build() {
	./configure \
		--prefix="$pkg_prefix"

	make -j"$(nproc)"
}

do_check() {
	make check
}

do_install() {
	make install

	chmod -v 0755 "${pkg_prefix}"/lib/preloadable_libintl.so
	# Fix scripts
	fix_interpreter "${pkg_prefix}/bin/*" core/bash-static bin/sh
}
