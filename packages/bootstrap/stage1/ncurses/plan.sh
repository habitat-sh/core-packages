program="ncurses"

pkg_name="ncurses-stage1"
pkg_origin="core"
pkg_version="6.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('ncurses')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/glibc
	core/linux-headers
	core/gcc-stage1
	core/build-tools-make
	core/build-tools-bash-static
	core/build-tools-coreutils
	core/build-tools-patchelf
)
pkg_include_dirs=(
	include
	include/ncursesw
)
pkg_lib_dirs=(lib)

do_prepare() {
	# Change the dynamic linker and glibc library to link against core/glibc
	case $pkg_target in
	aarch64-linux)
		HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc)/lib/ld-linux-aarch64.so.1"
		export HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER
		build_line "Setting HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER=${HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER}"
		;;
	x86_64-linux)
		HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER="$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2"
		export HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER
		build_line "Setting HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER=${HAB_GCC_STAGE1_GLIBC_DYNAMIC_LINKER}"
		;;
	esac
	HAB_GCC_STAGE1_GLIBC_PKG_PATH="$(pkg_path_for glibc)"
	export HAB_GCC_STAGE1_GLIBC_PKG_PATH
	build_line "Setting HAB_GCC_STAGE1_GLIBC_PKG_PATH=${HAB_GCC_STAGE1_GLIBC_PKG_PATH}"
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--without-shared \
		--without-debug \
		--without-ada \
		--disable-stripping \
		--enable-widec
	make
}

do_install() {
	make install
	rm -rf "${pkg_prefix:?}/bin"
	echo "INPUT(-lncursesw)" >"$pkg_prefix/lib/libcurses.a"

	# Packages depending on curses or ncurses may include headers
	# in multiple ways:
	# * #include <curses.h>
	# * #include <ncurses/curses.h>
	# * #include <ncursesw/curses.h>
	# By adding a symlink from 'ncurses' to 'ncursesw' and including
	# both the 'include' and 'include/ncursesw' folder to the include dirs
	# we can satisfy all these cases correctly
	ln -sv ncursesw "${pkg_prefix}/include/ncurses"
}

do_check() {
	make check
}