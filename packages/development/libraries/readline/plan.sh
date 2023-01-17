program="readline"

pkg_name="readline"
pkg_origin="core"
pkg_version="8.2"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The GNU Readline library provides a set of functions for use by applications \
that allow users to edit command lines as they are typed in."
pkg_upstream_url="http://tiswww.case.edu/php/chet/readline/rltop.html"
pkg_license=('GPL-2.0-or-later' 'LGPL-2.1-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/ncurses
)

pkg_build_deps=(
	core/gcc
	core/grep
	core/make
	core/bash-static
	core/coreutils
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--disable-bracketed-paste-default \
		--with-curses \
		--docdir="$pkg_prefix"/share/doc/readline-8.2
	make SHLIB_LIBS="-lncursesw"
}

do_check() {
	make check
}

do_install() {
	make install

	# remove unnecessary folder
	rm -rf "${pkg_prefix}/bin"
	# install documentation
	install -v -m644 doc/*.{ps,pdf,html,dvi} "${pkg_prefix}"/share/doc/readline-8.2
}
