pkg_name="libtool"
pkg_origin="core"
pkg_version="2.4.7"
pkg_license=('GPL-2.0-or-later')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
GNU libtool is a generic library support script. Libtool hides the complexity \
of using shared libraries behind a consistent, portable interface.\
"
pkg_upstream_url="http://www.gnu.org/software/libtool"
pkg_source="http://ftp.gnu.org/gnu/${pkg_name}/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="04e96c2404ea70c590c546eba4202a4e12722c640016c12b9b2f1ce3d481e9a8"
pkg_filename="${pkg_name}-${pkg_version}.tar.gz"
pkg_deps=(
	core/binutils
	core/coreutils
	core/glibc
	core/grep
	core/m4
	core/sed
)
pkg_build_deps=(
	core/diffutils
	core/gawk
	core/gcc
	core/file
	core/make
	core/patch
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
	sed -e "s,/usr/bin/env,$(pkg_interpreter_for coreutils bin/env),g" -i libtoolize.in
	# Drop the dependency on `help2man` by skipping the generation of a man page
	sed \
		-e "/^dist_man1_MANS =/ s,^.*$,dist_man1_MANS = $(libtoolize_1),g" \
		-i Makefile.in
}

do_build() {
	# * `lt_cv_sys_dlsearch_path` Makes the default library search path empty,
	# rather than `"/lib /usr/lib"`
	./configure \
		--prefix="$pkg_prefix" \
		FILECMD="$(pkg_path_for file)"/bin/file \
		lt_cv_sys_lib_dlsearch_path_spec="" \
		lt_cv_sys_lib_search_path_spec=""
	make
}

do_check() {
	make check TESTSUITEFLAGS=-j"$(nproc)" to
}
do_install() {
	make install
	sed -e "s|^#!.*|#!/bin/sh|g" -i "$pkg_prefix"/bin/libtoolize
}
