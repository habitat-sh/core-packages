program="make"

pkg_name="make"
pkg_origin="core"
pkg_version="4.4.1"
pkg_description="\
Make is a tool which controls the generation of executables and other \
non-source files of a program from the program's source files.\
"
pkg_upstream_url="https://www.gnu.org/software/make/"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
)
pkg_build_deps=(
	core/gcc
	core/bash
	core/build-tools-perl
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)

do_build() {
	./configure \
		--prefix="$pkg_prefix"
	make
}

do_check() {
	SHELL="$(pkg_path_for bash)"/bin/bash make check
}
