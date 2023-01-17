pkg_name="libunistring"
pkg_origin="core"
pkg_version="1.0"
pkg_description="Library functions for manipulating Unicode strings"
pkg_upstream_url="https://www.gnu.org/software/libunistring/"
pkg_license=('LGPL-3.0-or-later')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://ftp.gnu.org/gnu/libunistring/libunistring-${pkg_version}.tar.xz"
pkg_shasum="5bab55b49f75d77ed26b257997e919b693f29fd4a1bc22e0e6e024c246c72741"
pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/coreutils
	core/gawk
	core/gcc
	core/grep
	core/make
	core/sed
	core/build-tools-texinfo
	core/build-tools-perl
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_check() {
	make check
}
