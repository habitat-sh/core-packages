program="readline"

pkg_name="readline-stage1"
pkg_origin="core"
pkg_version="8.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="The GNU Readline library provides a set of functions for use by applications \
that allow users to edit command lines as they are typed in."
pkg_upstream_url="http://tiswww.case.edu/php/chet/readline/rltop.html"
pkg_license=('GPL-3.0-or-later')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02"
pkg_dirname="${program}-${pkg_version}"

pkg_build_deps=(
	core/gcc-stage1-with-glibc
	core/ncurses-stage1
	core/build-tools-make
	core/build-tools-bash-static
	core/build-tools-coreutils
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--disable-bracketed-paste-default \
		--with-curses \
		--disable-shared
	make SHLIB_LIBS="-lncursesw"
}

do_check() {
	make check
}

do_install() {
	make install

	# remove unnecessary folder
	rm -rf "${pkg_prefix:?}/bin"
	rm -rf "${pkg_prefix:?}/lib/pkgconfig"
}
