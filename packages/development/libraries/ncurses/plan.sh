program="ncurses"

pkg_name="ncurses"
pkg_origin="core"
pkg_version="6.3"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('LicenseRef-ncurses')
pkg_source="http://ftp.gnu.org/gnu/${program}/${program}-${pkg_version}.tar.gz"
pkg_shasum="97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059"
pkg_dirname="${program}-${pkg_version}"

pkg_deps=(
	core/glibc
	core/gcc-libs
)

pkg_build_deps=(
	core/gcc
	core/pkg-config
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include include/ncursesw)
pkg_lib_dirs=(lib)
pkg_pconfig_dirs=(lib/pkgconfig)

do_prepare() {
	export PKG_CONFIG_LIBDIR="${pkg_prefix}/lib/pkgconfig"
	build_line "Setting PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR}"
}

do_build() {
	./configure \
		--prefix="$pkg_prefix" \
		--with-shared \
		--with-termlib \
		--with-cxx-binding \
		--with-cxx-shared \
		--without-ada \
		--with-normal \
		--without-debug \
		--enable-pc-files \
		--with-pkg-config-libdir="${pkg_prefix}/lib/pkgconfig" \
		--enable-symlinks \
		--enable-ext-colors \
		--enable-ext-mouse \
		--enable-sigwinch \
		--enable-overwrite \
		--enable-widec

	make
}

do_install() {
	make install

	# Many packages that use Ncurses will compile just fine against the widechar
	# libraries, but won't know to look for them. Create symbolic links to
	# allow older and non-widec compatible programs to build properly
	for lib in ncurses form panel menu tinfo; do
		rm -vf "${pkg_prefix}/lib/lib${lib}.so"
		ln -sfv "lib${lib}w.a" "${pkg_prefix}/lib/lib${lib}.a"
		ln -sfv "lib${lib}w.so" "${pkg_prefix}/lib/lib${lib}.so"
		ln -sfv ${lib}w.pc "${pkg_prefix}/lib/pkgconfig/${lib}.pc"
	done

	# Add additional linker scripts so that any programs looking for curses
	# will find ncurses
	ln -sfv "libncursesw.a" "${pkg_prefix}/lib/libcurses.a"
	ln -sfv "libncursesw.so" "${pkg_prefix}/lib/libcurses.so"

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
