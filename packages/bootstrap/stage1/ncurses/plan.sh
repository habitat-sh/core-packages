program="ncurses"

pkg_name="ncurses-stage1"
pkg_origin="core"
pkg_version="6.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('LicenseRef-ncurses')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/glibc
	core/gcc-stage1-with-glibc
	core/build-tools-make
	core/build-tools-bash-static
	core/build-tools-coreutils
)
pkg_include_dirs=(
	include
	include/ncursesw
)
pkg_lib_dirs=(lib)

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

	# We create a link script so anyone linking against libcurses.a
	# will link to libncursesw.a instead
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
